//
//  ViewControllerLoggData.swift
//  RsyncOSX
//  The ViewController is the logview
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerLoggData: NSViewController, SetConfigurations, SetSchedules, Delay, Index, Connected, VcExecute {

    private var scheduleloggdata: ScheduleLoggData?
    private var snapshotsloggdata: SnapshotsLoggData?
    private var filterby: Sortandfilter?
    private var index: Int?
    private var sortedascending: Bool = true

    @IBOutlet weak var scheduletable: NSTableView!
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var numberOflogfiles: NSTextField!
    @IBOutlet weak var sortdirection: NSButton!
    @IBOutlet weak var selectedrows: NSTextField!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var selectbutton: NSButton!

    @IBAction func totinfo(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        self.configurations!.processtermination = .remoteinfotask
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        })
    }

    @IBAction func quickbackup(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_ sender: NSButton) {
        self.configurations!.processtermination = .automaticbackup
        self.configurations?.remoteinfotaskworkqueue = RemoteInfoTaskWorkQueue(inbatch: false)
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func sortdirection(_ sender: NSButton) {
        if self.sortedascending == true {
            self.sortedascending = false
            self.sortdirection.image = #imageLiteral(resourceName: "down")
        } else {
            self.sortedascending = true
            self.sortdirection.image = #imageLiteral(resourceName: "up")
        }
        guard self.filterby != nil else { return }
        switch self.filterby! {
        case .executedate:
            self.scheduleloggdata?.loggdata = self.scheduleloggdata!.sortbydate(notsortedlist: self.scheduleloggdata?.loggdata, sortdirection: self.sortedascending)
        default:
            self.scheduleloggdata?.loggdata = self.scheduleloggdata!.sortbystring(notsortedlist: self.scheduleloggdata?.loggdata, sortby: self.filterby!, sortdirection: self.sortedascending)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
    }

    @IBAction func selectlogs(_ sender: NSButton) {
        guard self.scheduleloggdata!.loggdata != nil else { return }
        for i in 0 ..< self.scheduleloggdata!.loggdata!.count {
            if self.scheduleloggdata!.loggdata![i].value(forKey: "deleteCellID") as? Int == 1 {
                self.scheduleloggdata!.loggdata![i].setValue(0, forKey: "deleteCellID")
            } else {
                self.scheduleloggdata!.loggdata![i].setValue(1, forKey: "deleteCellID")
            }
        }
        globalMainQueue.async(execute: { () -> Void in
            self.selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg") + " " + self.selectednumber()
            self.scheduletable.reloadData()
        })
    }

    @IBAction func deletealllogs(_ sender: NSButton) {
        let question: String = NSLocalizedString("Delete", comment: "Logg")
        let text: String = NSLocalizedString("Cancel or Delete", comment: "Logg")
        let dialog: String = NSLocalizedString("Delete", comment: "Logg")
        let answer = Alerts.dialogOrCancel(question: question + " " + self.selectednumber() + " logrecords?", text: text, dialog: dialog)
        if answer {
            self.deselectrow()
            self.schedules?.deleteselectedrows(scheduleloggdata: self.scheduleloggdata)
        }
    }

    private func selectednumber() -> String {
        let number = self.scheduleloggdata!.loggdata!.filter({($0.value(forKey: "deleteCellID") as? Int)! == 1}).count
        return String(number)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        self.search.delegate = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcloggdata, nsviewcontroller: self)
        self.sortdirection.image = #imageLiteral(resourceName: "up")
        self.sortedascending = true
        self.working.usesThreadedAnimation = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        ViewControllerReference.shared.activetab = .vcloggdata
        self.index = self.index()
        if let index = self.index {
            let hiddenID = self.configurations?.gethiddenID(index: index) ?? -1
            guard hiddenID > -1 else { return }
            let config = self.configurations?.getConfigurations()[index]
            self.scheduleloggdata = ScheduleLoggData(hiddenID: hiddenID, sortascending: self.sortedascending)
            if self.connected(config: config!) {
                if config?.task == "snapshot" { self.working.startAnimation(nil) }
                self.snapshotsloggdata = SnapshotsLoggData(config: config!, insnapshot: false)
            }
            if self.indexfromwhere() == .vcsnapshot {
                self.info.stringValue = Infologgdata().info(num: 2)
            } else {
                self.info.stringValue = Infologgdata().info(num: 1)
            }
        } else {
            self.info.stringValue = Infologgdata().info(num: 0)
            self.scheduleloggdata = ScheduleLoggData(sortascending: self.sortedascending)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.scheduleloggdata = nil
        self.snapshotsloggdata = nil
        self.working.stopAnimation(nil)
        self.selectbutton.state = .off
    }

    private func deselectrow() {
        guard self.index != nil else { return }
        self.scheduletable.deselectRow(self.index!)
        self.index = self.index()
    }
}

extension ViewControllerLoggData: NSSearchFieldDelegate {

    func controlTextDidChange(_ obj: Notification) {
        self.delayWithSeconds(0.25) {
            let filterstring = self.search.stringValue
            self.selectbutton.state = .off
            if filterstring.isEmpty {
                self.reloadtabledata()
            } else {
                self.scheduleloggdata!.filter(search: filterstring, filterby: self.filterby)
                globalMainQueue.async(execute: { () -> Void in
                    self.scheduletable.reloadData()
                })
            }
        }
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.index = nil
        self.reloadtabledata()
        self.selectbutton.state = .off
    }

}

extension ViewControllerLoggData: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if self.scheduleloggdata == nil {
            self.numberOflogfiles.stringValue = NSLocalizedString("Number of logs:", comment: "Logg")
            self.selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg") + " 0"
            return 0
        } else {
            self.numberOflogfiles.stringValue = NSLocalizedString("Number of logs:", comment: "Logg")
                + " " + String(self.scheduleloggdata!.loggdata?.count ?? 0)
            self.selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg")
                + " " + self.selectednumber()
            return self.scheduleloggdata!.loggdata?.count ?? 0
        }
    }

}

extension ViewControllerLoggData: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.scheduleloggdata != nil else { return nil }
        guard row < self.scheduleloggdata!.loggdata!.count else { return nil }
        let object: NSDictionary = self.scheduleloggdata!.loggdata![row]
        if tableColumn!.identifier.rawValue == "deleteCellID" ||
            tableColumn!.identifier.rawValue == "snapCellID" {
            return object[tableColumn!.identifier] as? Int
        } else {
            return object[tableColumn!.identifier] as? String
        }
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
        }
        let column = myTableViewFromNotification.selectedColumn
        var sortbystring = true
        switch column {
        case 0:
             self.filterby = .task
        case 3:
            self.filterby = .backupid
        case 4:
            self.filterby = .localcatalog
        case 5:
            self.filterby = .remoteserver
        case 6:
            sortbystring = false
            self.filterby = .executedate
        default:
            return
        }
        if sortbystring {
            self.scheduleloggdata?.loggdata = self.scheduleloggdata!.sortbystring(notsortedlist: self.scheduleloggdata?.loggdata, sortby: self.filterby!, sortdirection: self.sortedascending)
        } else {
            self.scheduleloggdata?.loggdata = self.scheduleloggdata!.sortbydate(notsortedlist: self.scheduleloggdata?.loggdata, sortdirection: self.sortedascending)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if tableColumn!.identifier.rawValue == "deleteCellID" {
            var delete: Int = (self.scheduleloggdata?.loggdata![row].value(forKey: "deleteCellID") as? Int)!
            if delete == 0 { delete = 1 } else if delete == 1 { delete = 0 }
            switch tableColumn!.identifier.rawValue {
            case "deleteCellID":
                self.scheduleloggdata?.loggdata![row].setValue(delete, forKey: "deleteCellID")
            default:
                break
            }
            globalMainQueue.async(execute: { () -> Void in
                self.selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg") + " " + self.selectednumber()
            })
        }
    }
}

extension ViewControllerLoggData: Reloadandrefresh {

    func reloadtabledata() {
        if let index = self.index {
            let hiddenID = self.configurations?.gethiddenID(index: index) ?? -1
            guard hiddenID > -1 else { return }
            let config = self.configurations?.getConfigurations()[index]
            self.scheduleloggdata = ScheduleLoggData(hiddenID: hiddenID, sortascending: self.sortedascending)
            if self.connected(config: config!) {
                if config?.task == "snapshot" { self.working.startAnimation(nil) }
                self.snapshotsloggdata = SnapshotsLoggData(config: config!, insnapshot: false)
            }
        } else {
            self.scheduleloggdata = ScheduleLoggData(sortascending: self.sortedascending)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
    }
}

extension ViewControllerLoggData: UpdateProgress {
    func processTermination() {
        self.snapshotsloggdata?.processTermination()
        guard self.snapshotsloggdata?.outputprocess?.error == false else { return }
        self.scheduleloggdata?.intersect(snapshotaloggdata: self.snapshotsloggdata)
        self.working.stopAnimation(nil)
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
    }

    func fileHandler() {
        //
    }
}

extension ViewControllerLoggData: OpenQuickBackup {
    func openquickbackup() {
        self.configurations!.processtermination = .quicktask
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        })
    }
}
