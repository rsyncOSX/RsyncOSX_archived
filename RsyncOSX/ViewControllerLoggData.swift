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
    @IBOutlet var sortdirection: NSButton!
    @IBOutlet var selectedrows: NSTextField!
    @IBOutlet var info: NSTextField!
    @IBOutlet var working: NSProgressIndicator!

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerProfile!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    @IBAction func sortdirection(_: NSButton) {
        if self.sortascending == true {
            self.sortascending = false
            self.sortdirection.image = #imageLiteral(resourceName: "down")
        } else {
            self.sortascending = true
            self.sortdirection.image = #imageLiteral(resourceName: "up")
        }
        self.sortbycolumn()
    }

    @IBAction func selectlogs(_: NSButton) {
        guard self.scheduleloggdata?.loggrecords != nil else { return }
        for i in 0 ..< (self.scheduleloggdata?.loggrecords?.count ?? 0) {
            if (self.scheduleloggdata?.loggrecords?[i].delete ?? 0) == 1 {
                self.scheduleloggdata?.loggrecords?[i].delete = 0
            } else {
                self.scheduleloggdata?.loggrecords?[i].delete = 1
            }
        }
        globalMainQueue.async { () -> Void in
            self.selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg") + " " + self.selectednumber()
            self.scheduletable.reloadData()
        }
    }

    // Sidebar delete
    func deletealllogs() {
        guard self.selectednumber() != "0" else { return }
        let question: String = NSLocalizedString("Delete", comment: "Logg")
        let text: String = NSLocalizedString("Cancel or Delete", comment: "Logg")
        let dialog: String = NSLocalizedString("Delete", comment: "Logg")
        let answer = Alerts.dialogOrCancel(question: question + " " + self.selectednumber() + " logrecords?", text: text, dialog: dialog)
        if answer {
            self.deselectrow()
            self.schedules?.deleteselectedrows(scheduleloggdata: self.scheduleloggdata)
            self.scheduleloggdata = nil
            self.snapshotscheduleloggdata = nil
        }
    }

    private func selectednumber() -> String {
        if let number = self.scheduleloggdata?.loggrecords?.filter({ $0.delete == 1 }).count {
            return String(number)
        } else {
            return "0"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        self.search.delegate = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcloggdata, nsviewcontroller: self)
        self.sortdirection.image = #imageLiteral(resourceName: "up")
        self.working.usesThreadedAnimation = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.sidebaractionsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        self.sidebaractionsDelegate?.sidebaractions(action: .logsviewbuttons)
        self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
        self.index = self.index()
        if let index = self.index {
            let hiddenID = self.configurations?.gethiddenID(index: index) ?? -1
            guard hiddenID > -1 else { return }
            if let config = self.configurations?.getConfigurations()?[index] {
                self.scheduleloggdata = ScheduleLoggData(hiddenID: hiddenID)
                if self.connected(config: config),
                   config.task == ViewControllerReference.shared.snapshot
                {
                    self.working.startAnimation(nil)
                    self.snapshotscheduleloggdata = Snapshotlogsandcatalogs(config: config)
                }
                if self.indexfromwhere() == .vcsnapshot {
                    self.info.stringValue = Infologgdata().info(num: 2)
                } else {
                    self.info.stringValue = Infologgdata().info(num: 1)
                }
            }
        } else {
            self.info.stringValue = Infologgdata().info(num: 0)
            self.scheduleloggdata = ScheduleLoggData(hiddenID: nil)
        }
        globalMainQueue.async { () -> Void in
            self.scheduletable.reloadData()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.scheduleloggdata = nil
        self.snapshotscheduleloggdata = nil
        self.working.stopAnimation(nil)
    }

    private func deselectrow() {
        guard self.index != nil else { return }
        self.scheduletable.deselectRow(self.index!)
        self.index = self.index()
    }

    func sortbycolumn() {
        var comp: (String, String) -> Bool
        var comp2: (Date, Date) -> Bool
        if self.sortascending == true {
            comp = (<)
            comp2 = (<)
        } else {
            comp = (>)
            comp2 = (>)
        }
        switch self.column {
        case 0:
            self.scheduleloggdata?.loggrecords = self.scheduleloggdata?.loggrecords?.sorted(by: \.task, using: comp)
        case 2:
            self.scheduleloggdata?.loggrecords = self.scheduleloggdata?.loggrecords?.sorted(by: \.backupID, using: comp)
        case 3:
            self.scheduleloggdata?.loggrecords = self.scheduleloggdata?.loggrecords?.sorted(by: \.localCatalog, using: comp)
        case 4:
            self.scheduleloggdata?.loggrecords = self.scheduleloggdata?.loggrecords?.sorted(by: \.remoteCatalog, using: comp)
        case 5:
            self.scheduleloggdata?.loggrecords = self.scheduleloggdata?.loggrecords?.sorted(by: \.offsiteServer, using: comp)
        case 6:
            self.scheduleloggdata?.loggrecords = self.scheduleloggdata?.loggrecords?.sorted(by: \.date, using: comp2)
        default:
            return
        }
        globalMainQueue.async { () -> Void in
            self.scheduletable.reloadData()
        }
    }
}

extension ViewControllerLoggData: NSSearchFieldDelegate {
    func controlTextDidChange(_: Notification) {
        self.delayWithSeconds(0.25) {
            let filterstring = self.search.stringValue
            if filterstring.isEmpty {
                self.reloadtabledata()
            } else {
                self.scheduleloggdata?.filter(search: filterstring, filterby: self.filterby)
                globalMainQueue.async { () -> Void in
                    self.scheduletable.reloadData()
                }
            }
        }
    }

    func searchFieldDidEndSearching(_: NSSearchField) {
        self.index = nil
        self.reloadtabledata()
    }
}

extension ViewControllerLoggData: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        if self.scheduleloggdata == nil {
            self.numberOflogfiles.stringValue = NSLocalizedString("Number of logs:", comment: "Logg")
            self.selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg") + " 0"
            return 0
        } else {
            self.numberOflogfiles.stringValue = NSLocalizedString("Number of logs:", comment: "Logg")
                + " " + String(self.scheduleloggdata?.loggrecords?.count ?? 0)
            self.selectedrows.stringValue = NSLocalizedString("Selected logs:", comment: "Logg")
                + " " + self.selectednumber()
            return self.scheduleloggdata?.loggrecords?.count ?? 0
        }
    }
}

extension ViewControllerLoggData: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let tableColumn = tableColumn {
            guard row < (self.scheduleloggdata?.loggrecords?.count ?? 0) else { return nil }
            if let object = self.scheduleloggdata?.loggrecords?[row] {
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
            self.index = nil
        }
        self.column = column
        self.sortbycolumn()
    }

    func tableView(_: NSTableView, setObjectValue _: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if let tableColumn = tableColumn {
            if tableColumn.identifier.rawValue == DictionaryStrings.deleteCellID.rawValue {
                var delete: Int = self.scheduleloggdata?.loggrecords![row].delete ?? 0
                if delete == 0 { delete = 1 } else if delete == 1 { delete = 0 }
                switch tableColumn.identifier.rawValue {
                case DictionaryStrings.deleteCellID.rawValue:
                    self.scheduleloggdata?.loggrecords?[row].delete = delete
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
        self.working.stopAnimation(nil)
        if let index = self.index {
            let hiddenID = self.configurations?.gethiddenID(index: index) ?? -1
            guard hiddenID > -1 else { return }
            if let config = self.configurations?.getConfigurations()?[index] {
                self.scheduleloggdata = ScheduleLoggData(hiddenID: hiddenID)
                if self.connected(config: config),
                   self.snapshotscheduleloggdata == nil
                {
                    if config.task == ViewControllerReference.shared.snapshot { self.working.startAnimation(nil) }
                    self.snapshotscheduleloggdata = Snapshotlogsandcatalogs(config: config)
                }
            }
        } else {
            self.scheduleloggdata = ScheduleLoggData(hiddenID: nil)
        }
        // align data - if self.snapshotscheduleloggdata != nil
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
        self.dismiss(viewcontroller)
    }
}

extension ViewControllerLoggData: NewProfile {
    func newprofile(profile _: String?, selectedindex _: Int?) {
        self.reloadtabledata()
    }

    func reloadprofilepopupbutton() {
        //
    }
}

extension ViewControllerLoggData: Sidebarbuttonactions {
    func sidebarbuttonactions(action: Sidebaractionsmessages) {
        switch action {
        case .Delete:
            self.deletealllogs()
        default:
            return
        }
    }
}
