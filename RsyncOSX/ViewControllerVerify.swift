//
//  ViewControllerVerify.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.07.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerVerify: NSViewController, SetConfigurations, GetIndex {

    @IBOutlet weak var outputtable: NSTableView!
    var outputprocess: OutputProcess?
    var index: Int?
    var estimatedindex: Int?
    var gotremoteinfo: Bool = false
    private var numbers: NSMutableDictionary?
    private var complete: Bool = false
    private var processRefererence: ProcessCmd?

    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var verifybutton: NSButton!
    @IBOutlet weak var deletedbutton: NSButton!

    @IBOutlet weak var transferredNumber: NSTextField!
    @IBOutlet weak var transferredNumberSizebytes: NSTextField!
    @IBOutlet weak var newfiles: NSTextField!
    @IBOutlet weak var deletefiles: NSTextField!
    @IBOutlet weak var totalNumber: NSTextField!
    @IBOutlet weak var totalDirs: NSTextField!
    @IBOutlet weak var totalNumberSizebytes: NSTextField!
    @IBOutlet weak var localtotalNumber: NSTextField!
    @IBOutlet weak var localtotalDirs: NSTextField!
    @IBOutlet weak var localtotalNumberSizebytes: NSTextField!
    @IBOutlet weak var gotit: NSTextField!
    @IBOutlet weak var datelastbackup: NSTextField!
    @IBOutlet weak var dayslastbackup: NSTextField!
    @IBOutlet weak var rsynccommanddisplay: NSTextField!
    @IBOutlet weak var verifyradiobutton: NSButton!
    @IBOutlet weak var deletedradiobutton: NSButton!

    @IBAction func verify(_ sender: NSButton) {
        if self.index != nil {
            self.rsynccommanddisplay.stringValue = Tools().displayrsynccommand(index: self.index!, display: .verify)
            self.verifyradiobutton.state = .on
            self.deletedradiobutton.state = .off
            self.gotit.stringValue = "Verifying, please wait..."
            self.enabledisablebuttons(enable: false)
            self.working.startAnimation(nil)
            let arguments = self.configurations?.arguments4verify(index: self.index!)
            self.outputprocess = OutputProcess()
            self.outputprocess?.addlinefromoutput("*** Verify ***")
            let verifytask = VerifyTask(arguments: arguments)
            verifytask.executeProcess(outputprocess: self.outputprocess)
            self.processRefererence = verifytask
        }
    }

    @IBAction func deleted(_ sender: NSButton) {
        if self.index != nil {
            self.rsynccommanddisplay.stringValue = Tools().displayrsynccommand(index: self.index!, display: .restore)
            self.deletedradiobutton.state = .on
            self.verifyradiobutton.state = .off
            self.gotit.stringValue = "Computing deleted, please wait..."
            self.enabledisablebuttons(enable: false)
            self.working.startAnimation(nil)
            let arguments = self.configurations?.arguments4restore(index: self.index!, argtype: .argdryRun)
            self.outputprocess = OutputProcess()
            self.outputprocess?.addlinefromoutput("*** Deleted ***")
            let verifytask = VerifyTask(arguments: arguments)
            verifytask.executeProcess(outputprocess: self.outputprocess)
            self.processRefererence = verifytask
        }
    }

    @IBAction func info(_ sender: NSButton) {
        let resources = Resources()
        NSWorkspace.shared.open(URL(string: resources.getResource(resource: .verify))!)
    }

    @IBAction func displayrsynccommand(_ sender: NSButton) {
        guard self.index != nil else {
            self.rsynccommanddisplay.stringValue = ""
            return
        }
        if self.verifyradiobutton.state == .on {
            self.rsynccommanddisplay.stringValue = Tools().displayrsynccommand(index: self.index!, display: .verify)
        } else {
            self.rsynccommanddisplay.stringValue = Tools().displayrsynccommand(index: self.index!, display: .restore)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcverify, nsviewcontroller: self)
        self.outputtable.delegate = self
        self.outputtable.dataSource = self
        self.working.usesThreadedAnimation = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.index = self.index(viewcontroller: .vctabmain)
        if let index = self.index {
            guard self.estimatedindex ?? -1 != index else { return }
            self.resetinfo()
            self.enabledisablebuttons(enable: false)
            self.estimatedindex = index
            self.gotit.stringValue = "Getting information, please wait ..."
            self.gotremoteinfo = false
            self.complete = false
            let datelastbackup = self.configurations?.getConfigurations()[index].dateRun ?? "none"
            let numberlastbackup = self.configurations?.getConfigurations()[index].dayssincelastbackup ?? "none"
            self.datelastbackup.stringValue = "Date last backup: " + datelastbackup
            self.dayslastbackup.stringValue = "Days since last backup: " + numberlastbackup
            self.estimateremoteinfo(index: index, local: true)
        } else {
            self.gotit.stringValue = "Please select a task in main view ..."
            self.outputprocess = nil
            globalMainQueue.async(execute: { () -> Void in
                self.outputtable.reloadData()
            })
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        guard self.processRefererence != nil else { return }
        self.processRefererence!.abortProcess()
    }

    private func enabledisablebuttons(enable: Bool) {
        self.verifybutton.isEnabled = enable
        self.deletedbutton.isEnabled = enable
    }

    private func estimateremoteinfo(index: Int, local: Bool) {
        var arguments: [String]?
        self.working.startAnimation(nil)
        self.outputprocess = OutputProcess()
        if local {
            globalMainQueue.async(execute: { () -> Void in
                self.outputtable.reloadData()
            })
            arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRunlocalcataloginfo)
        } else {
            arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRun)
        }
        let verifytask = VerifyTask(arguments: arguments)
        verifytask.executeProcess(outputprocess: self.outputprocess)
        self.processRefererence = verifytask
    }

    private func setNumbers(outputprocess: OutputProcess?, local: Bool) {
        globalMainQueue.async(execute: { () -> Void in
            let infotask = RemoteInfoTask(outputprocess: outputprocess)
            if local {
                self.numbers = NSMutableDictionary()
                self.localtotalNumber.stringValue = infotask.totalNumber!
                self.localtotalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.localtotalDirs.stringValue = infotask.totalDirs!
                self.numbers?.setValue(self.index!, forKey: "index")
                self.numbers?.setValue(infotask.totalNumber!, forKey: "localtotalNumber")
                self.numbers?.setValue(infotask.totalNumberSizebytes!, forKey: "localtotalNumberSizebytes")
                self.numbers?.setValue(infotask.totalDirs!, forKey: "localtotalDirs")
            } else {
                self.transferredNumber.stringValue = infotask.transferredNumber!
                self.transferredNumberSizebytes.stringValue = infotask.transferredNumberSizebytes!
                self.totalNumber.stringValue = infotask.totalNumber!
                self.totalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.totalDirs.stringValue = infotask.totalDirs!
                self.newfiles.stringValue = infotask.newfiles!
                self.deletefiles.stringValue = infotask.deletefiles!
                self.numbers?.setValue(infotask.transferredNumber!, forKey: "transferredNumber")
                self.numbers?.setValue(infotask.transferredNumberSizebytes!, forKey: "transferredNumberSizebytes")
                self.numbers?.setValue(infotask.totalNumber!, forKey: "totalNumber")
                self.numbers?.setValue(infotask.totalNumberSizebytes!, forKey: "totalNumberSizebytes")
                self.numbers?.setValue(infotask.totalDirs!, forKey: "totalDirs")
                self.numbers?.setValue(infotask.newfiles!, forKey: "newfiles")
                self.numbers?.setValue(infotask.deletefiles!, forKey: "deletefiles")
                self.working.stopAnimation(nil)
                self.gotit.stringValue = ""
            }
        })
    }

    private func resetinfo() {
        self.localtotalNumber.stringValue = ""
        self.localtotalNumberSizebytes.stringValue = ""
        self.localtotalDirs.stringValue = ""
        self.transferredNumber.stringValue = ""
        self.transferredNumberSizebytes.stringValue = ""
        self.totalNumber.stringValue = ""
        self.totalNumberSizebytes.stringValue = ""
        self.totalDirs.stringValue = ""
        self.newfiles.stringValue = ""
        self.deletefiles.stringValue = ""
        self.datelastbackup.stringValue = "Date last backup:"
        self.dayslastbackup.stringValue = "Days since last backup:"
        self.rsynccommanddisplay.stringValue = ""
        self.verifyradiobutton.state = .off
        self.deletedradiobutton.state = .off
        self.rsynccommanddisplay.stringValue = ""
    }
}

extension ViewControllerVerify: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.outputprocess?.getOutput()?.count ?? 0
    }
}

extension ViewControllerVerify: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if tableColumn == tableView.tableColumns[0] {
            text = self.outputprocess!.getOutput()![row]
            cellIdentifier = "outputID"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

extension ViewControllerVerify: UpdateProgress {
    func processTermination() {
        if self.gotremoteinfo == false {
            if self.complete == false {
                self.setNumbers(outputprocess: self.outputprocess, local: true)
            } else {
                self.gotremoteinfo = true
                self.setNumbers(outputprocess: self.outputprocess, local: false)
                self.enabledisablebuttons(enable: true)
            }
            if let index = self.index {
                if self.complete == false {
                    self.complete = true
                    self.outputprocess = OutputProcess()
                    self.estimateremoteinfo(index: index, local: false)
                }
            }
        } else {
            self.working.stopAnimation(nil)
            self.gotit.stringValue = "Completed ..."
        }
    }

    func fileHandler() {
        if self.gotremoteinfo == true {
            globalMainQueue.async(execute: { () -> Void in
                self.outputtable.reloadData()
            })
        }
    }
}
