//
//  ViewControllerQuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

protocol OpenQuickBackup: class {
    func openquickbackup()
}

protocol EnableQuicbackupButton: class {
    func enablequickbackupbutton()
}

class ViewControllerRemoteInfo: NSViewController, SetDismisser, AbortTask {

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var executebutton: NSButton!
    @IBOutlet weak var abortbutton: NSButton!
    @IBOutlet weak var count: NSTextField!
    @IBOutlet weak var selectalltaskswithfilestobackupbutton: NSButton!

    // remote info tasks
    private var remoteinfotask: RemoteInfoTaskWorkQueue?
    weak var remoteinfotaskDelegate: SetRemoteInfo?
    var selected: Bool = false
    var loaded: Bool = false
    var diddissappear: Bool = false

    @IBAction func execute(_ sender: NSButton) {
        if let backup = self.dobackups() {
            if backup.count > 0 {
                self.remoteinfotask?.setbackuplist(list: backup)
                let openDelegate: OpenQuickBackup?
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
                openDelegate?.openquickbackup()
            }
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Either abort or close
    @IBAction func abort(_ sender: NSButton) {
        if self.remoteinfotask?.stackoftasktobeestimated != nil {
            self.abort()
            self.remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: nil)
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func selectalltaskswithfilestobackup(_ sender: NSButton) {
        self.remoteinfotask?.selectalltaskswithfilestobackup(deselect: self.selected)
        if self.selected == true {
            self.selected = false
        } else {
            self.selected = true
        }
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcremoteinfo, nsviewcontroller: self)
        self.remoteinfotaskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        if let remoteinfotask = self.remoteinfotaskDelegate?.getremoteinfo() {
            self.remoteinfotask = remoteinfotask
            self.loaded = true
            self.progress.isHidden = true
        } else {
            self.remoteinfotask = RemoteInfoTaskWorkQueue(inbatch: false)
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
            return "Loaded cached data..."
        } else {
            let max = self.remoteinfotask?.maxnumber ?? 0
            return "Number of tasks to estimate: " + String(describing: max)
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

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let column = myTableViewFromNotification.selectedColumn
        if column == 0 {
            self.remoteinfotask?.sortbystrings(sort: .localCatalog)
        } else if column == 2 {
            self.remoteinfotask?.sortbystrings(sort: .offsiteCatalog)
        } else if column == 3 {
            self.remoteinfotask?.sortbystrings(sort: .offsiteServer)
        } else {
            return
        }
        self.reloadtabledata()
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
        let rest = self.remoteinfotask?.count ?? 0
        let max = self.remoteinfotask?.maxnumber ?? 0
        self.progress.doubleValue = Double(max - rest)
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
            var select: Int = (self.remoteinfotask?.records![row].value(forKey: "select") as? Int)!
            if select == 0 { select = 1 } else if select == 1 { select = 0 }
            self.remoteinfotask?.records![row].setValue(select, forKey: "select")
        }
        self.enableexecutebutton()
    }
}

extension ViewControllerRemoteInfo: Reloadandrefresh {

    // Updates tableview according to progress of batch
    func reloadtabledata() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerRemoteInfo: UpdateProgress {
    func processTermination() {
        self.reloadtabledata()
        self.updateProgressbar()
        if self.remoteinfotask?.stackoftasktobeestimated == nil {
            self.progress.stopAnimation(nil)
            self.progress.isHidden = true
            self.count.stringValue = "Completed"
            self.count.textColor = .green
            self.remoteinfotask?.selectalltaskswithfilestobackup(deselect: self.selected)
            self.selected = true
            self.selectalltaskswithfilestobackupbutton.isEnabled = true
        }
    }

    func fileHandler() {
        // nothing
    }
}

extension ViewControllerRemoteInfo: StartStopProgressIndicator {
    func start() {
        // self.initiateProgressbar()
    }

    func stop() {
        self.progress.stopAnimation(nil)
    }

    func complete() {
        // nothing
    }
}

extension ViewControllerRemoteInfo: EnableQuicbackupButton {
    func enablequickbackupbutton() {
        self.enableexecutebutton()
    }
}
