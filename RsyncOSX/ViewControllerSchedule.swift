//
//  ViewControllertabSchedule.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length cyclomatic_complexity function_body_length

import Foundation
import Cocoa

protocol SetProfileinfo: class {
    func setprofile(profile: String, color: NSColor)
}

class ViewControllerSchedule: NSViewController, SetConfigurations, SetSchedules, Delay, Index, VcMain, Checkforrsync, Setcolor {

    private var index: Int?
    private var schedulessorted: ScheduleSortedAndExpand?
    var schedule: Scheduletype?

    // Main tableview
    @IBOutlet weak var scheduletable: NSTableView!
    @IBOutlet weak var profilInfo: NSTextField!
    @IBOutlet weak var weeklybutton: NSButton!
    @IBOutlet weak var dailybutton: NSButton!
    @IBOutlet weak var oncebutton: NSButton!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var rsyncosxschedbutton: NSButton!
    @IBOutlet weak var menuappisrunning: NSButton!

    @IBAction func totinfo(_ sender: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        })
    }

    @IBAction func quickbackup(_ sender: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_ sender: NSButton) {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func rsyncosxsched(_ sender: NSButton) {
        let pathtorsyncosxschedapp: String = ViewControllerReference.shared.pathrsyncosxsched! + ViewControllerReference.shared.namersyncosssched
        NSWorkspace.shared.open(URL(fileURLWithPath: pathtorsyncosxschedapp))
        self.rsyncosxschedbutton.isEnabled = false
        NSApp.terminate(self)
    }

    @IBAction func once(_ sender: NSButton) {
        self.schedule = .once
        self.addschedule()
    }

    @IBAction func daily(_ sender: NSButton) {
        self.schedule = .daily
        self.addschedule()
    }

    @IBAction func weekly(_ sender: NSButton) {
        self.schedule = .weekly
        self.addschedule()
    }

    @IBAction func selectdate(_ sender: NSDatePicker) {
       self.schedulebuttonsonoff()
    }

    @IBAction func selecttime(_ sender: NSDatePicker) {
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
                self.schedules!.addschedule(hiddenID, schedule: self.schedule ?? .once, start: startdate)
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
            let dateformatter = DateFormatter()
            dateformatter.formatterBehavior = .behavior10_4
            dateformatter.dateStyle = .medium
            dateformatter.timeStyle = .short
            self.selectedstart.isHidden = false
            self.selectedstart.stringValue = dateformatter.string(from: startime)
            self.selectedstart.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            self.weeklybutton.isEnabled = true
            self.dailybutton.isEnabled = true
            self.oncebutton.isEnabled = true
        }
    }

    // Selecting profiles
    @IBAction func profiles(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        })
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    // Logg records
    @IBAction func loggrecords(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerScheduleDetails!)
        })
    }

    @IBOutlet weak var startdate: NSDatePicker!
    @IBOutlet weak var starttime: NSDatePicker!
    @IBOutlet weak var selectedstart: NSTextField!

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        self.scheduletable.doubleAction = #selector(ViewControllerMain.tableViewDoubleClick(sender:))
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabschedule, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if self.index() != nil {
            self.info.stringValue = Infoschedule().info(num: 3)
        } else {
            self.info.stringValue = Infoschedule().info(num: 0)
        }
        self.weeklybutton.isEnabled = false
        self.dailybutton.isEnabled = false
        self.oncebutton.isEnabled = false
        self.selectedstart.isHidden = true
        self.startdate.dateValue = Date()
        self.starttime.dateValue = Date()
        if self.schedulessorted == nil {
            self.schedulessorted = ScheduleSortedAndExpand()
        }
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
        self.delayWithSeconds(0.5) {
            self.enablemenuappbutton()
        }
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.info.stringValue = Infoschedule().info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
        } else {
            self.index = nil
        }
    }

    // View schedule details by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerScheduleDetails!)
        })
    }

    private func enablemenuappbutton() {
        globalMainQueue.async(execute: { () -> Void in
            let running = Running()
            guard running.enablemenuappbutton == true else {
                self.rsyncosxschedbutton.isEnabled = false
                if running.menuappnoconfig == false {
                    self.menuappisrunning.image = #imageLiteral(resourceName: "green")
                    self.info.stringValue = Infoschedule().info(num: 5)
                }
                return
            }
            self.rsyncosxschedbutton.isEnabled = true
            self.menuappisrunning.image = #imageLiteral(resourceName: "red")
        })
    }
}

extension ViewControllerSchedule: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
    }
}

extension ViewControllerSchedule: NSTableViewDelegate, Attributedestring {

   func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.configurations!.getConfigurationsDataSourceSynchronize()!.count  else { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSourceSynchronize()![row]
        let hiddenID: Int = object.value(forKey: "hiddenID") as? Int ?? -1
        switch tableColumn!.identifier.rawValue {
        case "scheduleID" :
            if self.schedulessorted != nil {
                let schedule: String? = self.schedulessorted!.sortandcountscheduledonetask(hiddenID, profilename: nil, number: false)
                if schedule?.isEmpty == false {
                    switch schedule {
                    case "once":
                        return NSLocalizedString("once", comment: "main")
                    case "daily":
                        return NSLocalizedString("daily", comment: "main")
                    case "weekly":
                        return NSLocalizedString("weekly", comment: "main")
                    case "manuel":
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
                if self.index() ?? -1 == row && self.index == nil {
                    return self.attributedstring(str: "localhost", color: NSColor.red, align: .left)
                } else {
                    return "localhost"
                }
            } else {
                if self.index() ?? -1 == row && self.index == nil {
                    let text = object[tableColumn!.identifier] as? String
                    return self.attributedstring(str: text!, color: NSColor.red, align: .left)
                } else {
                    return object[tableColumn!.identifier] as? String
                }
            }
        case "inCellID":
            if self.schedulessorted != nil {
                let taskintime: String? = self.schedulessorted!.sortandcountscheduledonetask(hiddenID, profilename: nil, number: true)
                return taskintime ?? ""
            }
        default:
            if self.index() ?? -1 == row && self.index == nil {
                let text = object[tableColumn!.identifier] as? String
                return self.attributedstring(str: text!, color: NSColor.red, align: .left)
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
    return nil
    }
}

extension  ViewControllerSchedule: GetHiddenID {
    func gethiddenID() -> Int {
        if let hiddenID = self.configurations?.gethiddenID(index: self.index ?? -1) {
            return hiddenID
        } else {
            return -1
        }
    }
}

extension ViewControllerSchedule: DismissViewController {

    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
    }
}

extension ViewControllerSchedule: Reloadandrefresh {

    func reloadtabledata() {
        // Create a New schedules object
        self.schedulessorted = ScheduleSortedAndExpand()
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
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
        globalMainQueue.async(execute: { () -> Void in
            self.profilInfo.stringValue = profile
            self.profilInfo.textColor = color
        })
    }
}

extension ViewControllerSchedule: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        })
    }
}
