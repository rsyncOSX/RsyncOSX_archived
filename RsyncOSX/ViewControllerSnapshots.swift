//
//  ViewControllerSnapshots.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length file_length

import Foundation
import Cocoa

class ViewControllerSnapshots: NSViewController, SetDismisser, SetConfigurations, Delay, Connected, VcMain, Index {

    private var hiddenID: Int?
    private var config: Configuration?
    private var snapshotsloggdata: SnapshotsLoggData?
    private var delete: Bool = false
    private var numbersinsequencetodelete: Int?
    private var snapshotstodelete: Double = 0
    private var index: Int?
    weak var processterminationDelegate: UpdateProgress?
    var abort: Bool = false
    // Reference to which plan in combox
    var combovalueslast = ["none",
                          "last",
                          "every"]

    let combovaluesdayofweek: [String] = [StringDayofweek.Sunday.rawValue,
                                    StringDayofweek.Monday.rawValue,
                                    StringDayofweek.Tuesday.rawValue,
                                    StringDayofweek.Wednesday.rawValue,
                                    StringDayofweek.Thursday.rawValue,
                                    StringDayofweek.Friday.rawValue,
                                    StringDayofweek.Saturday.rawValue]

    @IBOutlet weak var snapshotstableView: NSTableView!
    @IBOutlet weak var rsynctableView: NSTableView!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var deletebutton: NSButton!
    @IBOutlet weak var numberOflogfiles: NSTextField!
    @IBOutlet weak var deletesnapshots: NSSlider!
    @IBOutlet weak var stringdeletesnapshotsnum: NSTextField!
    @IBOutlet weak var gettinglogs: NSProgressIndicator!
    @IBOutlet weak var deletesnapshotsdays: NSSlider!
    @IBOutlet weak var stringdeletesnapshotsdaysnum: NSTextField!
    @IBOutlet weak var selectplan: NSComboBox!
    @IBOutlet weak var savebutton: NSButton!
    @IBOutlet weak var selectdayofweek: NSComboBox!

    var verifyrsyncpath: Verifyrsyncpath?

    @IBAction func totinfo(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            self.verifyrsyncpath!.noRsync()
            return
        }
        self.configurations!.processtermination = .remoteinfotask
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        })
    }

    @IBAction func quickbackup(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            self.verifyrsyncpath!.noRsync()
            return
        }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_ sender: NSButton) {
        self.configurations!.processtermination = .automaticbackup
        self.configurations?.remoteinfotaskworkqueue = RemoteInfoTaskWorkQueue(inbatch: false)
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func savesnapday(_ sender: NSButton) {
    }

    private func info (num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "Not a snapshot task..."
        case 2:
            self.info.stringValue = "Aborting delete operation..."
        case 3:
            self.info.stringValue = "Delete operation completed..."
        case 4:
            self.info.stringValue = "Seriously, enter a real number..."
        case 5:
            let num = String((self.snapshotsloggdata?.snapshotslogs?.count ?? 1 - 1) - 1)
            self.info.stringValue = "You cannot delete that many, max is " + num + "..."
        case 6:
            self.info.stringValue = "Seems not to be connected..."
        default:
            self.info.stringValue = ""
        }
    }

    private func initslidersdeletesnapshots() {
        self.deletesnapshots.altIncrementValue = 1.0
        self.deletesnapshots.maxValue = Double(self.snapshotsloggdata?.snapshotslogs?.count ?? 0) - 1.0
        self.deletesnapshots.minValue = 0.0
        self.deletesnapshots.intValue = 0
        self.stringdeletesnapshotsnum.stringValue = "0"
        self.deletesnapshotsdays.altIncrementValue = 1.0
        self.deletesnapshotsdays.maxValue = 99.0
        self.deletesnapshotsdays.minValue = 0.0
        self.deletesnapshotsdays.intValue = 99
        self.stringdeletesnapshotsdaysnum.stringValue = "99"
        self.numbersinsequencetodelete = 0
    }

    private func initcombox(combobox: NSComboBox, values: [String], index: Int) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: values)
        combobox.selectItem(at: index)
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    @IBAction func updatedeletesnapshotsnum(_ sender: NSSlider) {
        self.stringdeletesnapshotsnum.stringValue = String(self.deletesnapshots.intValue)
        self.numbersinsequencetodelete = Int(self.deletesnapshots.intValue - 1)
        self.markfordelete(numberstomark: self.numbersinsequencetodelete!)
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstableView.reloadData()
        })
    }

    @IBAction func updatedeletesnapshotsdays(_ sender: Any) {
        self.stringdeletesnapshotsdaysnum.stringValue = String(self.deletesnapshotsdays.intValue)
        self.numbersinsequencetodelete = self.snapshotsloggdata?.countbydays(num: Double(self.deletesnapshotsdays.intValue))
        self.markfordelete(numberstomark: self.numbersinsequencetodelete!)
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstableView.reloadData()
        })
    }

    private func markfordelete(numberstomark: Int ) {
        guard self.snapshotsloggdata?.snapshotslogs != nil else { return }
        for i in 0 ..< self.snapshotsloggdata!.snapshotslogs!.count - 1 {
            if i <= numberstomark {
                self.snapshotsloggdata?.snapshotslogs![i].setValue(1, forKey: "selectCellID")
            } else {
                self.snapshotsloggdata?.snapshotslogs![i].setValue(0, forKey: "selectCellID")
            }
        }
    }

    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        self.info(num: 2)
        self.snapshotsloggdata?.remotecatalogstodelete = nil
    }

    @IBAction func delete(_ sender: NSButton) {
        guard self.snapshotsloggdata != nil else { return }
        let answer = Alerts.dialogOKCancel("Do you REALLY want to DELETE selected snapshots?", text: "Cancel or OK")
        if answer {
            self.info(num: 0)
            self.snapshotsloggdata!.preparecatalogstodelete()
            guard self.snapshotsloggdata!.remotecatalogstodelete != nil else { return }
            self.presentAsSheet(self.viewControllerProgress!)
            self.deletebutton.isEnabled = false
            self.deletesnapshots.isEnabled = false
            self.deletesnapshotcatalogs()
            self.delete = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.snapshotstableView.delegate = self
        self.snapshotstableView.dataSource = self
        self.rsynctableView.delegate = self
        self.rsynctableView.dataSource = self
        self.gettinglogs.usesThreadedAnimation = true
        self.stringdeletesnapshotsnum.delegate = self
        self.stringdeletesnapshotsdaysnum.delegate = self
        self.selectplan.delegate = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcsnapshot, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        ViewControllerReference.shared.activetab = .vcsnapshot
        self.initcombox(combobox: self.selectplan, values: self.combovalueslast, index: 0)
        self.initcombox(combobox: self.selectdayofweek, values: self.combovaluesdayofweek, index: 0)
        self.selectplan.isEnabled = false
        if let index = self.index() {
            guard index < self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()!.count else { return }
            let hiddenID = self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()![index].value(forKey: "hiddenID") as? Int ?? -1
            let config = self.configurations!.getConfigurations()[index]
            guard self.connected(config: config) == true else {
                self.info(num: 6)
                return
            }
            self.index = self.configurations?.getIndex(hiddenID)
            self.getSourceindex(index: hiddenID)
        } else {
            self.snapshotsloggdata = nil
            self.reloadtabledata()
        }
    }

    private func deletesnapshotcatalogs() {
        var arguments: SnapshotDeleteCatalogsArguments?
        var deletecommand: SnapshotCommandDeleteCatalogs?
        guard self.snapshotsloggdata?.remotecatalogstodelete != nil else {
            self.deletebutton.isEnabled = true
            self.deletesnapshots.isEnabled = true
            self.info(num: 0)
            return
        }
        guard self.snapshotsloggdata!.remotecatalogstodelete!.count > 0 else {
            self.deletebutton.isEnabled = true
            self.deletesnapshots.isEnabled = true
            self.info(num: 0)
            return
        }
        let remotecatalog = self.snapshotsloggdata!.remotecatalogstodelete![0]
        self.snapshotsloggdata!.remotecatalogstodelete!.remove(at: 0)
        if self.snapshotsloggdata!.remotecatalogstodelete!.count == 0 {
            self.snapshotsloggdata!.remotecatalogstodelete = nil
        }
        arguments = SnapshotDeleteCatalogsArguments(config: self.config!, remotecatalog: remotecatalog)
        deletecommand = SnapshotCommandDeleteCatalogs(command: arguments?.getCommand(), arguments: arguments?.getArguments())
        deletecommand?.setdelegate(object: self)
        deletecommand?.executeProcess(outputprocess: nil)
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == self.snapshotstableView {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                let dict = self.snapshotsloggdata!.snapshotslogs![index]
                self.hiddenID = dict.value(forKey: "hiddenID") as? Int
                guard self.hiddenID != nil else { return }
                self.index = self.configurations?.getIndex(hiddenID!)
            } else {
                self.index = nil
            }
        } else {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                let config = self.configurations!.getConfigurations()[index]
                guard self.connected(config: config) == true else {
                    self.info(num: 6)
                    return
                }
                self.selectplan.isEnabled = false
                self.info(num: 0)
                let hiddenID = self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()![index].value(forKey: "hiddenID") as? Int ?? -1
                self.getSourceindex(index: hiddenID)
            }
        }
    }

    func getSourceindex(index: Int) {
        self.hiddenID = index
        self.config = self.configurations!.getConfigurations()[self.configurations!.getIndex(hiddenID!)]
        guard self.config!.task == ViewControllerReference.shared.snapshot else {
            self.info(num: 1)
            return
        }
        self.snapshotsloggdata = SnapshotsLoggData(config: self.config!, insnapshot: true)
        self.localCatalog.stringValue = self.config!.localCatalog
        self.offsiteCatalog.stringValue = self.config!.offsiteCatalog
        self.offsiteUsername.stringValue = self.config!.offsiteUsername
        self.backupID.stringValue = self.config!.backupID
        self.info(num: 0)
        self.gettinglogs.startAnimation(nil)
    }
}

extension ViewControllerSnapshots: DismissViewController {

    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        if self.snapshotsloggdata?.remotecatalogstodelete != nil {
            self.snapshotsloggdata?.remotecatalogstodelete = nil
            self.info(num: 2)
            self.abort = true
        }
    }
}

extension ViewControllerSnapshots: UpdateProgress {
    func processTermination() {
        self.selectplan.isEnabled = true
        if delete {
            let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess
            if self.snapshotsloggdata!.remotecatalogstodelete == nil {
                self.delete = false
                self.deletebutton.isEnabled = true
                self.deletesnapshots.isEnabled = true
                self.info(num: 3)
                self.snapshotsloggdata = SnapshotsLoggData(config: self.config!, insnapshot: true)
                if self.abort == true {
                    self.abort = false
                } else {
                    vc?.processTermination()
                }
            } else {
                vc?.fileHandler()
            }
            self.deletesnapshotcatalogs()
        } else {
            self.deletebutton.isEnabled = true
            self.snapshotsloggdata?.processTermination()
            self.initslidersdeletesnapshots()
            self.gettinglogs.stopAnimation(nil)
            self.numbersinsequencetodelete = nil
            globalMainQueue.async(execute: { () -> Void in
                self.snapshotstableView.reloadData()
            })
        }
    }

    func fileHandler() {
        //
    }
}

extension ViewControllerSnapshots: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.snapshotstableView {
            guard self.snapshotsloggdata?.snapshotslogs != nil else {
                self.numberOflogfiles.stringValue = "Number of snapshots:"
                return 0
            }
            self.numberOflogfiles.stringValue = "Number of snapshots: " + String(self.snapshotsloggdata?.snapshotslogs!.count ?? 0)
            return (self.snapshotsloggdata?.snapshotslogs!.count ?? 0)
        } else {
           return self.configurations?.getConfigurationsDataSourcecountBackupSnapshot()?.count ?? 0
        }
    }
}

extension ViewControllerSnapshots: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == self.rsynctableView {
            guard row < self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()!.count else { return nil }
            guard row < self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()!.count else { return nil }
            let object: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()![row]
            return object[tableColumn!.identifier] as? String
        } else {
            guard row < self.snapshotsloggdata?.snapshotslogs!.count ?? 0 else { return nil }
            let object: NSDictionary = self.snapshotsloggdata!.snapshotslogs![row]
            if tableColumn!.identifier.rawValue == "selectCellID" {
                return object[tableColumn!.identifier] as? Int
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard tableView == self.snapshotstableView else { return }
        if tableColumn!.identifier.rawValue == "selectCellID" {
            var select: Int = (self.snapshotsloggdata?.snapshotslogs![row].value(forKey: "selectCellID") as? Int) ?? 0
            if select == 0 { select = 1 } else if select == 1 { select = 0 }
            guard row < self.snapshotsloggdata!.snapshotslogs!.count - 1 else { return }
            self.snapshotsloggdata?.snapshotslogs![row].setValue(select, forKey: "selectCellID")
        }
    }
}

extension ViewControllerSnapshots: Reloadandrefresh {
    func reloadtabledata() {
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstableView.reloadData()
            self.rsynctableView.reloadData()
        })
    }
}

extension ViewControllerSnapshots: NSTextFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        self.delayWithSeconds(0.5) {
            guard self.snapshotsloggdata != nil else { return }
            if (notification.object as? NSTextField)! == self.stringdeletesnapshotsnum {
                if self.stringdeletesnapshotsnum.stringValue.isEmpty == false {
                    if let num = Int(self.stringdeletesnapshotsnum.stringValue) {
                        self.info(num: 0)
                        if num > self.snapshotsloggdata?.snapshotslogs?.count ?? 0 {
                            self.deletesnapshots.intValue = Int32((self.snapshotsloggdata?.snapshotslogs?.count)! - 1)
                            self.info(num: 5)
                        } else {
                            self.deletesnapshots.intValue = Int32(num)
                        }
                        self.numbersinsequencetodelete = Int(self.deletesnapshots.intValue) - 1
                        self.markfordelete(numberstomark: self.numbersinsequencetodelete!)
                        globalMainQueue.async(execute: { () -> Void in
                            self.snapshotstableView.reloadData()
                        })
                    } else {
                        self.info(num: 4)
                    }
                }
            } else {
                if self.stringdeletesnapshotsdaysnum.stringValue.isEmpty == false {
                    if let num = Int(self.stringdeletesnapshotsdaysnum.stringValue) {
                        self.deletesnapshotsdays.intValue = Int32(num)
                        self.numbersinsequencetodelete = self.snapshotsloggdata!.countbydays(num: Double(self.stringdeletesnapshotsdaysnum.stringValue) ?? 0)
                        self.markfordelete(numberstomark: self.numbersinsequencetodelete!)
                        globalMainQueue.async(execute: { () -> Void in
                            self.snapshotstableView.reloadData()
                        })
                    } else {
                        self.info(num: 4)
                    }
                }
            }
        }
    }
}

extension ViewControllerSnapshots: Count {
    func maxCount() -> Int {
        guard self.snapshotsloggdata?.remotecatalogstodelete != nil else { return 0 }
        let max = self.snapshotsloggdata!.remotecatalogstodelete!.count
        self.snapshotstodelete = Double(max)
        return max
    }

    func inprogressCount() -> Int {
        guard self.snapshotsloggdata?.remotecatalogstodelete != nil else { return 0 }
        let progress = Int(self.snapshotstodelete) - self.snapshotsloggdata!.remotecatalogstodelete!.count
        return progress
    }
}

extension ViewControllerSnapshots: GetSnapshotsLoggData {
    func getsnapshotsloggaata() -> SnapshotsLoggData? {
        return self.snapshotsloggdata
    }
}

extension ViewControllerSnapshots: NewProfile {
    func newProfile(profile: String?) {
        self.snapshotsloggdata = nil
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstableView.reloadData()
        })
    }

    func enableProfileMenu() {
        //
    }
}

extension ViewControllerSnapshots: NSComboBoxDelegate {
    func comboBoxSelectionDidChange(_ notification: Notification) {
        switch self.selectplan.indexOfSelectedItem {
        case 1:
            _ = PlanSnapshots(plan: 1)
        case 2:
            _ = PlanSnapshots(plan: 2)
        default:
            return
        }
    }
}

extension ViewControllerSnapshots: OpenQuickBackup {
    func openquickbackup() {
        self.configurations!.processtermination = .quicktask
        self.configurations!.allowNotifyinMain = false
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        })
    }
}
