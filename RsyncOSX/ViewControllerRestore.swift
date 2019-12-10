//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerRestore: NSViewController, SetConfigurations, Abort, Connected, Setcolor, VcMain, Checkforrsync {
    @IBOutlet var restoretable: NSTableView!
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var gotit: NSTextField!

    @IBOutlet var transferredNumber: NSTextField!
    @IBOutlet var transferredNumberSizebytes: NSTextField!
    @IBOutlet var newfiles: NSTextField!
    @IBOutlet var deletefiles: NSTextField!
    @IBOutlet var totalNumber: NSTextField!
    @IBOutlet var totalDirs: NSTextField!
    @IBOutlet var totalNumberSizebytes: NSTextField!
    @IBOutlet var restorebutton: NSButton!
    @IBOutlet var tmprestore: NSTextField!
    @IBOutlet var selecttmptorestore: NSButton!
    @IBOutlet var estimatebutton: NSButton!

    var index: Int?
    var maxcount: Int = 0
    var outputprocess: OutputProcess?
    var diddissappear: Bool = false
    weak var sendprocess: SendProcessreference?

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

    // Abort button
    @IBAction func abort(_: NSButton) {
        self.working.stopAnimation(nil)
        self.estimatebutton.isEnabled = true
        self.restorebutton.isEnabled = false
        self.abort()
    }

    @IBAction func restore(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        let question: String = NSLocalizedString("Do you REALLY want to start a RESTORE ?", comment: "Restore")
        let text: String = NSLocalizedString("Cancel or Restore", comment: "Restore")
        let dialog: String = NSLocalizedString("Restore", comment: "Restore")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
        if answer {
            if let index = self.index {
                self.gotit.textColor = setcolor(nsviewcontroller: self, color: .white)
                let gotit: String = NSLocalizedString("Executing restore...", comment: "Restore")
                self.gotit.stringValue = gotit
                self.gotit.isHidden = false
                self.restorebutton.isEnabled = false
                self.outputprocess = OutputProcess()
                globalMainQueue.async { () -> Void in
                    self.presentAsSheet(self.viewControllerProgress!)
                }
                switch self.selecttmptorestore.state {
                case .on:
                    _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: false,
                                    tmprestore: true, updateprogress: self)
                case .off:
                    _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: false,
                                    tmprestore: false, updateprogress: self)
                default:
                    return
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.restoretable.delegate = self
        self.restoretable.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcrestore, nsviewcontroller: self)
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.gotit.isHidden = true
        guard self.diddissappear == false else { return }
        self.restorebutton.isEnabled = false
        self.estimatebutton.isEnabled = false
        self.settmp()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func settmp() {
        let setuserconfig: String = NSLocalizedString(" ... set in User configuration ...", comment: "Restore")
        self.tmprestore.stringValue = ViewControllerReference.shared.restorePath ?? setuserconfig
        if (ViewControllerReference.shared.restorePath ?? "").isEmpty == true {
            self.selecttmptorestore.state = .off
        } else {
            self.selecttmptorestore.state = .on
        }
    }

    private func setNumbers(outputprocess: OutputProcess?) {
        globalMainQueue.async { () -> Void in
            let infotask = RemoteinfonumbersOnetask(outputprocess: outputprocess)
            self.transferredNumber.stringValue = infotask.transferredNumber!
            self.transferredNumberSizebytes.stringValue = infotask.transferredNumberSizebytes!
            self.totalNumber.stringValue = infotask.totalNumber!
            self.totalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
            self.totalDirs.stringValue = infotask.totalDirs!
            self.newfiles.stringValue = infotask.newfiles!
            self.deletefiles.stringValue = infotask.deletefiles!
            self.working.stopAnimation(nil)
            self.restorebutton.isEnabled = true
            self.gotit.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            let gotit: String = NSLocalizedString("Got it...", comment: "Restore")
            self.gotit.stringValue = gotit
            self.gotit.isHidden = false
        }
    }

    @IBAction func prepareforrestore(_: NSButton) {
        if let index = self.index {
            if self.connected(config: self.configurations!.getConfigurations()[index]) == true,
                self.configurations!.getConfigurations()[index].task != ViewControllerReference.shared.syncremote {
                self.gotit.textColor = setcolor(nsviewcontroller: self, color: .white)
                let gotit: String = NSLocalizedString("Getting info, please wait...", comment: "Restore")
                self.gotit.stringValue = gotit
                self.gotit.isHidden = false
                self.estimatebutton.isEnabled = false
                self.working.startAnimation(nil)
                self.outputprocess = OutputProcess()
                self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
                if ViewControllerReference.shared.restorePath != nil && self.selecttmptorestore.state == .on {
                    _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: true,
                                    tmprestore: true, updateprogress: self)
                } else {
                    self.selecttmptorestore.state = .off
                    _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: true,
                                    tmprestore: false, updateprogress: self)
                }
            } else {
                self.gotit.stringValue = NSLocalizedString("Seems not to be connected...", comment: "Remote Info")
                self.gotit.textColor = self.setcolor(nsviewcontroller: self, color: .red)
                self.gotit.isHidden = false
            }
        }
    }

    @IBAction func toggletmprestore(_: NSButton) {
        self.estimatebutton.isEnabled = true
        self.restorebutton.isEnabled = false
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.estimatebutton.isEnabled = true
            self.index = index
        } else {
            self.estimatebutton.isEnabled = false
            self.index = nil
        }
        self.restorebutton.isEnabled = false
    }
}

extension ViewControllerRestore: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
    }
}

extension ViewControllerRestore: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.configurations!.getConfigurationsDataSourceSynchronize()!.count else { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSourceSynchronize()![row]
        switch tableColumn!.identifier.rawValue {
        case "offsiteServerCellID":
            if (object[tableColumn!.identifier] as? String)!.isEmpty {
                return "localhost"
            } else {
                return object[tableColumn!.identifier] as? String
            }
        default:
            return object[tableColumn!.identifier] as? String
        }
    }
}

extension ViewControllerRestore: UpdateProgress {
    func processTermination() {
        self.setNumbers(outputprocess: self.outputprocess)
        self.maxcount = self.outputprocess?.getMaxcount() ?? 0
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.processTermination()
        }
    }

    func fileHandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.fileHandler()
        }
    }
}

extension ViewControllerRestore: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerRestore: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        globalMainQueue.async { () -> Void in
            self.restoretable.reloadData()
        }
    }
}

extension ViewControllerRestore: Count {
    func maxCount() -> Int {
        return self.maxcount
    }

    func inprogressCount() -> Int {
        return self.outputprocess?.count() ?? 0
    }
}

extension ViewControllerRestore: TemporaryRestorePath {
    func temporaryrestorepath() {
        self.settmp()
    }
}
