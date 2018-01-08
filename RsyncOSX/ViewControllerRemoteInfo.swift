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

class ViewControllerRemoteInfo: NSViewController, SetDismisser, AbortTask {

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var abortbutton: NSButton!
    @IBOutlet weak var count: NSTextField!
    // remote info tasks
    private var remoteinfotask: RemoteInfoTaskWorkQueue?
    weak var remoteinfotaskDelegate: SetRemoteInfo?

    // Either abort or close
    @IBAction func abort(_ sender: NSButton) {
        if self.remoteinfotask?.stackoftasktobeestimated != nil {
            self.abort()
        }
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

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcremoteinfo, nsviewcontroller: self)
        self.remoteinfotaskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.remoteinfotask = RemoteInfoTaskWorkQueue()
        self.remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: self.remoteinfotask)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        self.count.stringValue = self.number()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.working.stopAnimation(nil)
        self.remoteinfotask = nil
    }

    private func number() -> String {
        let max = self.remoteinfotask?.maxnumber ?? 0
        let rest = self.remoteinfotask?.count ?? 0
        let num = String(describing: max - rest) + " of " + String(describing: max)
        return "Estimating " + num
    }

    private func dobackups() -> [NSMutableDictionary]? {
        let backup = self.remoteinfotask?.records?.filter({$0.value(forKey: "backup") as? Int == 1})
        return backup
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        // guard self.remoteinfotask?.maxnumber ?? 0 == self.remoteinfotask?.count ?? 0 else { return }
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
        case "backup":
            return object[tableColumn!.identifier] as? Int
        default:
            return object[tableColumn!.identifier] as? String
        }
    }

    // Toggling selection
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard  self.remoteinfotask?.records != nil else { return }
        if tableColumn!.identifier.rawValue == "backup" {
            var select: Int = (self.remoteinfotask?.records![row].value(forKey: "backup") as? Int)!
            if select == 0 { select = 1 } else if select == 1 { select = 0 }
            self.remoteinfotask?.records![row].setValue(select, forKey: "backup")
        }
    }
}

extension ViewControllerRemoteInfo: Reloadandrefresh {

    // Updates tableview according to progress of batch
    func reloadtabledata() {
        self.count.stringValue = self.number()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerRemoteInfo: UpdateProgress {
    func processTermination() {
        self.reloadtabledata()
        if self.remoteinfotask?.stackoftasktobeestimated == nil {
            self.working.stopAnimation(nil)
        }
    }

    func fileHandler() {
        // nothing
    }
}

extension ViewControllerRemoteInfo: StartStopProgressIndicator {
    func start() {
        self.working.startAnimation(nil)
    }

    func stop() {
        self.working.stopAnimation(nil)
    }

    func complete() {
        // nothing
    }
}
