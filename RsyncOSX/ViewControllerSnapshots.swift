//
//  ViewControllerSnapshots.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length file_length cyclomatic_complexity type_body_length

import Cocoa
import Foundation

class ViewControllerSnapshots: NSViewController, SetDismisser, SetConfigurations, Delay, Connected, VcMain, Checkforrsync, Setcolor, Help {
    var hiddenID: Int?
    var config: Configuration?
    var snapshotlogsandcatalogs: Snapshotlogsandcatalogs?
    var numbersinsequencetodelete: Int?
    var snapshotstodelete: Double = 0
    var index: Int?
    // Reference to which plan in combox
    var combovalueslast = [NSLocalizedString("none", comment: "plan"),
                           NSLocalizedString("every", comment: "plan"),
                           NSLocalizedString("last", comment: "plan")]

    let combovaluesdayofweek: [String] = [NSLocalizedString("Sunday", comment: "plan"),
                                          NSLocalizedString("Monday", comment: "plan"),
                                          NSLocalizedString("Tuesday", comment: "plan"),
                                          NSLocalizedString("Wednesday", comment: "plan"),
                                          NSLocalizedString("Thursday", comment: "plan"),
                                          NSLocalizedString("Friday", comment: "plan"),
                                          NSLocalizedString("Saturday", comment: "plan")]
    var diddissappear: Bool = false
    // Send messages to the sidebar
    weak var sidebaractionsDelegate: Sidebaractions?
    var configurations: Estimatedlistforsynchronization?

    @IBOutlet var snapshotstableView: NSTableView!
    @IBOutlet var rsynctableView: NSTableView!
    @IBOutlet var info: NSTextField!
    @IBOutlet var numberOflogfiles: NSTextField!
    @IBOutlet var deletesnapshots: NSSlider!
    @IBOutlet var stringdeletesnapshotsnum: NSTextField!
    @IBOutlet var gettinglogs: NSProgressIndicator!
    @IBOutlet var deletesnapshotsdays: NSSlider!
    @IBOutlet var stringdeletesnapshotsdaysnum: NSTextField!
    @IBOutlet var selectplan: NSComboBox!
    @IBOutlet var selectdayofweek: NSComboBox!
    @IBOutlet var dayofweek: NSTextField!
    @IBOutlet var lastorevery: NSTextField!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        presentAsModalWindow(viewControllerProfile!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        help()
    }

    // Sidebar save day of week
    func savesnapdayofweek() {
        var configurations = self.configurations?.getConfigurations()
        guard configurations?.count ?? 0 > 0 else { return }
        if let index = index {
            guard configurations?[index].task == SharedReference.shared.snapshot else { return }
            configurations?[index].snapdayoffweek = config?.snapdayoffweek
            configurations?[index].snaplast = config?.snaplast
            // Update configuration in memory before saving
            self.configurations?.updateConfigurations(configurations?[index], index: index)
        }
    }

    // Sidebar delete button
    func deleteaction() {
        guard snapshotlogsandcatalogs != nil else { return }
        guard SharedReference.shared.process == nil else { return }
        let num = snapshotlogsandcatalogs?.logrecordssnapshot?.filter { $0.selectCellID == 1 }.count
        let question: String = NSLocalizedString("Do you REALLY want to delete selected snapshots", comment: "Snapshots") + " (" + String(num ?? 0) + ")?"
        let text: String = NSLocalizedString("Cancel or Delete", comment: "Snapshots")
        let dialog: String = NSLocalizedString("Delete", comment: "Snapshots")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
        if answer {
            info.stringValue = Infosnapshots().info(num: 0)
            snapshotlogsandcatalogs?.preparesnapshotcatalogsfordelete()
            guard snapshotlogsandcatalogs?.snapshotcatalogstodelete != nil else { return }
            presentAsSheet(viewControllerProgress!)
            deletesnapshots.isEnabled = false
            deletesnapshotcatalogs()
        }
    }

    private func initslidersdeletesnapshots() {
        guard snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0 > 0 else { return }
        deletesnapshots.altIncrementValue = 1.0
        deletesnapshots.maxValue = Double(snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0) - 1.0
        deletesnapshots.minValue = 0.0
        deletesnapshots.intValue = 0
        stringdeletesnapshotsnum.stringValue = "0"
        deletesnapshotsdays.altIncrementValue = 1.0
        if let maxdaysold = snapshotlogsandcatalogs?.logrecordssnapshot?[0] {
            if let days = maxdaysold.days {
                deletesnapshotsdays.maxValue = (Double(days) ?? 0.0) + 1
                deletesnapshotsdays.intValue = Int32(deletesnapshotsdays.maxValue)
                if let maxdaysoldstring = Double(maxdaysold.days ?? "100") {
                    stringdeletesnapshotsdaysnum.stringValue = String(format: "%.0f", maxdaysoldstring)
                }
            }
        } else {
            deletesnapshotsdays.maxValue = 0.0
            deletesnapshotsdays.intValue = 0
            stringdeletesnapshotsdaysnum.stringValue = "0"
        }
        deletesnapshotsdays.minValue = 0.0
        numbersinsequencetodelete = 0
    }

    private func initcombox(combobox: NSComboBox, values: [String], index: Int) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: values)
        combobox.selectItem(at: index)
    }

    @IBAction func updatedeletesnapshotsnum(_: NSSlider) {
        guard index != nil else { return }
        stringdeletesnapshotsnum.stringValue = String(deletesnapshots.intValue)
        numbersinsequencetodelete = Int(deletesnapshots.intValue - 1)
        markfordelete(numberstomark: numbersinsequencetodelete!)
        globalMainQueue.async { () -> Void in
            self.snapshotstableView.reloadData()
        }
        info.stringValue = NSLocalizedString("Delete number of snapshots:", comment: "plan") + " " + String(deletesnapshots.intValue)
        info.textColor = setcolor(nsviewcontroller: self, color: .green)
        dayofweek.isHidden = true
        lastorevery.isHidden = true
    }

    @IBAction func updatedeletesnapshotsdays(_: NSSlider) {
        guard index != nil else { return }
        stringdeletesnapshotsdaysnum.stringValue = String(deletesnapshotsdays.intValue)
        numbersinsequencetodelete = snapshotlogsandcatalogs?.countbydays(num: Double(deletesnapshotsdays.intValue))
        markfordelete(numberstomark: numbersinsequencetodelete!)
        globalMainQueue.async { () -> Void in
            self.snapshotstableView.reloadData()
        }
        info.stringValue = NSLocalizedString("Delete snapshots older than:", comment: "plan") + " " + String(deletesnapshotsdays.intValue)
        info.textColor = setcolor(nsviewcontroller: self, color: .green)
        dayofweek.isHidden = true
        lastorevery.isHidden = true
    }

    private func markfordelete(numberstomark: Int) {
        guard snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0 > 0 else { return }
        for i in 0 ..< (snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0) - 1 {
            if i <= numberstomark {
                snapshotlogsandcatalogs?.logrecordssnapshot?[i].selectCellID = 1
            } else {
                snapshotlogsandcatalogs?.logrecordssnapshot?[i].selectCellID = 0
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurations = Estimatedlistforsynchronization()
        snapshotstableView.delegate = self
        snapshotstableView.dataSource = self
        rsynctableView.delegate = self
        rsynctableView.dataSource = self
        gettinglogs.usesThreadedAnimation = true
        stringdeletesnapshotsnum.delegate = self
        stringdeletesnapshotsdaysnum.delegate = self
        selectplan.delegate = self
        selectdayofweek.delegate = self
        SharedReference.shared.setvcref(viewcontroller: .vcsnapshot, nsviewcontroller: self)
        initpopupbutton()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // For sending messages to the sidebar
        sidebaractionsDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        sidebaractionsDelegate?.sidebaractions(action: .snapshotviewbuttons)
        guard diddissappear == false else { return }
        initcombox(combobox: selectplan, values: combovalueslast, index: 0)
        initcombox(combobox: selectdayofweek, values: combovaluesdayofweek, index: 0)
        selectplan.isEnabled = false
        selectdayofweek.isEnabled = false
        snapshotlogsandcatalogs = nil
        reloadtabledata()
        info.textColor = setcolor(nsviewcontroller: self, color: .red)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        diddissappear = true
    }

    private func deletesnapshotcatalogs() {
        guard (snapshotlogsandcatalogs?.snapshotcatalogstodelete?.count ?? 0) > 0 else {
            deletesnapshots.isEnabled = true
            info.stringValue = Infosnapshots().info(num: 0)
            return
        }
        if let remotecatalog = snapshotlogsandcatalogs?.snapshotcatalogstodelete?[0] {
            snapshotlogsandcatalogs?.snapshotcatalogstodelete?.remove(at: 0)
            if (snapshotlogsandcatalogs?.snapshotcatalogstodelete?.count ?? 0) == 0 {
                snapshotlogsandcatalogs?.snapshotcatalogstodelete = nil
            }
            if let config = config {
                let arguments = SnapshotDeleteCatalogsArguments(config: config, remotecatalog: remotecatalog)
                let command = OtherProcess(command: arguments.getCommand(),
                                           arguments: arguments.getArguments(),
                                           processtermination: processtermination,
                                           filehandler: filehandler)
                command.executeProcess(outputprocess: nil)
            }
        }
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == snapshotstableView {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                if let dict = snapshotlogsandcatalogs?.logrecordssnapshot?[index] {
                    info.textColor = setcolor(nsviewcontroller: self, color: .green)
                    let num = snapshotlogsandcatalogs?.logrecordssnapshot?.filter { $0.selectCellID == 1 }.count
                    info.stringValue = NSLocalizedString("Delete number of snapshots:", comment: "plan") + " " + String(num ?? 0)
                    hiddenID = dict.hiddenID
                    guard hiddenID != nil else { return }
                    self.index = configurations?.getIndex(hiddenID!)
                }
            } else {
                index = nil
            }
        } else {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                if let config = configurations?.getConfigurations()?[index] {
                    guard config.task == SharedReference.shared.snapshot else { return }
                    guard connected(config: config) == true else {
                        info.stringValue = Infosnapshots().info(num: 6)
                        return
                    }
                    selectplan.isEnabled = false
                    selectdayofweek.isEnabled = false
                    info.stringValue = Infosnapshots().info(num: 0)
                    let hiddenID = configurations?.getConfigurationsDataSourceSynchronize()?[index].value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int ?? -1
                    self.index = configurations?.getIndex(hiddenID)
                    getsourcebyindex(index: hiddenID)
                }
            } else {
                selectplan.isEnabled = false
                selectdayofweek.isEnabled = false
                snapshotlogsandcatalogs = nil
                index = nil
                info.stringValue = ""
                reloadtabledata()
            }
        }
    }

    func getsourcebyindex(index: Int) {
        hiddenID = index
        config = configurations?.getConfigurations()?[configurations?.getIndex(index) ?? -1]
        guard config?.task == SharedReference.shared.snapshot else {
            info.stringValue = Infosnapshots().info(num: 1)
            self.index = nil
            return
        }
        if let config = config {
            info.stringValue = Infosnapshots().info(num: 0)
            gettinglogs.startAnimation(nil)
            snapshotlogsandcatalogs = Snapshotlogsandcatalogs(config: config)
        }
    }

    private func preselectcomboboxes() {
        selectdayofweek.selectItem(withObjectValue: NSLocalizedString(config?.snapdayoffweek ?? "Sunday", comment: "dayofweek"))
        if config?.snaplast ?? 1 == 1 {
            selectplan.selectItem(withObjectValue: NSLocalizedString("every", comment: "plan"))
        } else {
            selectplan.selectItem(withObjectValue: NSLocalizedString("last", comment: "plan"))
        }
    }

    private func setlabeldayofweekandlast() {
        dayofweek.textColor = setcolor(nsviewcontroller: self, color: .green)
        lastorevery.textColor = setcolor(nsviewcontroller: self, color: .green)
        dayofweek.stringValue = NSLocalizedString(config?.snapdayoffweek ?? "Sunday", comment: "dayofweek")
        if config?.snaplast ?? 1 == 1 {
            lastorevery.stringValue = NSLocalizedString("every", comment: "plan")
        } else {
            lastorevery.stringValue = NSLocalizedString("last", comment: "plan")
        }
    }

    func initpopupbutton() {
        var profilestrings: [String]?
        profilestrings = CatalogProfile().getcatalogsasstringnames()
        profilestrings?.insert(NSLocalizedString("Default profile", comment: "default profile"), at: 0)
        profilepopupbutton.removeAllItems()
        profilepopupbutton.addItems(withTitles: profilestrings ?? [])
        profilepopupbutton.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        var profile = profilepopupbutton.titleOfSelectedItem
        let selectedindex = profilepopupbutton.indexOfSelectedItem
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            profile = nil
        }
        profilepopupbutton.selectItem(at: selectedindex)
        // TODO:
        _ = Selectprofile(profile: profile, selectedindex: selectedindex)
    }

    func tag() {
        guard config?.task == SharedReference.shared.snapshot else { return }
        guard SharedReference.shared.process == nil else { return }
        _ = Tagsnapshots(plan: config?.snaplast ?? 1, snapdayoffweek: config?.snapdayoffweek ?? StringDayofweek.Sunday.rawValue, snapshotsloggdata: snapshotlogsandcatalogs)
        dayofweek.isHidden = false
        lastorevery.isHidden = false
    }
}

extension ViewControllerSnapshots: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        dismiss(viewcontroller)
        if snapshotlogsandcatalogs?.snapshotcatalogstodelete != nil {
            snapshotlogsandcatalogs?.snapshotcatalogstodelete = nil
            info.stringValue = Infosnapshots().info(num: 2)
        }
    }
}

extension ViewControllerSnapshots {
    func processtermination() {
        if let vc = SharedReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess,
           let config = config
        {
            if snapshotlogsandcatalogs?.snapshotcatalogstodelete == nil {
                deletesnapshots.isEnabled = true
                info.stringValue = Infosnapshots().info(num: 3)
                snapshotlogsandcatalogs = Snapshotlogsandcatalogs(config: config)
                vc.processTermination()
            } else {
                vc.fileHandler()
            }
            deletesnapshotcatalogs()
        }
    }

    func filehandler() {}
}

extension ViewControllerSnapshots: Count {
    func maxCount() -> Int {
        let max = snapshotlogsandcatalogs?.snapshotcatalogstodelete?.count ?? 0
        snapshotstodelete = Double(max)
        return max
    }

    func inprogressCount() -> Int {
        let progress = Int(snapshotstodelete) - (snapshotlogsandcatalogs?.snapshotcatalogstodelete?.count ?? 0)
        return progress
    }
}

extension ViewControllerSnapshots: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == snapshotstableView {
            let numberofsnaps: String = NSLocalizedString("Number snapshots:", comment: "Snapshots")
            guard snapshotlogsandcatalogs?.logrecordssnapshot != nil else {
                numberOflogfiles.stringValue = numberofsnaps + " "
                return 0
            }
            numberOflogfiles.stringValue = numberofsnaps + " " + String(snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0)
            return snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0
        } else {
            return configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
        }
    }
}

extension ViewControllerSnapshots: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == rsynctableView {
            guard row < (configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0) else { return nil }
            if let object: NSDictionary = configurations?.getConfigurationsDataSourceSynchronize()?[row] {
                return object[tableColumn!.identifier] as? String
            } else {
                return nil
            }
        } else {
            guard row < (snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0) else { return nil }
            if let object = snapshotlogsandcatalogs?.logrecordssnapshot?[row],
               let tableColumn = tableColumn
            {
                switch tableColumn.identifier.rawValue {
                case DictionaryStrings.snapshotCatalog.rawValue:
                    return object.snapshotCatalog
                case DictionaryStrings.dateExecuted.rawValue:
                    return object.dateExecuted
                case DictionaryStrings.period.rawValue:
                    return object.period
                case DictionaryStrings.days.rawValue:
                    return object.days
                case DictionaryStrings.selectCellID.rawValue:
                    return object.selectCellID
                case DictionaryStrings.resultExecuted.rawValue:
                    return object.resultExecuted
                default:
                    return nil
                }
            } else {
                return nil
            }
        }
    }

    func tableView(_ tableView: NSTableView, setObjectValue _: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard tableView == snapshotstableView else { return }
        if let tableColumn = tableColumn {
            if tableColumn.identifier.rawValue == DictionaryStrings.selectCellID.rawValue {
                var select: Int = snapshotlogsandcatalogs?.logrecordssnapshot?[row].selectCellID ?? 0
                if select == 0 { select = 1 } else if select == 1 { select = 0 }
                guard row < (snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0) - 1 else { return }
                snapshotlogsandcatalogs?.logrecordssnapshot?[row].selectCellID = select
            }
        }
    }
}

extension ViewControllerSnapshots: Reloadandrefresh {
    func reloadtabledata() {
        setlabeldayofweekandlast()
        selectplan.isEnabled = true
        selectdayofweek.isEnabled = true
        initslidersdeletesnapshots()
        gettinglogs.stopAnimation(nil)
        numbersinsequencetodelete = nil
        preselectcomboboxes()
        globalMainQueue.async { () -> Void in
            self.snapshotstableView.reloadData()
            self.rsynctableView.reloadData()
        }
    }
}

extension ViewControllerSnapshots: NSTextFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        delayWithSeconds(0.5) {
            guard self.snapshotlogsandcatalogs != nil else { return }
            if notification.object as? NSTextField == self.stringdeletesnapshotsnum {
                if self.stringdeletesnapshotsnum.stringValue.isEmpty == false {
                    if let num = Int(self.stringdeletesnapshotsnum.stringValue) {
                        self.info.stringValue = Infosnapshots().info(num: 0)
                        if num > self.snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0 {
                            self.deletesnapshots.intValue = Int32((self.snapshotlogsandcatalogs?.logrecordssnapshot?.count ?? 0) - 1)
                            self.info.stringValue = Infosnapshots().info(num: 5)
                        } else {
                            self.deletesnapshots.intValue = Int32(num)
                        }
                        self.numbersinsequencetodelete = Int(self.deletesnapshots.intValue) - 1
                        self.markfordelete(numberstomark: self.numbersinsequencetodelete ?? 0)
                        globalMainQueue.async { () -> Void in
                            self.snapshotstableView.reloadData()
                        }
                    } else {
                        self.info.stringValue = Infosnapshots().info(num: 4)
                    }
                }
            } else {
                if self.stringdeletesnapshotsdaysnum.stringValue.isEmpty == false {
                    if let num = Int(self.stringdeletesnapshotsdaysnum.stringValue) {
                        self.deletesnapshotsdays.intValue = Int32(num)
                        self.numbersinsequencetodelete = self.snapshotlogsandcatalogs?.countbydays(num: Double(self.stringdeletesnapshotsdaysnum.stringValue) ?? 0)
                        self.markfordelete(numberstomark: self.numbersinsequencetodelete ?? 0)
                        globalMainQueue.async { () -> Void in
                            self.snapshotstableView.reloadData()
                        }
                    } else {
                        self.info.stringValue = Infosnapshots().info(num: 4)
                    }
                }
            }
        }
    }
}

extension ViewControllerSnapshots: NewProfile {
    func newprofile(profile _: String?, selectedindex: Int?) {
        if let index = selectedindex {
            profilepopupbutton.selectItem(at: index)
        } else {
            initpopupbutton()
        }
        snapshotlogsandcatalogs = nil
        globalMainQueue.async { () -> Void in
            self.snapshotstableView.reloadData()
        }
    }

    func reloadprofilepopupbutton() {}
}

extension ViewControllerSnapshots: NSComboBoxDelegate {
    func comboBoxSelectionDidChange(_: Notification) {
        switch selectdayofweek.indexOfSelectedItem {
        case 0:
            config?.snapdayoffweek = StringDayofweek.Sunday.rawValue
        case 1:
            config?.snapdayoffweek = StringDayofweek.Monday.rawValue
        case 2:
            config?.snapdayoffweek = StringDayofweek.Tuesday.rawValue
        case 3:
            config?.snapdayoffweek = StringDayofweek.Wednesday.rawValue
        case 4:
            config?.snapdayoffweek = StringDayofweek.Thursday.rawValue
        case 5:
            config?.snapdayoffweek = StringDayofweek.Friday.rawValue
        case 6:
            config?.snapdayoffweek = StringDayofweek.Saturday.rawValue
        default:
            config?.snapdayoffweek = StringDayofweek.Sunday.rawValue
        }
        info.stringValue = ""
        switch selectplan.indexOfSelectedItem {
        case 1:
            config?.snaplast = 1
        case 2:
            config?.snaplast = 2
        default:
            return
        }
        dayofweek.isHidden = true
        lastorevery.isHidden = true
    }
}

extension ViewControllerSnapshots: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerSnapshots: GetSelecetedIndex {
    func getindex() -> Int? {
        return index
    }
}

extension ViewControllerSnapshots: Sidebarbuttonactions {
    func sidebarbuttonactions(action: Sidebaractionsmessages) {
        switch action {
        case .Tag:
            tag()
        case .Delete:
            deleteaction()
        case .Save:
            savesnapdayofweek()
        default:
            return
        }
    }
}
