//
//  ViewControllerVerify.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.07.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerVerify: NSViewController, SetConfigurations, Index, VcMain, Connected, Setcolor, Checkforrsync, Help {
    var outputprocess: OutputProcess?
    var lastindex: Int?
    var estimatedindex: Int?
    var gotremoteinfo: Bool = false
    private var complete: Bool = false
    let lastdate: String = NSLocalizedString("Date last synchronize:", comment: "Verify")
    let dayssince: String = NSLocalizedString("Days since last synchronize:", comment: "Verify")

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
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    @IBAction func verify(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        if let index = self.index() {
            self.estimatedindex = index
            self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: index, display: .verify).displayrsyncpath ?? ""
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .white)
            let gotit: String = NSLocalizedString("Verifying, please wait...", comment: "Verify")
            self.gotit.stringValue = gotit
            self.working.startAnimation(nil)
            if let arguments = self.configurations?.arguments4verify(index: index) {
                self.outputprocess = OutputProcess()
                self.outputprocess?.addlinefromoutput(str: "*** Verify ***")
                self.verifyandchanged(arguments: arguments)
            }
        }
    }

    @IBAction func changed(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        if let index = self.index() {
            self.estimatedindex = index
            self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: index, display: .restore).displayrsyncpath ?? ""
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .white)
            let gotit: String = NSLocalizedString("Computing changed, please wait...", comment: "Verify")
            self.gotit.stringValue = gotit
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
        _ = InterruptProcess()
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
            self.gotremoteinfo = false
            self.complete = false
            let datelastbackup = self.configurations?.getConfigurations()[self.index()!].dateRun ?? ""
            if datelastbackup.isEmpty == false {
                let date = datelastbackup.en_us_date_from_string()
                self.datelastbackup.stringValue = NSLocalizedString("Date last synchronize:", comment: "Remote Info")
                    + " " + date.localized_string_from_date()
            } else {
                self.datelastbackup.stringValue = NSLocalizedString("Date last synchronize:", comment: "Remote Info")
            }
            let numberlastbackup = self.configurations?.getConfigurations()[self.index()!].dayssincelastbackup ?? ""
            self.dayslastbackup.stringValue = self.dayssince + " " + numberlastbackup
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
                self.resetinfo()
                return false
            }
            guard self.connected(config: config) == true else {
                self.gotit.textColor = setcolor(nsviewcontroller: self, color: .red)
                let dontgotit: String = NSLocalizedString("Seems not to be connected...", comment: "Verify")
                self.gotit.stringValue = dontgotit
                self.resetinfo()
                return false
            }
            guard self.index() != self.lastindex ?? -1 else { return false }
            guard self.estimatedindex ?? -1 != index else { return false }
        } else {
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
            let task: String = NSLocalizedString("Please select a task in Synchronize ...", comment: "Verify")
            self.gotit.stringValue = task
            self.outputprocess = nil
            self.resetinfo()
            globalMainQueue.async { () -> Void in
                self.outputtable.reloadData()
            }
            guard self.index() != nil else { return false }
        }
        self.gotit.stringValue = ""
        return true
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.lastindex = self.index()
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
        ViewControllerReference.shared.process = nil
        if self.gotremoteinfo == false {
            if self.complete == false {
                self.publishnumbers(outputprocess: self.outputprocess, local: true)
            } else {
                self.gotremoteinfo = true
                self.publishnumbers(outputprocess: self.outputprocess, local: false)
            }
            if let index = self.index() {
                if self.complete == false {
                    self.complete = true
                    self.outputprocess = OutputProcess()
                    self.estimateremoteinfo(index: index, local: false)
                }
            }
            globalMainQueue.async { () -> Void in
                self.outputtable.reloadData()
            }
        } else {
            self.working.stopAnimation(nil)
            let gotit: String = NSLocalizedString("Completed ...", comment: "Verify")
            self.gotit.stringValue = gotit
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
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
