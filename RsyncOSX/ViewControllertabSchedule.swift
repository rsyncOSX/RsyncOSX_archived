//
//  ViewControllertabSchedule.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length cyclomatic_complexity file_length

import Foundation
import Cocoa

// Protocol for restarting timer
protocol StartTimer: class {
    func startTimerNextJob()
}

protocol SetProfileinfo: class {
    func setprofile(profile: String, color: NSColor)
}

class ViewControllertabSchedule: NSViewController, SetConfigurations, SetSchedules, Coloractivetask, OperationChanged, VcSchedule {

    private var index: Int?
    private var hiddenID: Int?
    private var nextTask: Timer?
    private var schedulessorted: ScheduleSortedAndExpand?
    private var infoschedulessorted: InfoScheduleSortedAndExpand?
    var tools: Tools?

    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var profilInfo: NSTextField!
    @IBOutlet weak var firstScheduledTask: NSTextField!
    @IBOutlet weak var secondScheduledTask: NSTextField!
    @IBOutlet weak var firstRemoteServer: NSTextField!
    @IBOutlet weak var secondRemoteServer: NSTextField!
    @IBOutlet weak var firstLocalCatalog: NSTextField!
    @IBOutlet weak var secondLocalCatalog: NSTextField!
    @IBOutlet weak var operation: NSTextField!
    @IBOutlet weak var weeklybutton: NSButton!
    @IBOutlet weak var dailybutton: NSButton!
    @IBOutlet weak var oncebutton: NSButton!
    @IBOutlet weak var info: NSTextField!

    private func info (num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "Select a task..."
        case 2:
            self.info.stringValue = "Start is passed..."
        case 3:
            self.info.stringValue = "Start must be 24 hours from now..."
        case 4:
            self.info.stringValue = "Start must be 7 days from now...."
        default:
            self.info.stringValue = ""
        }
    }

    @IBAction func once(_ sender: NSButton) {
        let startdate: Date = Date()
        // Seconds from now to start for "once"
        let seconds: TimeInterval = self.stoptime.dateValue.timeIntervalSinceNow
        // Date and time for stop
        let stopdate: Date = self.stopdate.dateValue.addingTimeInterval(seconds)
        var schedule: String?
        if self.index != nil {
            schedule = "once"
            if seconds > -60 {
                self.addschedule(schedule: schedule!, startdate: startdate, stopdate: stopdate + 60)
            } else {
                self.info(num: 2)
            }
        } else {
           self.info(num: 1)
        }
    }

    @IBAction func daily(_ sender: NSButton) {
        let startdate: Date = Date()
        let seconds: TimeInterval = self.stoptime.dateValue.timeIntervalSinceNow
        // Date and time for stop
        let stopdate: Date = self.stopdate.dateValue.addingTimeInterval(seconds)
        // Seconds from now to start for "daily"
        let secondsstart: TimeInterval = self.stopdate.dateValue.timeIntervalSinceNow
        var schedule: String?
        if self.index != nil {
            schedule = "daily"
            if secondsstart >= (60*60*24) {
                 self.addschedule(schedule: schedule!, startdate: startdate, stopdate: stopdate)
            } else {
                self.info(num: 3)
            }
        } else {
            self.info(num: 1)
        }
    }

    @IBAction func weekly(_ sender: NSButton) {
        let startdate: Date = Date()
        let seconds: TimeInterval = self.stoptime.dateValue.timeIntervalSinceNow
        // Date and time for stop
        let stopdate: Date = self.stopdate.dateValue.addingTimeInterval(seconds)
        // Seconds from now to start for "weekly"
        let secondsstart: TimeInterval = self.stopdate.dateValue.timeIntervalSinceNow
        var schedule: String?
        if self.index != nil {
            schedule = "weekly"
            if secondsstart >= (60*60*24*7) {
                self.addschedule(schedule: schedule!, startdate: startdate, stopdate: stopdate)
            } else {
                self.info(num: 4)
            }
        } else {
            self.info(num: 1)
        }
    }

    @IBAction func selectdate(_ sender: NSDatePicker) {
       self.schedulesonoff()
    }

    @IBAction func selecttime(_ sender: NSDatePicker) {
       self.schedulesonoff()
    }

    private func schedulesonoff() {
        let seconds: TimeInterval = self.stoptime.dateValue.timeIntervalSinceNow
        // Date and time for stop
        let stopdate: Date = self.stopdate.dateValue.addingTimeInterval(seconds)
        // Seconds from now to start for "weekly"
        let secondstostop = stopdate.timeIntervalSinceNow
        if secondstostop < 60 {
            self.weeklybutton.isEnabled = false
            self.dailybutton.isEnabled = false
            self.oncebutton.isEnabled = false
        }
        if secondstostop > 60 {
            self.weeklybutton.isEnabled = false
            self.dailybutton.isEnabled = false
            self.oncebutton.isEnabled = true
        }
        if secondstostop > 60*60*24 {
            self.weeklybutton.isEnabled = false
            self.dailybutton.isEnabled = true
            self.oncebutton.isEnabled = true
        }
        if secondstostop > 60*60*24*7 {
            self.weeklybutton.isEnabled = true
            self.dailybutton.isEnabled = true
            self.oncebutton.isEnabled = true
        }
    }

    // Selecting profiles
    @IBAction func profiles(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerProfile!)
        })
    }

    private func addschedule(schedule: String, startdate: Date, stopdate: Date) {
        let answer = Alerts.dialogOKCancel("Add Schedule?", text: "Cancel or OK")
        if answer {
            self.schedules!.addschedule(self.hiddenID!, schedule: schedule, start: startdate, stop: stopdate)
            self.infonexttask()
            self.startTimer()
        }
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    // Logg records
    @IBAction func loggrecords(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerScheduleDetails!)
        })
    }

    @IBOutlet weak var stopdate: NSDatePicker!
    @IBOutlet weak var stoptime: NSDatePicker!

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.mainTableView.doubleAction = #selector(ViewControllertabMain.tableViewDoubleClick(sender:))
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabschedule, nsviewcontroller: self)
        self.tools = Tools()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.weeklybutton.isEnabled = false
        self.dailybutton.isEnabled = false
        self.oncebutton.isEnabled = false
        self.stopdate.dateValue = Date()
        self.stoptime.dateValue = Date()
        if self.schedulessorted == nil {
            self.schedulessorted = ScheduleSortedAndExpand()
            self.infoschedulessorted = InfoScheduleSortedAndExpand(sortedandexpanded: self.schedulessorted)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        self.infonexttask()
        self.startTimer()
        self.operationsmethod()
    }

    internal func operationsmethod() {
        switch ViewControllerReference.shared.operation {
        case .dispatch:
            self.operation.stringValue = "Operation method: dispatch"
        case .timer:
            self.operation.stringValue = "Operation method: timer"
        }
    }

    // Start timer
    func startTimer() {
        if self.schedulessorted != nil {
            let timer: Double = self.infoschedulessorted!.startTimerseconds()
            // timer == 0 do not start NSTimer, timer > 0 update frequens of NSTimer
            if timer > 0 {
                self.nextTask?.invalidate()
                self.nextTask = nil
                // Update when next task is to be executed
                self.nextTask = Timer.scheduledTimer(timeInterval: timer, target: self, selector: #selector(infonexttask), userInfo: nil, repeats: true)
            }
        }
    }

    // Update display next scheduled jobs in time
    @objc func infonexttask() {
        guard self.schedulessorted != nil else { return }
        // Displaying next two scheduled tasks
        self.firstLocalCatalog.textColor = .black
        self.firstScheduledTask.stringValue = self.infoschedulessorted!.whenIsNextTwoTasksString()[0]
        self.secondScheduledTask.stringValue = self.infoschedulessorted!.whenIsNextTwoTasksString()[1]
        if self.infoschedulessorted!.remoteServerAndPathNextTwoTasks().count > 0 {
            if self.infoschedulessorted!.remoteServerAndPathNextTwoTasks().count > 2 {
                self.firstRemoteServer.stringValue = self.infoschedulessorted!.remoteServerAndPathNextTwoTasks()[0]
                self.firstLocalCatalog.stringValue = self.infoschedulessorted!.remoteServerAndPathNextTwoTasks()[1]
                self.secondRemoteServer.stringValue = self.infoschedulessorted!.remoteServerAndPathNextTwoTasks()[2]
                self.secondLocalCatalog.stringValue = self.infoschedulessorted!.remoteServerAndPathNextTwoTasks()[3]
            } else {
                guard self.infoschedulessorted!.remoteServerAndPathNextTwoTasks().count == 2 else {
                    return
                }
                self.firstRemoteServer.stringValue = self.infoschedulessorted!.remoteServerAndPathNextTwoTasks()[0]
                self.firstLocalCatalog.stringValue = self.infoschedulessorted!.remoteServerAndPathNextTwoTasks()[1]
                self.secondRemoteServer.stringValue = ""
                self.secondLocalCatalog.stringValue = ""
            }
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            // Set index
            self.index = index
            let dict = self.configurations!.getConfigurationsDataSourcecountBackup()![index]
            self.hiddenID = dict.value(forKey: "hiddenID") as? Int
        } else {
            self.index = nil
            self.hiddenID = nil
        }
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerScheduleDetails!)
        })
    }

}

extension ViewControllertabSchedule: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configurations?.getConfigurationsDataSourcecountBackup()?.count ?? 0
    }
}

extension ViewControllertabSchedule: NSTableViewDelegate, Attributedestring {

   func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.configurations!.getConfigurationsDataSourcecountBackup()!.count  else { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackup()![row]
        var number: Int?
        var taskintime: String?
        let hiddenID: Int = (object.value(forKey: "hiddenID") as? Int)!
        switch tableColumn!.identifier.rawValue {
        case "numberCellID" :
            if self.schedulessorted != nil {
                number = self.schedulessorted!.countscheduledtasks(hiddenID)
            }
            if number ?? 0 > 0 {
                let returnstr = String(number!)
                if let color = self.colorindex, color == hiddenID {
                    return self.attributedstring(str: returnstr, color: NSColor.green, align: .center)
                } else {
                    return returnstr
                }
            }
        case "batchCellID" :
            return object[tableColumn!.identifier] as? Int!
        case "offsiteServerCellID":
            if (object[tableColumn!.identifier] as? String)!.isEmpty {
                return "localhost"
            } else {
                return object[tableColumn!.identifier] as? String
            }
        case "inCellID":
            if self.schedulessorted != nil {
                taskintime = self.schedulessorted!.sortandcountscheduledtasks(hiddenID)
                return taskintime ?? ""
            }
        default:
            return object[tableColumn!.identifier] as? String
        }
    return nil
    }

    // Toggling batch
   func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if self.configurations!.getConfigurations()[row].task == "backup" {
            self.configurations!.getConfigurationsDataSource()![row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
            self.configurations!.setBatchYesNo(row)
        }
    }

}

extension  ViewControllertabSchedule: GetHiddenID {
    func gethiddenID() -> Int? {
        return self.hiddenID
    }
}

extension ViewControllertabSchedule: DismissViewController {

    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        self.infonexttask()
        self.operationsmethod()
    }
}

extension ViewControllertabSchedule: Reloadandrefresh {

    func reloadtabledata() {
        self.firstRemoteServer.stringValue = ""
        self.firstLocalCatalog.stringValue = ""
        self.secondRemoteServer.stringValue = ""
        self.secondLocalCatalog.stringValue = ""
        // Create a New schedules object
        self.schedulessorted = ScheduleSortedAndExpand()
        self.infoschedulessorted = InfoScheduleSortedAndExpand(sortedandexpanded: self.schedulessorted)
        self.firstScheduledTask.stringValue = self.infoschedulessorted!.whenIsNextTwoTasksString()[0]
        self.secondScheduledTask.stringValue = self.infoschedulessorted!.whenIsNextTwoTasksString()[1]
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

}

extension ViewControllertabSchedule: StartTimer {

    // Called from Process
    func startTimerNextJob() {
        self.schedulessorted = ScheduleSortedAndExpand()
        self.infoschedulessorted = InfoScheduleSortedAndExpand(sortedandexpanded: self.schedulessorted)
        self.firstRemoteServer.stringValue = ""
        self.firstLocalCatalog.stringValue = ""
        self.startTimer()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        self.infonexttask()
    }
}

// Deselect a row
extension ViewControllertabSchedule: DeselectRowTable {
    // deselect a row after row is deleted
    func deselect() {
        guard self.index != nil else { return }
        self.mainTableView.deselectRow(self.index!)
    }
}

extension ViewControllertabSchedule: SetProfileinfo {
    func setprofile(profile: String, color: NSColor) {
        globalMainQueue.async(execute: { () -> Void in
            self.profilInfo.stringValue = profile
            self.profilInfo.textColor = color
        })
    }
}
