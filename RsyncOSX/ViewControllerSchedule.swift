//
//  ViewControllertabSchedule.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length cyclomatic_complexity function_body_length file_length

import Cocoa
import Foundation

protocol SetProfileinfo: AnyObject {
    func setprofile(profile: String, color: NSColor)
}

class ViewControllerSchedule: NSViewController, SetConfigurations, SetSchedules, Delay, Index, VcMain, Checkforrsync, Setcolor, Help {
    var index: Int?
    // var schedulessorted: ScheduleSortedAndExpand?
    var schedule: Scheduletype?
    // Scheduleetails
    var scheduledetails: [NSMutableDictionary]?

    // Main tableview
    @IBOutlet var scheduletable: NSTableView!
    @IBOutlet var profilInfo: NSTextField!
    @IBOutlet var weeklybutton: NSButton!
    @IBOutlet var dailybutton: NSButton!
    @IBOutlet var oncebutton: NSButton!
    @IBOutlet var info: NSTextField!
    @IBOutlet var rsyncosxschedbutton: NSButton!
    @IBOutlet var menuappisrunning: NSButton!
    @IBOutlet var scheduletabledetails: NSTableView!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

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

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    @IBAction func rsyncosxsched(_: NSButton) {
        let running = Running()
        guard running.rsyncOSXschedisrunning == false else {
            self.info.stringValue = Infoexecute().info(num: 5)
            self.info.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            return
        }
        let pathtorsyncosxschedapp: String = ViewControllerReference.shared.pathrsyncosxsched ?? "/Applications/" + ViewControllerReference.shared.namersyncosssched
        guard running.verifypathexists(pathorfilename: pathtorsyncosxschedapp) == true else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: pathtorsyncosxschedapp))
        NSApp.terminate(self)
    }

    @IBAction func once(_: NSButton) {
        self.schedule = .once
        self.addschedule()
    }

    @IBAction func daily(_: NSButton) {
        self.schedule = .daily
        self.addschedule()
    }

    @IBAction func weekly(_: NSButton) {
        self.schedule = .weekly
        self.addschedule()
    }

    @IBAction func selectdate(_: NSDatePicker) {
        self.schedulebuttonsonoff()
    }

    @IBAction func selecttime(_: NSDatePicker) {
        self.schedulebuttonsonoff()
    }

    private func addschedule() {
        guard self.index != nil || self.index() != nil else { return }
        let question: String = NSLocalizedString("Add Schedule?", comment: "Add schedule")
        let text: String = NSLocalizedString("Cancel or Add", comment: "Add schedule")
        let dialog: String = NSLocalizedString("Add", comment: "Add schedule")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
        if answer {
            self.info.stringValue = Infoschedule().info(num: 2)
            let seconds: TimeInterval = self.starttime.dateValue.timeIntervalSinceNow
            let startdate: Date = self.startdate.dateValue.addingTimeInterval(seconds)
            if let index = self.index() {
                if self.index == nil {
                    self.index = index
                }
            }
            if let hiddenID = self.configurations?.gethiddenID(index: self.index ?? -1) {
                guard hiddenID != -1 else { return }
                self.schedules!.addschedule(hiddenID: hiddenID, schedule: self.schedule ?? .once, start: startdate)
            }
        }
    }

    private func schedulebuttonsonoff() {
        let seconds: TimeInterval = self.starttime.dateValue.timeIntervalSinceNow
        // Date and time for stop
        let startime: Date = self.startdate.dateValue.addingTimeInterval(seconds)
        let secondstostart = startime.timeIntervalSinceNow
        if secondstostart < 60 {
            self.selectedstart.isHidden = true
            self.weeklybutton.isEnabled = false
            self.dailybutton.isEnabled = false
            self.oncebutton.isEnabled = false
        }
        if secondstostart > 60 {
            self.selectedstart.isHidden = false
            self.selectedstart.stringValue = startime.localized_string_from_date() + " (" + Dateandtime().timestring(seconds: secondstostart) + ")"
            self.selectedstart.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            self.weeklybutton.isEnabled = true
            self.dailybutton.isEnabled = true
            self.oncebutton.isEnabled = true
        }
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

    @IBOutlet var startdate: NSDatePicker!
    @IBOutlet var starttime: NSDatePicker!
    @IBOutlet var selectedstart: NSTextField!

    @IBAction func update(_: NSButton) {
        self.schedules?.deleteandstopschedules(data: scheduledetails)
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        self.scheduletabledetails.delegate = self
        self.scheduletabledetails.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabschedule, nsviewcontroller: self)
        self.rsyncosxschedbutton.toolTip = NSLocalizedString("The menu app", comment: "Execute")
        self.initpopupbutton()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if self.index() != nil, self.index == nil {
            self.info.stringValue = Infoschedule().info(num: 3)
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
        } else {
            self.info.stringValue = Infoschedule().info(num: 0)
        }
        self.weeklybutton.isEnabled = false
        self.dailybutton.isEnabled = false
        self.oncebutton.isEnabled = false
        self.selectedstart.isHidden = true
        self.startdate.dateValue = Date()
        self.starttime.dateValue = Date()
        self.reloadtabledata()
        self.delayWithSeconds(0.5) {
            self.menuappicons()
        }
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == self.scheduletable {
            self.info.stringValue = Infoschedule().info(num: 0)
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                self.index = index
                let hiddendID = self.configurations?.gethiddenID(index: self.index ?? -1)
                self.scheduledetails = self.schedules?.readscheduleonetask(hiddenID: hiddendID)
            } else {
                self.index = nil
                self.scheduledetails = nil
            }
            globalMainQueue.async { () -> Void in
                self.scheduletabledetails.reloadData()
                self.scheduletable.reloadData()
            }
        }
    }

    func menuappicons() {
        globalMainQueue.async { () -> Void in
            let running = Running()
            if running.rsyncOSXschedisrunning == true {
                self.menuappisrunning.image = #imageLiteral(resourceName: "green")
                self.info.stringValue = Infoexecute().info(num: 5)
                self.info.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            } else {
                self.menuappisrunning.image = #imageLiteral(resourceName: "red")
            }
        }
    }

    func initpopupbutton() {
        var profilestrings: [String]?
        profilestrings = CatalogProfile().getDirectorysStrings()
        profilestrings?.insert(NSLocalizedString("Default profile", comment: "default profile"), at: 0)
        self.profilepopupbutton.removeAllItems()
        self.profilepopupbutton.addItems(withTitles: profilestrings ?? [])
        self.profilepopupbutton.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        var profile = self.profilepopupbutton.titleOfSelectedItem
        let selectedindex = self.profilepopupbutton.indexOfSelectedItem
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            profile = nil
        }
        self.profilepopupbutton.selectItem(at: selectedindex)
        _ = Selectprofile(profile: profile, selectedindex: selectedindex)
    }
}

extension ViewControllerSchedule: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.scheduletable {
            return self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
        } else {
            return self.scheduledetails?.count ?? 0
        }
    }
}

extension ViewControllerSchedule: NSTableViewDelegate, Attributedestring {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == self.scheduletable {
            if row < self.configurations!.getConfigurationsDataSourceSynchronize()?.count ?? 0 {
                let object: NSDictionary = self.configurations!.getConfigurationsDataSourceSynchronize()![row]
                let hiddenID: Int = object.value(forKey: "hiddenID") as? Int ?? -1
                switch tableColumn!.identifier.rawValue {
                case "scheduleID":
                    if self.sortedandexpanded != nil {
                        let schedule: String? = self.sortedandexpanded!.sortandcountscheduledonetask(hiddenID, profilename: nil, number: false)
                        if schedule?.isEmpty == false {
                            switch schedule {
                            case Scheduletype.once.rawValue:
                                return NSLocalizedString("once", comment: "main")
                            case Scheduletype.daily.rawValue:
                                return NSLocalizedString("daily", comment: "main")
                            case Scheduletype.weekly.rawValue:
                                return NSLocalizedString("weekly", comment: "main")
                            case Scheduletype.manuel.rawValue:
                                return NSLocalizedString("manuel", comment: "main")
                            default:
                                return ""
                            }
                        } else {
                            return ""
                        }
                    }
                case "offsiteServerCellID":
                    if (object[tableColumn!.identifier] as? String)!.isEmpty {
                        if self.index() ?? -1 == row, self.index == nil {
                            return self.attributedstring(str: "localhost", color: NSColor.green, align: .left)
                        } else {
                            return "localhost"
                        }
                    } else {
                        if self.index() ?? -1 == row, self.index == nil {
                            let text = object[tableColumn!.identifier] as? String
                            return self.attributedstring(str: text!, color: NSColor.green, align: .left)
                        } else {
                            return object[tableColumn!.identifier] as? String
                        }
                    }
                case "inCellID":
                    if self.sortedandexpanded != nil {
                        let taskintime: String? = self.sortedandexpanded!.sortandcountscheduledonetask(hiddenID, profilename: nil, number: true)
                        return taskintime ?? ""
                    }
                default:
                    if self.index() ?? -1 == row, self.index == nil {
                        let text = object[tableColumn!.identifier] as? String
                        return self.attributedstring(str: text!, color: NSColor.green, align: .left)
                    } else {
                        return object[tableColumn!.identifier] as? String
                    }
                }
            } else {
                return nil
            }
        } else {
            if row < self.scheduledetails?.count ?? 0 {
                let object: NSMutableDictionary = self.scheduledetails![row]
                switch tableColumn!.identifier.rawValue {
                case "active":
                    let datestopstring = object.value(forKey: "dateStop") as? String ?? ""
                    let schedule = object.value(forKey: "schedule") as? String ?? ""
                    guard datestopstring.isEmpty == false, datestopstring != "no stop date" else { return nil }
                    let dateStop: Date = datestopstring.en_us_date_from_string()
                    if dateStop.timeIntervalSinceNow > 0, schedule != Scheduletype.stopped.rawValue {
                        return #imageLiteral(resourceName: "complete")
                    } else {
                        return nil
                    }
                case "stopCellID", "deleteCellID":
                    return object[tableColumn!.identifier] as? Int
                case "schedule":
                    switch object[tableColumn!.identifier] as? String {
                    case Scheduletype.once.rawValue:
                        return NSLocalizedString("once", comment: "main")
                    case Scheduletype.daily.rawValue:
                        return NSLocalizedString("daily", comment: "main")
                    case Scheduletype.weekly.rawValue:
                        return NSLocalizedString("weekly", comment: "main")
                    case Scheduletype.manuel.rawValue:
                        return NSLocalizedString("manuel", comment: "main")
                    case Scheduletype.stopped.rawValue:
                        return NSLocalizedString("stopped", comment: "main")
                    default:
                        return ""
                    }
                case "dateStart":
                    if object[tableColumn!.identifier] as? String == "01 Jan 1900 00:00" {
                        return NSLocalizedString("no startdate", comment: "Schedule details")
                    } else {
                        let stringdate: String = object[tableColumn!.identifier] as? String ?? ""
                        if stringdate.isEmpty {
                            return ""
                        } else {
                            return stringdate.en_us_date_from_string().localized_string_from_date()
                        }
                    }
                case "dateStop":
                    if object[tableColumn!.identifier] as? String == "01 Jan 2100 00:00" {
                        return NSLocalizedString("no stopdate", comment: "Schedule details")
                    } else {
                        let stringdate: String = object[tableColumn!.identifier] as? String ?? ""
                        if stringdate.isEmpty {
                            return ""
                        } else {
                            return stringdate.en_us_date_from_string().localized_string_from_date()
                        }
                    }
                case "numberoflogs", "dayinweek":
                    return object[tableColumn!.identifier] as? String
                default:
                    return nil
                }
            } else {
                return nil
            }
        }
        return nil
    }

    func tableView(_: NSTableView, setObjectValue _: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if tableColumn!.identifier.rawValue == "stopCellID" || tableColumn!.identifier.rawValue == "deleteCellID" {
            var stop: Int = (self.scheduledetails![row].value(forKey: "stopCellID") as? Int)!
            var delete: Int = (self.scheduledetails![row].value(forKey: "deleteCellID") as? Int)!
            if stop == 0 { stop = 1 } else if stop == 1 { stop = 0 }
            if delete == 0 { delete = 1 } else if delete == 1 { delete = 0 }
            switch tableColumn!.identifier.rawValue {
            case "stopCellID":
                self.scheduledetails![row].setValue(stop, forKey: "stopCellID")
            case "deleteCellID":
                self.scheduledetails![row].setValue(delete, forKey: "deleteCellID")
            default:
                break
            }
        }
    }
}

extension ViewControllerSchedule: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        self.reloadtabledata()
    }
}

extension ViewControllerSchedule: Reloadandrefresh {
    func reloadtabledata() {
        let hiddendID = self.configurations?.gethiddenID(index: self.index ?? -1)
        self.scheduledetails = self.schedules?.readscheduleonetask(hiddenID: hiddendID)
        globalMainQueue.async { () -> Void in
            self.scheduletable.reloadData()
            self.scheduletabledetails.reloadData()
        }
    }
}

// Deselect a row
extension ViewControllerSchedule: DeselectRowTable {
    // deselect a row after row is deleted
    func deselect() {
        guard self.index != nil else { return }
        self.scheduletable.deselectRow(self.index!)
    }
}

extension ViewControllerSchedule: SetProfileinfo {
    func setprofile(profile: String, color: NSColor) {
        globalMainQueue.async { () -> Void in
            self.profilInfo.stringValue = profile
            self.profilInfo.textColor = color
        }
    }
}

extension ViewControllerSchedule: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}
