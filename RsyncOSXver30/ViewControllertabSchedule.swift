//
//  ViewControllertabSchedule.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

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

class ViewControllertabSchedule : NSViewController {
    
    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var once: NSButton!
    @IBOutlet weak var daily: NSButton!
    @IBOutlet weak var weekly: NSButton!
    @IBOutlet weak var details: NSButton!
    
    // Index selected
    private var index:Int?
    // hiddenID
    fileprivate var hiddenID:Int?
    // Added schedules
    private var newSchedules:Bool?
    // Timer to count down when next scheduled backup is due.
    // The timer just updates stringvalue in ViewController.
    // Another function is responsible to kick off the first
    // scheduled operation.
    private var nextTask : Timer?
    // Scedules object
    fileprivate var schedules : ScheduleSortedAndExpand?
    
    // Delegates
    // Delegate to inform new schedules added or schedules deleted
    weak var newSchedules_delegate:NewSchedules?
    // Delegate function for starting next scheduled operatin if any
    // Delegate function is triggered when NSTaskDidTerminationNotification
    // is discovered (e.g previous job is done)
    weak var start_next_job_delegate:StartNextScheduledTask?
    
    // Information Schedule details
    // self.presentViewControllerAsSheet(self.ViewControllerScheduleDetails)
    lazy var ViewControllerScheduleDetails: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardScheduleID")
            as! NSViewController
    }()
    
    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    lazy var ViewControllerUserconfiguration: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardUserconfigID")
            as! NSViewController
    }()

    @IBOutlet weak var firstScheduledTask: NSTextField!
    @IBOutlet weak var secondScheduledTask: NSTextField!
    @IBOutlet weak var firstRemoteServer: NSTextField!
    @IBOutlet weak var secondRemoteServer: NSTextField!
    @IBOutlet weak var firstLocalCatalog: NSTextField!
    @IBOutlet weak var secondLocalCatalog: NSTextField!
    
    
    @IBAction func chooseSchedule(_ sender: NSButton) {
        
        // Date and time for start
        let startdate:Date = self.stoptime.dateValue
        // Seconds from now to starttime
        let seconds:TimeInterval = self.stoptime.dateValue.timeIntervalSinceNow
        // Date and time for stop
        let stopdate:Date = self.stopdate.dateValue.addingTimeInterval(seconds)
        var schedule:String?
        var details:Bool = false
        
        if (self.index != nil) {
            if (self.once.state == 1) {
                schedule = "once"
            } else if (self.daily.state == 1) {
                schedule = "daily"
            } else if (self.weekly.state == 1) {
                schedule = "weekly"
            } else if (self.details.state == 1) {
                // Details
                details = true
                GlobalMainQueue.async(execute: { () -> Void in
                     self.presentViewControllerAsSheet(self.ViewControllerScheduleDetails)
                })
            }
            
            if (details == false) {
                let answer = Alerts.dialogOKCancel("Add Schedule?", text: "Cancel or OK")
                if (answer) {
                    SharingManagerSchedule.sharedInstance.addScheduleData(self.hiddenID!, schedule: schedule!, start: startdate, stop: stopdate)
                    self.newSchedules = true
                    // Refresh table and recalculate the Schedules jobs
                    self.refreshInSchedule()
                    self.startTimer()
                    // Start next job, if any, by delegate
                    if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                        start_next_job_delegate = pvc
                        start_next_job_delegate?.startProcess()
                    }
                }
            }
        }
    }
    
    // Userconfiguration button
    @IBAction func Userconfiguration(_ sender: NSButton) {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
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
        SharingManagerConfiguration.sharedInstance.ScheduleObjectMain = self
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Set initial values of dates to now
        self.stopdate.dateValue = Date()
        self.stoptime.dateValue = Date()
        if (self.schedules == nil) {
            // Create a Schedules object
            self.schedules = ScheduleSortedAndExpand()
        }
        if (SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecountBackupOnlyCount() > 0 ) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        // Displaying next two scheduled tasks
        self.nextScheduledtask()
        // Call function to check if a scheduled backup is due for countdown
        self.startTimer()
        // Reference to self
        SharingManagerSchedule.sharedInstance.ViewObjectSchedule = self
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        if (self.newSchedules!) {
            self.newSchedules = false
            if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                self.newSchedules_delegate = pvc
                // Notify new schedules are added
                self.newSchedules_delegate?.newSchedulesAdded()
            }
        }
    }
    
    // Start timer
    func startTimer() {
        // Find out if count down and update display
        if (self.schedules != nil) {
            let timer:Double = self.schedules!.startTimerseconds()
            // timer == 0 do not start NSTimer, timer > 0 update frequens of NSTimer
            if (timer > 0) {
                self.nextTask?.invalidate()
                self.nextTask = nil
                // Update when next task is to be executed
                self.nextTask = Timer.scheduledTimer(timeInterval: timer, target: self, selector: #selector(nextScheduledtask), userInfo: nil, repeats: true)
            }
        }
    }
    
    // Update display next scheduled jobs in time
    func nextScheduledtask() {
        if (self.schedules != nil) {
            // Displaying next two scheduled tasks
            self.firstScheduledTask.stringValue = (self.schedules?.whenIsNextTwoTasksString()[0])!
            self.secondScheduledTask.stringValue = (self.schedules?.whenIsNextTwoTasksString()[1])!
            if ((self.schedules?.remoteServerAndPathNextTwoTasks().count)! > 0) {
                if ((self.schedules?.remoteServerAndPathNextTwoTasks().count)! > 2) {
                    self.firstRemoteServer.stringValue = (self.schedules?.remoteServerAndPathNextTwoTasks()[0])!
                    self.firstLocalCatalog.stringValue = (self.schedules?.remoteServerAndPathNextTwoTasks()[1])!
                    self.secondRemoteServer.stringValue = (self.schedules?.remoteServerAndPathNextTwoTasks()[2])!
                    self.secondLocalCatalog.stringValue = (self.schedules?.remoteServerAndPathNextTwoTasks()[3])!
                } else {
                    self.firstRemoteServer.stringValue = (self.schedules?.remoteServerAndPathNextTwoTasks()[0])!
                    self.firstLocalCatalog.stringValue = (self.schedules?.remoteServerAndPathNextTwoTasks()[1])!
                    self.secondRemoteServer.stringValue = ""
                    self.secondLocalCatalog.stringValue = ""
                }
                
            }
        }
    }
    
    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = notification.object as! NSTableView
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            // Set index
            self.index = index
            let dict = SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly()![index]
            self.hiddenID = dict.value(forKey: "hiddenID") as? Int
        } else {
            self.index = nil
            self.hiddenID = nil
        }
    }
    
}

extension ViewControllertabSchedule : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecountBackupOnlyCount()
    }
}

extension ViewControllertabSchedule : NSTableViewDelegate {
    
    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let object : NSDictionary = SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly()![row]
        var text:String?
        var schedule :Bool = false
        var number:Int?
        
        let hiddenID:Int = (object.value(forKey: "hiddenID") as? Int)!
        if SharingManagerSchedule.sharedInstance.hiddenIDinSchedule(hiddenID) {
            text = object[tableColumn!.identifier] as? String
            if (text == "backup" || text == "restore") {
                schedule = true
            }
        }
        if ((tableColumn!.identifier) == "batchCellID") {
            return object[tableColumn!.identifier] as? Int!
        } else {
            if (self.schedules != nil) {
                number = self.schedules!.numberOfFutureSchedules(hiddenID)
            } else {
                number = 0
            }
            if (schedule && number! > 0) {
                let returnstr = text! + " (" + String(number!) + ")"
                return returnstr
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
    }
    
    // Toggling batch
    @objc(tableView:setObjectValue:forTableColumn:row:) func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if (SharingManagerConfiguration.sharedInstance.getConfigurations()[row].task == "backup") {
            SharingManagerConfiguration.sharedInstance.getConfigurationsDataSource()![row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
            SharingManagerConfiguration.sharedInstance.setBatchYesNo(row)
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
    func dismiss_view(viewcontroller:NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllertabSchedule: AddProfiles {
    
    // Just reset the schedules
    func newProfile() {
        self.schedules = nil
        self.firstRemoteServer.stringValue = ""
        self.firstLocalCatalog.stringValue = ""
        self.secondRemoteServer.stringValue = ""
        self.secondLocalCatalog.stringValue = ""
        // Must unload Schedule data before new Profile is loaded.
        SharingManagerSchedule.sharedInstance.resetSchedule()
    }
    
    func enableProfileMenu() {
        // Nothing, just for complying to protocol
    }

}

extension ViewControllertabSchedule: RefreshtableViewtabSchedule {
    
    func refreshInSchedule() {
        if (SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecountBackupOnlyCount() > 0 ) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        // Create a New schedules object
        self.schedules = nil
        self.schedules = ScheduleSortedAndExpand()
        // Displaying next two scheduled tasks
        self.firstScheduledTask.stringValue = (self.schedules?.whenIsNextTwoTasksString()[0])!
        self.secondScheduledTask.stringValue = (self.schedules?.whenIsNextTwoTasksString()[1])!
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

