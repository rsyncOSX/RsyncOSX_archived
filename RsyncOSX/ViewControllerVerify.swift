//
//  ViewControllerVerify.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.07.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length type_body_length

import Cocoa
import Foundation

class ViewControllerVerify: NSViewController, SetConfigurations, Index, VcMain, Connected, Setcolor, Checkforrsync {
    var outputprocess: OutputProcess?
    var lastindex: Int?
    var estimatedindex: Int?
    var gotremoteinfo: Bool = false
    private var complete: Bool = false
    private var processRefererence: ProcessCmd?
    let lastdate: String = NSLocalizedString("Date last backup:", comment: "Verify")
    let dayssince: String = NSLocalizedString("Days since last backup:", comment: "Verify")

    @IBOutlet var outputtable: NSTableView!
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var verifybutton: NSButton!
    @IBOutlet var changedbutton: NSButton!

    @IBOutlet var transferredNumber: NSTextField!
    @IBOutlet var transferredNumberSizebytes: NSTextField!
    @IBOutlet var newfiles: NSTextField!
    @IBOutlet var deletefiles: NSTextField!
    @IBOutlet var totalNumber: NSTextField!
    @IBOutlet var totalDirs: NSTextField!
    @IBOutlet var totalNumberSizebytes: NSTextField!
    @IBOutlet var localtotalNumber: NSTextField!
    @IBOutlet var localtotalDirs: NSTextField!
    @IBOutlet var localtotalNumberSizebytes: NSTextField!
    @IBOutlet var gotit: NSTextField!
    @IBOutlet var datelastbackup: NSTextField!
    @IBOutlet var dayslastbackup: NSTextField!
    @IBOutlet var rsynccommanddisplay: NSTextField!
    @IBOutlet var verifyradiobutton: NSButton!
    @IBOutlet var changedradiobutton: NSButton!

    @IBOutlet var localcatalog: NSTextField!
    @IBOutlet var remotecatalog: NSTextField!
    @IBOutlet var remoteserver: NSTextField!

    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    @IBAction func quickbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_: NSButton) {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        }
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        }
    }

    @IBAction func verify(_: NSButton) {
        if let index = self.index() {
            self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: index, display: .verify).displayrsyncpath ?? ""
            self.verifyradiobutton.state = .on
            self.changedradiobutton.state = .off
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .white)
            let gotit: String = NSLocalizedString("Verifying, please wait...", comment: "Verify")
            self.gotit.stringValue = gotit
            self.enabledisablebuttons(enable: false)
            self.working.startAnimation(nil)
            if let arguments = self.configurations?.arguments4verify(index: index) {
                self.outputprocess = OutputProcess()
                self.outputprocess?.addlinefromoutput(str: "*** Verify ***")
                self.verifyandchanged(arguments: arguments)
            }
        }
    }

    @IBAction func changed(_: NSButton) {
        if let index = self.index() {
            self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: index, display: .restore).displayrsyncpath ?? ""
            self.changedradiobutton.state = .on
            self.verifyradiobutton.state = .off
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .white)
            let gotit: String = NSLocalizedString("Computing changed, please wait...", comment: "Verify")
            self.gotit.stringValue = gotit
            self.enabledisablebuttons(enable: false)
            self.working.startAnimation(nil)
            if let arguments = self.configurations?.arguments4restore(index: index, argtype: .argdryRun) {
                self.outputprocess = OutputProcess()
                self.outputprocess?.addlinefromoutput(str: "*** Changed ***")
                self.verifyandchanged(arguments: arguments)
            }
        }
    }

    private func verifyandchanged(arguments: [String]) {
        let verifytask = ProcessCmd(command: nil, arguments: arguments)
        verifytask.setupdateDelegate(object: self)
        verifytask.executeProcess(outputprocess: self.outputprocess)
        self.processRefererence = verifytask
    }

    @IBAction func info(_: NSButton) {
        let resources = Resources()
        NSWorkspace.shared.open(URL(string: resources.getResource(resource: .verify))!)
    }

    @IBAction func displayrsynccommand(_: NSButton) {
        if let index = self.index() {
            if self.verifyradiobutton.state == .on {
                self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: index, display: .verify).displayrsyncpath ?? ""
            } else {
                self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: index, display: .restore).displayrsyncpath ?? ""
            }
        } else {
            self.rsynccommanddisplay.stringValue = ""
        }
    }

    // Abort button
    @IBAction func abort(_: NSButton) {
        self.processRefererence?.abortProcess()
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
        if self.index() != nil, self.reload() {
            self.resetinfo()
            self.setinfo()
            self.enabledisablebuttons(enable: false)
            self.estimatedindex = self.index()
            let gotit: String = NSLocalizedString("Getting information, please wait ...", comment: "Verify")
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.gotit.stringValue = gotit
            self.gotremoteinfo = false
            self.complete = false
            let datelastbackup = self.configurations?.getConfigurations()[self.index()!].dateRun ?? ""
            if datelastbackup.isEmpty == false {
                let date = datelastbackup.en_us_date_from_string()
                self.datelastbackup.stringValue = NSLocalizedString("Date last backup:", comment: "Remote Info")
                    + " " + date.localized_string_from_date()
            } else {
                self.datelastbackup.stringValue = NSLocalizedString("Date last backup:", comment: "Remote Info")
            }
            let numberlastbackup = self.configurations?.getConfigurations()[self.index()!].dayssincelastbackup ?? ""
            self.dayslastbackup.stringValue = self.dayssince + " " + numberlastbackup
            self.estimateremoteinfo(index: self.index()!, local: true)
        } else {
            _ = self.reload()
        }
    }

    private func reload() -> Bool {
        if let index = self.index() {
            let config = self.configurations!.getConfigurations()[index]
            guard config.task != ViewControllerReference.shared.syncremote else {
                self.gotit.textColor = setcolor(nsviewcontroller: self, color: .red)
                let message: String = NSLocalizedString("Cannot verify a syncremote task...", comment: "Verify")
                self.gotit.stringValue = message
                self.verifybutton.isEnabled = false
                self.changedbutton.isEnabled = false
                self.resetinfo()
                return false
            }
            guard self.connected(config: config) == true else {
                self.gotit.textColor = setcolor(nsviewcontroller: self, color: .red)
                let dontgotit: String = NSLocalizedString("Seems not to be connected...", comment: "Verify")
                self.gotit.stringValue = dontgotit
                self.verifybutton.isEnabled = false
                self.changedbutton.isEnabled = false
                self.resetinfo()
                return false
            }
            guard self.index() != self.lastindex ?? -1 else { return false }
            guard self.estimatedindex ?? -1 != index else { return false }
        } else {
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
            let task: String = NSLocalizedString("Please select a task in Execute ...", comment: "Verify")
            self.gotit.stringValue = task
            self.outputprocess = nil
            self.resetinfo()
            globalMainQueue.async { () -> Void in
                self.outputtable.reloadData()
            }
            guard self.index() != nil else { return false }
        }
        return true
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.lastindex = self.index()
    }

    private func enabledisablebuttons(enable: Bool) {
        self.verifybutton.isEnabled = enable
        self.changedbutton.isEnabled = enable
    }

    private func estimateremoteinfo(index: Int, local: Bool) {
        var arguments: [String]?
        self.working.startAnimation(nil)
        self.outputprocess = OutputProcess()
        if local {
            globalMainQueue.async { () -> Void in
                self.outputtable.reloadData()
            }
            arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRunlocalcataloginfo)
        } else {
            arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRun)
        }
        let estimate = ProcessCmd(command: nil, arguments: arguments)
        estimate.setupdateDelegate(object: self)
        estimate.executeProcess(outputprocess: self.outputprocess)
        self.processRefererence = estimate
    }

    private func publishnumbers(outputprocess: OutputProcess?, local: Bool) {
        globalMainQueue.async { () -> Void in
            let infotask = RemoteinfonumbersOnetask(outputprocess: outputprocess)
            if local {
                self.localtotalNumber.stringValue = infotask.totalNumber!
                self.localtotalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.localtotalDirs.stringValue = infotask.totalDirs!
            } else {
                self.transferredNumber.stringValue = infotask.transferredNumber!
                self.transferredNumberSizebytes.stringValue = infotask.transferredNumberSizebytes!
                self.totalNumber.stringValue = infotask.totalNumber!
                self.totalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.totalDirs.stringValue = infotask.totalDirs!
                self.newfiles.stringValue = infotask.newfiles!
                self.deletefiles.stringValue = infotask.deletefiles!
                self.working.stopAnimation(nil)
                self.gotit.stringValue = ""
            }
        }
    }

    private func setinfo() {
        if let hiddenID = self.configurations?.gethiddenID(index: self.index() ?? -1) {
            self.localcatalog.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .localCatalog)
            self.remoteserver.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteServer)
            self.remotecatalog.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .remoteCatalog)
        }
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
        self.datelastbackup.stringValue = self.lastdate
        self.dayslastbackup.stringValue = self.dayssince
        self.rsynccommanddisplay.stringValue = ""
        self.verifyradiobutton.state = .off
        self.changedradiobutton.state = .off
        self.rsynccommanddisplay.stringValue = ""
        self.localcatalog.stringValue = ""
        self.remoteserver.stringValue = ""
        self.remotecatalog.stringValue = ""
    }
}

extension ViewControllerVerify: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.outputprocess?.getOutput()?.count ?? 0
    }
}

extension ViewControllerVerify: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = self.outputprocess?.getOutput()?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}

extension ViewControllerVerify: UpdateProgress {
    func processTermination() {
        if self.gotremoteinfo == false {
            if self.complete == false {
                self.publishnumbers(outputprocess: self.outputprocess, local: true)
            } else {
                self.gotremoteinfo = true
                self.publishnumbers(outputprocess: self.outputprocess, local: false)
                self.enabledisablebuttons(enable: true)
            }
            if let index = self.index() {
                if self.complete == false {
                    self.complete = true
                    self.outputprocess = OutputProcess()
                    self.estimateremoteinfo(index: index, local: false)
                }
            }
            globalMainQueue.async(execute: { () -> Void in
                self.outputtable.reloadData()
            })
        } else {
            self.working.stopAnimation(nil)
            let gotit: String = NSLocalizedString("Completed ...", comment: "Verify")
            self.gotit.stringValue = gotit
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.changedbutton.isEnabled = true
            self.verifybutton.isEnabled = true
        }
    }

    func fileHandler() {
        if self.gotremoteinfo == true {
            globalMainQueue.async { () -> Void in
                self.outputtable.reloadData()
            }
        }
    }
}

extension ViewControllerVerify: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerVerify: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}
