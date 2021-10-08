//
//  ViewControllerLoggData.swift
//  RsyncOSX
//  The ViewController is the logview
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity

import Cocoa
import Foundation

class ViewControllerLoggData: NSViewController, SetConfigurations, SetSchedules, Delay, Index, Connected, VcMain, Checkforrsync, Setcolor, Help {
    private var scheduleloggdata: ScheduleLoggData?
    private var snapshotscheduleloggdata: Snapshotlogsandcatalogs?
    private var filterby: Sortandfilter?
    private var index: Int?
    private var column: Int = 0
    private var sortascending: Bool = true
    // Send messages to the sidebar
    weak var sidebaractionsDelegate: Sidebaractions?

    @IBOutlet var scheduletable: NSTableView!
    @IBOutlet var search: NSSearchField!
    @IBOutlet var numberOflogfiles: NSTextField!
    @IBOutlet var selectedrows: NSTextField!
    @IBOutlet var info: NSTextField!
    @IBOutlet var working: NSProgressIndicator!

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        presentAsModalWindow(viewControllerProfile!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        help()
    }

    @IBAction func selectlogs(_: NSButton) {
        guard scheduleloggdata?.loggrecords != nil else { return }
        for i in 0 ..< (scheduleloggdata?.loggrecords?.count ?? 0) {
            if (scheduleloggdata?.loggrecords?[i].delete ?? 0) == 1 {
                scheduleloggdata?.loggrecords?[i].delete = 0
            } else {
                scheduleloggdata?.loggrecords?[i].delete = 1
            }
        }
        globalMainQueue.async { () -> Void in
            self.selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg") + " " + self.selectednumber()
            self.scheduletable.reloadData()
        }
    }

    // Sidebar delete
    func deletealllogs() {
        guard selectednumber() != "0" else { return }
        let question: String = NSLocalizedString("Delete", comment: "Logg")
        let text: String = NSLocalizedString("Cancel or Delete", comment: "Logg")
        let dialog: String = NSLocalizedString("Delete", comment: "Logg")
        let answer = Alerts.dialogOrCancel(question: question + " " + selectednumber() + " logrecords?", text: text, dialog: dialog)
        if answer {
            deselectrow()
            schedules?.deleteselectedrows(scheduleloggdata: scheduleloggdata)
            scheduleloggdata = nil
            snapshotscheduleloggdata = nil
            reloadtabledata()
        }
    }

    private func selectednumber() -> String {
        if let number = scheduleloggdata?.loggrecords?.filter({ $0.delete == 1 }).count {
            return String(number)
        } else {
            return "0"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scheduletable.delegate = self
        scheduletable.dataSource = self
        search.delegate = self
        SharedReference.shared.setvcref(viewcontroller: .vcloggdata, nsviewcontroller: self)
        working.usesThreadedAnimation = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        sidebaractionsDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        sidebaractionsDelegate?.sidebaractions(action: .logsviewbuttons)
        info.textColor = setcolor(nsviewcontroller: self, color: .green)
        index = index()
        if let index = index {
            let hiddenID = configurations?.gethiddenID(index: index) ?? -1
            guard hiddenID > -1 else { return }
            if let config = configurations?.getConfigurations()?[index] {
                scheduleloggdata = ScheduleLoggData(hiddenID: hiddenID)
                // If task is snapshot get snapshotlogs
                if connected(config: config),
                   config.task == SharedReference.shared.snapshot
                {
                    working.startAnimation(nil)
                    snapshotscheduleloggdata = Snapshotlogsandcatalogs(config: config)
                }
                info.stringValue = Infologgdata().info(num: 1)
            }
        } else {
            info.stringValue = Infologgdata().info(num: 0)
            scheduleloggdata = ScheduleLoggData(hiddenID: nil)
        }
        globalMainQueue.async { () -> Void in
            self.scheduletable.reloadData()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        scheduleloggdata = nil
        snapshotscheduleloggdata = nil
        working.stopAnimation(nil)
    }

    private func deselectrow() {
        guard index != nil else { return }
        scheduletable.deselectRow(index!)
        index = index()
    }

    func sortbycolumn() {
        var comp: (String, String) -> Bool
        var comp2: (Date, Date) -> Bool
        if sortascending == true {
            comp = (<)
            comp2 = (<)
        } else {
            comp = (>)
            comp2 = (>)
        }
        switch column {
        case 0:
            scheduleloggdata?.loggrecords = scheduleloggdata?.loggrecords?.sorted(by: \.task, using: comp)
        case 2:
            scheduleloggdata?.loggrecords = scheduleloggdata?.loggrecords?.sorted(by: \.backupID, using: comp)
        case 3:
            scheduleloggdata?.loggrecords = scheduleloggdata?.loggrecords?.sorted(by: \.localCatalog, using: comp)
        case 4:
            scheduleloggdata?.loggrecords = scheduleloggdata?.loggrecords?.sorted(by: \.remoteCatalog, using: comp)
        case 5:
            scheduleloggdata?.loggrecords = scheduleloggdata?.loggrecords?.sorted(by: \.offsiteServer, using: comp)
        case 6:
            scheduleloggdata?.loggrecords = scheduleloggdata?.loggrecords?.sorted(by: \.date, using: comp2)
        default:
            return
        }
        globalMainQueue.async { () -> Void in
            self.scheduletable.reloadData()
        }
    }

    func marklogsfromsnapshots() {
        guard SharedReference.shared.process == nil else { return }
        // Merged log records for snapshots based on real snapshot catalogs
        guard snapshotscheduleloggdata?.logrecordssnapshot?.count ?? 0 > 0 else { return }
        // All log records
        guard scheduleloggdata?.loggrecords?.count ?? 0 > 0 else { return }
        for i in 0 ..< (scheduleloggdata?.loggrecords?.count ?? 0) {
            scheduleloggdata?.loggrecords?[i].delete = 1
            if let logrecordssnapshot = snapshotscheduleloggdata?.logrecordssnapshot {
                if logrecordssnapshot.contains(where: { record in
                    if record.resultExecuted == self.scheduleloggdata?.loggrecords?[i].resultExecuted {
                        self.scheduleloggdata?.loggrecords?[i].delete = 0
                        return true
                    }
                    return false
                }) {}
            }
        }
        globalMainQueue.async { () -> Void in
            self.scheduletable.reloadData()
        }
    }
}

extension ViewControllerLoggData: NSSearchFieldDelegate {
    func controlTextDidChange(_: Notification) {
        delayWithSeconds(0.25) {
            let filterstring = self.search.stringValue
            if filterstring.isEmpty {
                self.reloadtabledata()
            } else {
                self.scheduleloggdata?.filter(search: filterstring)
                globalMainQueue.async { () -> Void in
                    self.scheduletable.reloadData()
                }
            }
        }
    }

    func searchFieldDidEndSearching(_: NSSearchField) {
        index = nil
        reloadtabledata()
    }
}

extension ViewControllerLoggData: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        if scheduleloggdata == nil {
            numberOflogfiles.stringValue = NSLocalizedString("Number of logs:", comment: "Logg")
            selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg") + " 0"
            return 0
        } else {
            numberOflogfiles.stringValue = NSLocalizedString("Number of logs:", comment: "Logg")
                + " " + String(scheduleloggdata?.loggrecords?.count ?? 0)
            selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg")
                + " " + selectednumber()
            return scheduleloggdata?.loggrecords?.count ?? 0
        }
    }
}

extension ViewControllerLoggData: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let tableColumn = tableColumn {
            guard row < (scheduleloggdata?.loggrecords?.count ?? 0) else { return nil }
            if let object = scheduleloggdata?.loggrecords?[row] {
                switch tableColumn.identifier.rawValue {
                case DictionaryStrings.deleteCellID.rawValue:
                    return object.delete
                case DictionaryStrings.selectCellID.rawValue:
                    return object.selectCellID
                case DictionaryStrings.task.rawValue:
                    return object.task
                case DictionaryStrings.backupID.rawValue:
                    return object.backupID
                case DictionaryStrings.localCatalog.rawValue:
                    return object.localCatalog
                case DictionaryStrings.remoteCatalog.rawValue:
                    return object.remoteCatalog
                case DictionaryStrings.dateExecuted.rawValue:
                    return object.dateExecuted
                case DictionaryStrings.resultExecuted.rawValue:
                    return object.resultExecuted
                case DictionaryStrings.offsiteServer.rawValue:
                    return object.offsiteServer
                default:
                    return nil
                }
            }
            return nil
        }
        return nil
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let column = myTableViewFromNotification.selectedColumn
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
        } else {
            index = nil
        }
        self.column = column
        sortbycolumn()
    }

    func tableView(_: NSTableView, setObjectValue _: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if let tableColumn = tableColumn {
            if tableColumn.identifier.rawValue == DictionaryStrings.deleteCellID.rawValue {
                var delete: Int = scheduleloggdata?.loggrecords?[row].delete ?? 0
                if delete == 0 { delete = 1 } else if delete == 1 { delete = 0 }
                switch tableColumn.identifier.rawValue {
                case DictionaryStrings.deleteCellID.rawValue:
                    scheduleloggdata?.loggrecords?[row].delete = delete
                default:
                    break
                }
                globalMainQueue.async { () -> Void in
                    self.selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg") + " " + self.selectednumber()
                }
            }
        }
    }
}

extension ViewControllerLoggData: Reloadandrefresh {
    func reloadtabledata() {
        working.stopAnimation(nil)
        if let index = index {
            let hiddenID = configurations?.gethiddenID(index: index) ?? -1
            guard hiddenID > -1 else { return }
            if let config = configurations?.getConfigurations()?[index] {
                scheduleloggdata = ScheduleLoggData(hiddenID: hiddenID)
                if connected(config: config),
                   snapshotscheduleloggdata == nil
                {
                    if config.task == SharedReference.shared.snapshot { working.startAnimation(nil) }
                    snapshotscheduleloggdata = Snapshotlogsandcatalogs(config: config)
                }
            }
        } else {
            scheduleloggdata = ScheduleLoggData(hiddenID: nil)
        }
        globalMainQueue.async { () -> Void in
            self.scheduletable.reloadData()
        }
    }
}

extension ViewControllerLoggData: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerLoggData: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        dismiss(viewcontroller)
    }
}

extension ViewControllerLoggData: NewProfile {
    func newprofile(profile _: String?, selectedindex _: Int?) {
        reloadtabledata()
    }

    func reloadprofilepopupbutton() {}
}

extension ViewControllerLoggData: Sidebarbuttonactions {
    func sidebarbuttonactions(action: Sidebaractionsmessages) {
        switch action {
        case .Snap:
            marklogsfromsnapshots()
        case .Delete:
            deletealllogs()
        default:
            return
        }
    }
}
