//
//  ViewControllerQuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity

import Foundation
import Cocoa

protocol OpenQuickBackup: class {
    func openquickbackup()
}

class ViewControllerRemoteInfo: NSViewController, SetDismisser, Abort, Setcolor {

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var executebutton: NSButton!
    @IBOutlet weak var abortbutton: NSButton!
    @IBOutlet weak var count: NSTextField!
    @IBOutlet weak var selectalltaskswithfilestobackupbutton: NSButton!

    // remote info tasks
    private var remoteinfotask: RemoteinfoEstimation?
    weak var remoteinfotaskDelegate: SetRemoteInfo?
    var selected: Bool = false
    var loaded: Bool = false
    var diddissappear: Bool = false

    @IBAction func execute(_ sender: NSButton) {
        if let backup = self.dobackups() {
            if backup.count > 0 {
                self.remoteinfotask?.setbackuplist(list: backup)
                weak var openDelegate: OpenQuickBackup?
                if (self.presentingViewController as? ViewControllertabMain) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
                } else if (self.presentingViewController as? ViewControllertabSchedule) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
                } else if (self.presentingViewController as? ViewControllerNewConfigurations) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
                } else if (self.presentingViewController as? ViewControllerCopyFiles) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
                } else if (self.presentingViewController as? ViewControllerSsh) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
                } else if (self.presentingViewController as? ViewControllerVerify) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcverify) as? ViewControllerVerify
                } else if (self.presentingViewController as? ViewControllerLoggData) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
                } else if (self.presentingViewController as? ViewControllerSnapshots) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
                }
                openDelegate?.openquickbackup()
            }
        }
        self.closeview()
    }

    // Either abort or close
    @IBAction func abort(_ sender: NSButton) {
        if self.remoteinfotask?.stackoftasktobeestimated?.count ?? 0 > 0 {
            self.abort()
            self.remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: nil)
        }
         self.closeview()
    }

    private func closeview() {
        if (self.presentingViewController as? ViewControllertabMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presentingViewController as? ViewControllertabSchedule) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabschedule)
        } else if (self.presentingViewController as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcnewconfigurations)
        } else if (self.presentingViewController as? ViewControllerCopyFiles) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        } else if (self.presentingViewController as? ViewControllerSnapshots) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        } else if (self.presentingViewController as? ViewControllerSsh) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcssh)
        } else if (self.presentingViewController as? ViewControllerVerify) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcverify)
        } else if (self.presentingViewController as? ViewControllerLoggData) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        }
    }

    @IBAction func selectalltaskswithfilestobackup(_ sender: NSButton) {
        self.remoteinfotask?.selectalltaskswithnumbers(deselect: self.selected)
        if self.selected == true {
            self.selected = false
        } else {
            self.selected = true
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        self.enableexecutebutton()
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcremoteinfo, nsviewcontroller: self)
        ViewControllerReference.shared.activetab = .vcremoteinfo
        self.remoteinfotaskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        if let remoteinfotask = self.remoteinfotaskDelegate?.getremoteinfo() {
            self.remoteinfotask = remoteinfotask
            self.loaded = true
            self.progress.isHidden = true
        } else {
            self.remoteinfotask = RemoteinfoEstimation()
            self.remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: self.remoteinfotask)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        self.count.stringValue = self.number()
        self.enableexecutebutton()
        if self.loaded {
            self.selectalltaskswithfilestobackupbutton.isEnabled = true
        } else {
            self.initiateProgressbar()
            self.selectalltaskswithfilestobackupbutton.isEnabled = false
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func number() -> String {
        if self.loaded {
            return NSLocalizedString("Loaded cached data...", comment: "Remote info")
        } else {
            let max = self.remoteinfotask?.maxnumber ?? 0
            return NSLocalizedString("Number of tasks to estimate:", comment: "Remote info") + " " + String(describing: max)
        }
    }

    private func dobackups() -> [NSMutableDictionary]? {
        let backup = self.remoteinfotask?.records?.filter({$0.value( forKey: "select") as? Int == 1})
        return backup
    }

    private func enableexecutebutton() {
        if let backup = self.dobackups() {
            if backup.count > 0 {
                self.executebutton.isEnabled = true
            } else {
                self.executebutton.isEnabled = false
            }
        } else {
            self.executebutton.isEnabled = false
        }
    }

    // Progress bars
    private func initiateProgressbar() {
        if let calculatedNumberOfFiles = self.remoteinfotask?.maxnumber {
            self.progress.maxValue = Double(calculatedNumberOfFiles)
        }
        self.progress.minValue = 0
        self.progress.doubleValue = 0
        self.progress.startAnimation(self)
    }

    private func updateProgressbar() {
         globalMainQueue.async(execute: { () -> Void in
            let rest = self.remoteinfotask?.count ?? 0
            let max = self.remoteinfotask?.maxnumber ?? 0
            self.progress.doubleValue = Double(max - rest)
        })
    }
}

extension ViewControllerRemoteInfo: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.remoteinfotask?.records?.count ?? 0
    }
}

extension ViewControllerRemoteInfo: NSTableViewDelegate, Attributedestring {
    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.remoteinfotask?.records != nil else { return nil }
        guard row < (self.remoteinfotask!.records?.count)! else { return nil }
        let object: NSDictionary = (self.remoteinfotask?.records?[row])!
        switch tableColumn!.identifier.rawValue {
        case "transferredNumber":
            let celltext = object[tableColumn!.identifier] as? String
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case "transferredNumberSizebytes":
            let celltext = object[tableColumn!.identifier] as? String
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case "newfiles":
            let celltext = object[tableColumn!.identifier] as? String
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case "deletefiles":
            let celltext = object[tableColumn!.identifier] as? String
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case "select":
            return object[tableColumn!.identifier] as? Int
        default:
            return object[tableColumn!.identifier] as? String
        }
    }

    // Toggling selection
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard  self.remoteinfotask?.records != nil else { return }
        if tableColumn!.identifier.rawValue == "select" {
            var select: Int = self.remoteinfotask?.records![row].value(forKey: "select") as? Int ?? 0
            if select == 0 { select = 1 } else if select == 1 { select = 0 }
            self.remoteinfotask?.records![row].setValue(select, forKey: "select")
        }
        self.enableexecutebutton()
    }
}

extension ViewControllerRemoteInfo: UpdateProgress {
    func processTermination() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        self.updateProgressbar()
    }

    func fileHandler() {
        //
    }
}

extension ViewControllerRemoteInfo: StartStopProgressIndicator {
    func start() {
        // self.initiateProgressbar()
    }

    func stop() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        self.progress.stopAnimation(nil)
        self.progress.isHidden = true
        self.count.stringValue = NSLocalizedString("Completed", comment: "Remote info")
        self.count.textColor = setcolor(nsviewcontroller: self, color: .green)
        self.selected = true
        self.selectalltaskswithfilestobackupbutton.isEnabled = true
        self.enableexecutebutton()
    }

    func complete() {
        // nothing
    }
}
