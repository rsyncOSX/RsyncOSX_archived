//
//  ViewControllertabSchedule.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

// Protocol for notifying added Schedules
protocol  NewSchedules : class {
    func newSchedulesAdded()
}

// Protocol for restarting timer
protocol StartTimer : class {
    func startTimerNextJob()
}

class ViewControllertabSchedule: NSViewController {

    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var once: NSButton!
    @IBOutlet weak var daily: NSButton!
    @IBOutlet weak var weekly: NSButton!
    @IBOutlet weak var details: NSButton!

    // Index selected
    private var index: Int?
    // hiddenID
    fileprivate var hiddenID: Int?
    // Added schedules
    private var newSchedules: Bool?
    // Timer to count down when next scheduled backup is due. The timer just updates stringvalue in ViewController.
    // Another function is responsible to kick off the first scheduled operation.
    private var nextTask: Timer?
    // Scedules object
    fileprivate var schedules: ScheduleSortedAndExpand?
    // Delegate to inform new schedules added or schedules deleted
    weak var newSchedulesDelegate: NewSchedules?
    // Delegate function for starting next scheduled operatin if any
    // Delegate function is triggered when NSTaskDidTerminationNotification
    // is discovered (e.g previous job is done)
    weak var startnextjobDelegate: StartNextScheduledTask?

    // Information Schedule details
    // self.presentViewControllerAsSheet(self.ViewControllerScheduleDetails)
    lazy var viewControllerScheduleDetails: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardScheduleID"))
            as? NSViewController)!
    }()

    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    lazy var viewControllerUserconfiguration: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardUserconfigID"))
            as? NSViewController)!
    }()

    @IBOutlet weak var firstScheduledTask: NSTextField!
    @IBOutlet weak var secondScheduledTask: NSTextField!
    @IBOutlet weak var firstRemoteServer: NSTextField!
    @IBOutlet weak var secondRemoteServer: NSTextField!
    @IBOutlet weak var firstLocalCatalog: NSTextField!
    @IBOutlet weak var secondLocalCatalog: NSTextField!

    @IBAction func chooseSchedule(_ sender: NSButton) {

        let startdate: Date = Date()
        // Seconds from now to starttime
        let seconds: TimeInterval = self.stoptime.dateValue.timeIntervalSinceNow
        // Date and time for stop
        let stopdate: Date = self.stopdate.dateValue.addingTimeInterval(seconds)
        let secondsstart: TimeInterval = self.stopdate.dateValue.timeIntervalSinceNow
        var schedule: String?
        var details: Bool = false
        var range: Bool = false

        if self.index != nil {
            if self.once.state == .on {
                schedule = "once"
                if seconds > 0 {
                    range = true
                } else {
                    self.info(str: "Startdate has passed...")
                }
            } else if self.daily.state  == .on {
                schedule = "daily"
                if secondsstart >= (60*60*24) {
                    range = true
                } else {
                    self.info(str: "Startdate has to be more than 24 hours ahead...")
                }
            } else if self.weekly.state  == .on {
                schedule = "weekly"
                if secondsstart >= (60*60*24*7) {
                    range = true
                } else {
                    self.info(str: "Startdate has to be more than 7 days ahead...")
                }
            } else if self.details.state  == .on {
                // Details
                details = true
                globalMainQueue.async(execute: { () -> Void in
                     self.presentViewControllerAsSheet(self.viewControllerScheduleDetails)
                })
                self.details.state = .off
            }
            if details == false && range == true {
                self.addschedule(schedule: schedule!, startdate: startdate, stopdate: stopdate)
            }
            // Reset radiobuttons
            self.once.state = .off
            self.daily.state = .off
            self.weekly.state = .off
            self.details.state = .off
        }
    }

    private func addschedule(schedule: String, startdate: Date, stopdate: Date) {
        let answer = Alerts.dialogOKCancel("Add Schedule?", text: "Cancel or OK")
        if answer {
            Schedules.shared.addschedule(self.hiddenID!, schedule: schedule, start: startdate, stop: stopdate)
            self.newSchedules = true
            // Refresh table and recalculate the Schedules jobs
            self.refresh()
            // Start next job, if any, by delegate
            self.startnextjobDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            self.startnextjobDelegate?.startProcess()
            // Displaying next two scheduled tasks
            self.nextScheduledtask()
            // Call function to check if a scheduled backup is due for countdown
            self.startTimer()
        }
    }

    private func info(str: String) {
        self.firstLocalCatalog.textColor = .red
        self.firstLocalCatalog.stringValue = str
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerUserconfiguration)
        })
    }

    // First execution starts TODAY at time
    // Next execution starts after SCHEDULE 

    // Date for stopping services
    @IBOutlet weak var stopdate: NSDatePicker!
    // Time for stopping services
    @IBOutlet weak var stoptime: NSDatePicker!

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newSchedules = false
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        // Create a Schedules object
        self.schedules = ScheduleSortedAndExpand()
        // Setting reference to self.
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabschedule, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Set initial values of dates to now
        self.stopdate.dateValue = Date()
        self.stoptime.dateValue = Date()
        if self.schedules == nil {
            // Create a Schedules object
            self.schedules = ScheduleSortedAndExpand()
        }
        if Configurations.shared.configurationsDataSourcecountBackupOnlyCount() > 0 {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        // Displaying next two scheduled tasks
        self.nextScheduledtask()
        // Call function to check if a scheduled backup is due for countdown
        self.startTimer()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        if self.newSchedules! {
            self.newSchedules = false
            self.newSchedulesDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            // Notify new schedules are added
            self.newSchedulesDelegate?.newSchedulesAdded()
        }
    }

    // Start timer
    func startTimer() {
        // Find out if count down and update display
        if self.schedules != nil {
            let timer: Double = self.schedules!.startTimerseconds()
            // timer == 0 do not start NSTimer, timer > 0 update frequens of NSTimer
            if timer > 0 {
                self.nextTask?.invalidate()
                self.nextTask = nil
                // Update when next task is to be executed
                self.nextTask = Timer.scheduledTimer(timeInterval: timer, target: self, selector: #selector(nextScheduledtask), userInfo: nil, repeats: true)
            }
        }
    }

    // Update display next scheduled jobs in time
    @objc func nextScheduledtask() {
        guard self.schedules != nil else {
            return
        }
        // Displaying next two scheduled tasks
        self.firstLocalCatalog.textColor = .black
        self.firstScheduledTask.stringValue = self.schedules!.whenIsNextTwoTasksString()[0]
        self.secondScheduledTask.stringValue = self.schedules!.whenIsNextTwoTasksString()[1]
        if self.schedules!.remoteServerAndPathNextTwoTasks().count > 0 {
            if self.schedules!.remoteServerAndPathNextTwoTasks().count > 2 {
                self.firstRemoteServer.stringValue = self.schedules!.remoteServerAndPathNextTwoTasks()[0]
                self.firstLocalCatalog.stringValue = self.schedules!.remoteServerAndPathNextTwoTasks()[1]
                self.secondRemoteServer.stringValue = self.schedules!.remoteServerAndPathNextTwoTasks()[2]
                self.secondLocalCatalog.stringValue = self.schedules!.remoteServerAndPathNextTwoTasks()[3]
            } else {
                guard self.schedules!.remoteServerAndPathNextTwoTasks().count == 2 else {
                    return
                }
                self.firstRemoteServer.stringValue = self.schedules!.remoteServerAndPathNextTwoTasks()[0]
                self.firstLocalCatalog.stringValue = self.schedules!.remoteServerAndPathNextTwoTasks()[1]
                self.secondRemoteServer.stringValue = ""
                self.secondLocalCatalog.stringValue = ""
            }
        }
    }

    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            // Set index
            self.index = index
            let dict = Configurations.shared.getConfigurationsDataSourcecountBackupOnly()![index]
            self.hiddenID = dict.value(forKey: "hiddenID") as? Int
        } else {
            self.index = nil
            self.hiddenID = nil
        }
    }

}

extension ViewControllertabSchedule : NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return Configurations.shared.configurationsDataSourcecountBackupOnlyCount()
    }
}

extension ViewControllertabSchedule : NSTableViewDelegate {

    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let object: NSDictionary = Configurations.shared.getConfigurationsDataSourcecountBackupOnly()![row]
        var text: String?
        var schedule: Bool = false
        var number: Int?

        let hiddenID: Int = (object.value(forKey: "hiddenID") as? Int)!
        if Schedules.shared.hiddenIDinSchedule(hiddenID) {
            text = object[tableColumn!.identifier] as? String
            if text == "backup" || text == "restore" {
                schedule = true
            }
        }
        if tableColumn!.identifier.rawValue == "batchCellID" {
            return object[tableColumn!.identifier] as? Int!
        } else {
            if self.schedules != nil {
                number = self.schedules!.numberOfFutureSchedules(hiddenID)
            } else {
                number = 0
            }
            if schedule && number! > 0 {
                let returnstr = text! + " (" + String(number!) + ")"
                return returnstr
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
    }

    // Toggling batch
    @objc(tableView:setObjectValue:forTableColumn:row:) func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if Configurations.shared.getConfigurations()[row].task == "backup" {
            Configurations.shared.getConfigurationsDataSource()![row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
            Configurations.shared.setBatchYesNo(row)
        }
    }

}

extension  ViewControllertabSchedule: GetHiddenID {

    func gethiddenID() -> Int {
        return self.hiddenID!
    }

}

extension ViewControllertabSchedule: DismissViewController {

    // Function for dismissing a presented view
    // - parameter viewcontroller: the viewcontroller to be dismissed
    // Telling the view to dismiss any presented Viewcontroller
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllertabSchedule: AddProfiles {

    // Just reset the schedules
    func newProfile(new: Bool) {
        // Resetting the reference to ScheduleSortedAndExpand object.
        // New object is created when a new profile is loaded.
        self.schedules = nil
        self.firstRemoteServer.stringValue = ""
        self.firstLocalCatalog.stringValue = ""
        self.secondRemoteServer.stringValue = ""
        self.secondLocalCatalog.stringValue = ""
    }

    func enableProfileMenu() {
        // Nothing, just for complying to protocol
    }

}

extension ViewControllertabSchedule: RefreshtableView {

    func refresh() {
        if Configurations.shared.configurationsDataSourcecountBackupOnlyCount() > 0 {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        self.firstRemoteServer.stringValue = ""
        self.firstLocalCatalog.stringValue = ""
        self.secondRemoteServer.stringValue = ""
        self.secondLocalCatalog.stringValue = ""
        // Create a New schedules object
        self.schedules = nil
        self.schedules = ScheduleSortedAndExpand()
        // Displaying next two scheduled tasks
        self.firstScheduledTask.stringValue = self.schedules!.whenIsNextTwoTasksString()[0]
        self.secondScheduledTask.stringValue = self.schedules!.whenIsNextTwoTasksString()[1]
    }

}

extension ViewControllertabSchedule: StartTimer {

    // Called from Process
    func startTimerNextJob() {
        self.schedules = ScheduleSortedAndExpand()
        self.firstRemoteServer.stringValue = ""
        self.firstLocalCatalog.stringValue = ""
        self.startTimer()
    }
}
