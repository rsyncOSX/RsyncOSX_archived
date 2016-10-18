//
//  SharingManagerSchedule.swift
//  RsyncOSX
//
//  This object stays in memory runtime and holds key data and operations on Schedules.
//  The obect is the model for the Schedules but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  Created by Thomas Evensen on 09/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

// Protocol for doing a refresh of updated tableView
protocol RefreshtableViewtabSchedule : class {
    func refreshInSchedule()
}

class SharingManagerSchedule {    

    // Creates a singelton of this class
    class var  sharedInstance: SharingManagerSchedule {
        struct Singleton {
            static let instance = SharingManagerSchedule()
        }
        return Singleton.instance
    }
    
    // CONFIGURATIONS RSYNCOSX
    
    // Reference to Timer in scheduled operation
    // Used to terminate scheduled jobs
    private var waitForTask : Timer?
    // Variabl if Schedule data must be is changed and must bed read into memory again
    var ScheduleIsDirty:Bool = true
    // Reference to the first Scheduled job
    // Is set when SortedAndExpanded is calculated
    var scheduledJob:NSDictionary?
    // Reference to NSViewObjects requiered for protocol functions for kikcking of scheduled jobs
    var ViewObjectSchedule: NSViewController?
    // Delegate functions
    weak var refresh_delegate:RefreshtableViewtabMain?
    
    // DATA STRUCTURE
    
    // Array to store all scheduled jobs and history of executions
    // Will be kept in memory until destroyed
    private var Schedule = [configurationSchedule]()

    // THE GETTERS
    
    // Return reference to Schedule data
    // self.Schedule is privat data
    func getSchedule()-> [configurationSchedule] {
        return self.Schedule
    }
    
    // CLEANING FUNCTION 
    
    // Function to clean all Schedules and scheduled job
    // Cleans everything
    func cleanAllSchedules() {
        self.cancelJobWaiting()
        self.destroySchedule()
        self.ScheduleIsDirty = true
    }
    
    // DESTROY FUNCTIONS
    private func destroySchedule() {
        self.Schedule.removeAll()
    }
    
    /// Function for setting reference to waiting job e.g. to the timer.
    /// Used to invalidate timer (cancel waiting job)
    /// - parameter timer: the NSTimer object
    func setJobWaiting (timer:Timer) {
        self.waitForTask = timer
    }
    
    /// Function for canceling next job waiting for execution.
    func cancelJobWaiting () {
        print("Cancel job")
        self.waitForTask?.invalidate()
    }
        
    /// Function for reading all jobs for schedule and all history of past executions.
    /// Schedules are stored in self.Schedule.
    /// If Schedule already in memory AND not dirty do not read them again. If Schedule is 
    /// dirty, clean memory and read all Shedules into memory.
    /// The Schedules stored in memory is only the plan for each task. E.g for
    /// task 1 the plan is Scheduled backup every day from date until date at time
    /// every day. The actual Schedules are computed (expanded and sorted) in 
    /// another object based upon the plan for Schedules. It is only the plans
    /// which are stored to permanent store.
    /// The functions does NOT cancel waiting jobs or recalculate next scheduled job.
    func getAllSchedules() {
        var store:[configurationSchedule]?
        store = storeAPI.sharedInstance.getScheduleandhistory()
        // If Schedule already in memory dont read them again
        // Schedules are only read into memory if Dirty
        
        if store != nil {
            var data:[configurationSchedule] = [configurationSchedule]()
            // Deleting any existing Schedule
            self.destroySchedule()
            // Reading new schedule into memory
            for i in 0 ..< store!.count {
                data.append(store![i])
            }
            // Sorting schedule after hiddenID
            data.sort { (schedule1, schedule2) -> Bool in
                if (schedule1.hiddenID > schedule2.hiddenID) {
                    return true
                } else {
                    return false
                }
            }
            // Setting self.Schedule as data
            self.Schedule = data
        }
    }

    
    /// Function adds new Shcedules (plans). Functions writes
    /// schedule plans to permanent store.
    /// - parameter hiddenID: hiddenID for task
    /// - parameter schedule: schedule
    /// - parameter start: start date and time
    /// - parameter stop: stop date and time
    func addScheduleData (_ hiddenID: Int, schedule : String, start: Date, stop: Date) {
        let dateformatter = Utils.sharedInstance.setDateformat()
        let dict = NSMutableDictionary()
        dict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
        dict.setObject(dateformatter.string(from: start), forKey: "dateStart" as NSCopying)
        dict.setObject(dateformatter.string(from: stop), forKey: "dateStop" as NSCopying)
        dict.setObject(schedule, forKey: "schedule" as NSCopying)
        let newSchedule = configurationSchedule(dictionary: dict, executed: nil)
        self.Schedule.append(newSchedule)
        // Set data dirty
        SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        storeAPI.sharedInstance.saveScheduleFromMemory()
    }

    /// Function is reading Schedule plans and transform plans to 
    /// array of NSDictionary. Used for presenting Schedule in tableViews
    /// - returns : array of Schedules
    func getScheduleAsNSDictionary () -> [NSDictionary] {
        var data = [NSDictionary]()
        for i in 0 ..< self.Schedule.count {
            if self.Schedule[i].dateStop != nil {
                if (self.Schedule[i].schedule != "stopped") {
                    let dict :NSDictionary = [
                        "dateStart": self.Schedule[i].dateStart,
                        "dateStop": self.Schedule[i].dateStop!,
                        "hiddenID": self.Schedule[i].hiddenID,
                        "schedule": self.Schedule[i].schedule
                    ]
                    data.append(dict as NSDictionary)
                }
            }
        }
        return data
    }
    
    /// Function deletes all Schedules by hiddenID. Invoked when Configurations are
    /// deleted. When a Configuration are deleted all tasks connected to
    /// Configuration has to  be deleted.
    /// - parameter hiddenID : hiddenID for task
    func deleteSchedulesbyHiddenID(hiddenID : Int) {
        var delete : Bool = false
        for i in 0 ..< self.Schedule.count {
            if (self.Schedule[i].hiddenID == hiddenID) {
                // Mark Schedules for delete
                // Cannot delete in memory, index out of bound is result
                self.Schedule[i].delete = true
                delete = true
            }
        }
        if (delete) {
            storeAPI.sharedInstance.saveScheduleFromMemory()
            // Send message about refresh tableView
            self.doaRefreshTableviewMain()
        }
    }
    
    /// Function reads all Schedule data for one task by hiddenID
    /// - parameter hiddenID : hiddenID for task
    /// - returns : array of Schedules
    func readScheduledata (_ hiddenID : Int) -> [NSMutableDictionary] {
        
        var row: NSMutableDictionary
        var data : [NSMutableDictionary] = []
        
        for i in 0 ..< self.Schedule.count {
            if (self.Schedule[i].hiddenID == hiddenID) {
                row = [
                    "dateStart": self.Schedule[i].dateStart,
                    "stopCellID":0,
                    "deleteCellID":0,
                    "dateStop":"",
                    "schedule":self.Schedule[i].schedule,
                    "hiddenID":Schedule[i].hiddenID
                ]
                if (self.Schedule[i].dateStop == nil) {
                    row.setValue("no stop date", forKey: "dateStop")
                } else {
                    row.setValue(self.Schedule[i].dateStop, forKey: "dateStop")
                }
                if (self.Schedule[i].schedule == "stopped") {
                    row.setValue(1, forKey: "stopCellID")
                }
                data.append(row)
            }
        }
        return data
    }
    
    /// Function either deletes or stops Schedules.
    /// - parameter data : array of Schedules which some of them are either marked for stop or delete
    func deleteOrStopSchedules (data:[NSMutableDictionary]) {
    
        var update:Bool = false
        
        if (data.count) > 0 {
            
            let hiddenID = data[0].value(forKey: "hiddenID") as? Int
            let stop = data.filter({ return (($0.value(forKey: "stopCellID") as? Int) == 1)})
            let delete = data.filter({ return (($0.value(forKey: "deleteCellID") as? Int) == 1)})
           
            // Delete Schedules
            if (delete.count > 0) {
                update = true
                for i in 0 ..< delete.count {
                    self.delete(dict: delete[i])
                }
            }
            // Stop Schedules
            if (stop.count > 0) {
                update = true
                for i in 0 ..< stop.count {
                    self.stop(dict: stop[i])
                }
                // Computing new parent key before saving to disk.
                self.updateExecutedNewKey(hiddenID!)
            }
            if (update) {
                // Saving the resulting data file
                storeAPI.sharedInstance.saveScheduleFromMemory()
                // Send message about refresh tableView
                self.doaRefreshTableviewMain()
            }
        }
    }
    
    // Test if Schedule record in memory is set to delete or not
    private func delete (dict:NSDictionary) {
        loop :  for i in 0 ..< self.Schedule.count {
            if dict.value(forKey: "hiddenID") as? Int == self.Schedule[i].hiddenID {
                if (dict.value(forKey: "dateStop") as? String == self.Schedule[i].dateStop || self.Schedule[i].dateStop == nil &&
                    dict.value(forKey: "schedule") as? String == self.Schedule[i].schedule &&
                    dict.value(forKey: "dateStart") as? String == self.Schedule[i].dateStart) {
                    self.Schedule[i].delete = true
                    break
                }
            }
        }
    }
    
    // Test if Schedule record in memory is set to stop er not
    private func stop (dict:NSDictionary) {
        loop :  for i in 0 ..< self.Schedule.count {
            if (dict.value(forKey: "hiddenID") as? Int == self.Schedule[i].hiddenID) {
                if (dict.value(forKey: "dateStop") as? String == self.Schedule[i].dateStop || self.Schedule[i].dateStop == nil &&
                    dict.value(forKey: "schedule") as? String == self.Schedule[i].schedule &&
                    dict.value(forKey: "dateStart") as? String == self.Schedule[i].dateStart) {
                    self.Schedule[i].schedule = "stopped"
                    break
                }
            }
         
        }
    }
    
    
    // Protocol function
    // Send message to main view do a refresh of table
    private func doaRefreshTableviewMain() {
        // Send message about refresh tableView
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
            self.refresh_delegate = pvc
            self.refresh_delegate?.refreshInMain()
        }
    }
    
    // Check if hiddenID is in Scheduled tasks
    func hiddenIDinSchedule (_ hiddenID : Int) -> Bool {
        let result = self.Schedule.filter({return ($0.hiddenID == hiddenID && $0.dateStop != nil)})
        if result.isEmpty {
            return false
        } else {
            return true
        }
    }
        
    /// Function adds results of task to file (via memory). Memory are
    /// saved after changed. Used in either single tasks or batch.
    /// - parameter hiddenID : hiddenID for task
    /// - parameter result : String representation of result
    /// - parameter date : String representation of date and time stamp
    func addScheduleResultManuel(_ hiddenID: Int, result : String) {
        // Set the current date
        let currendate = Date()
        let dateformatter = Utils.sharedInstance.setDateformat()
        let date = dateformatter.string(from: currendate)
        
        if (SharingManagerConfiguration.sharedInstance.detailedlogging) {
            var inserted:Bool = false
            for i in 0 ..< self.Schedule.count {
                // Add record only to record with no enddate
                if (SharingManagerConfiguration.sharedInstance.gettask(hiddenID) == "backup") {
                    if (self.Schedule[i].hiddenID == hiddenID  && self.Schedule[i].schedule == "manuel" && self.Schedule[i].dateStop == nil) {
                        let dict = NSMutableDictionary()
                        dict.setObject(date, forKey: "dateExecuted" as NSCopying)
                        dict.setObject(result, forKey: "resultExecuted" as NSCopying)
                        let dictKey:NSDictionary = [
                            "dateStart":self.Schedule[i].dateStart,
                            "schedule":self.Schedule[i].schedule,
                            "hiddenID":self.Schedule[i].hiddenID]
                        
                        let parent : String = self.computeKey(dictKey)
                        dict.setValue(parent, forKey: "parent")
                        self.Schedule[i].executed.append(dict)
                        inserted = true
                    }
                }
            }
            // Record does not exist, create new Schedule (not inserted)
            if (inserted == false) {
                if (SharingManagerConfiguration.sharedInstance.gettask(hiddenID) == "backup") {
                    let masterdict = NSMutableDictionary()
                    masterdict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
                    masterdict.setObject(date, forKey: "dateStart" as NSCopying)
                    masterdict.setObject("manuel", forKey: "schedule" as NSCopying)
                    
                    let dict = NSMutableDictionary()
                    dict.setObject(date, forKey: "dateExecuted" as NSCopying)
                    dict.setObject(result, forKey: "resultExecuted" as NSCopying)
                    
                    // Compute key to parent
                    // Just to pass schedule in dictionary, no saved but used for computing key to parent
                    let parent : String = self.computeKey(masterdict)
                    dict.setValue(parent, forKey: "parent")
                    
                    let executed = NSMutableArray()
                    executed.add(dict)
                    let newSchedule = configurationSchedule(dictionary: masterdict, executed: executed)
                    self.Schedule.append(newSchedule)
                    // Set insetred true to force write of record
                    inserted = true
                }
            }
            if (inserted) {
               storeAPI.sharedInstance.saveScheduleFromMemory()
            }
        }
    }
    
    /// Function adds results of task to file (via memory). Memory are
    /// saved after changed. Used in either single tasks or batch.
    /// - parameter hiddenID : hiddenID for task
    /// - parameter dateStart : String representation of date and time stamp start schedule
    /// - parameter result : String representation of result
    /// - parameter date : String representation of date and time stamp for task executed
    /// - parameter schedule : schedule of task
    func addScheduleResult(_ hiddenID: Int, dateStart : String, result : String, date: String, schedule : String) {
        if (SharingManagerConfiguration.sharedInstance.detailedlogging) {
            loop : for i in 0 ..< self.Schedule.count {
                if (self.Schedule[i].hiddenID == hiddenID  &&
                    self.Schedule[i].schedule == schedule &&
                    self.Schedule[i].dateStart == dateStart) {
                    if (SharingManagerConfiguration.sharedInstance.gettask(hiddenID) == "backup") {
                        let dict = NSMutableDictionary()
                        dict.setObject(date, forKey: "dateExecuted" as NSCopying)
                        dict.setObject(result, forKey: "resultExecuted" as NSCopying)
                        // Compute key to parent
                        // Just to pass schedule in dictionary, no saved but used for computing key to parent
                        let dictKey:NSDictionary = [
                            "dateStart":self.Schedule[i].dateStart,
                            "schedule":self.Schedule[i].schedule,
                            "hiddenID":self.Schedule[i].hiddenID
                        ]
                        let parent : String = self.computeKey(dictKey)
                        dict.setValue(parent, forKey: "parent")
                        self.Schedule[i].executed.append(dict)
                        storeAPI.sharedInstance.saveScheduleFromMemory()
                        break loop
                    }
                }
            }
        }
    }
    
    
    // Computing key for checking of parent.
    // Parent key is stored in executed dictionary
    func computeKey (_ dict : NSDictionary) -> String {
        var key:String?
        let hiddenID:Int = (dict.value(forKey: "hiddenID") as? Int)!
        let schedule:String = (dict.value(forKey: "schedule") as? String)!
        let dateStart:String = (dict.value(forKey: "dateStart") as? String)!
        key = String(hiddenID) + schedule + dateStart
        return key!
    }
    
    func checkKey (_ dict1 : NSDictionary, dict2 : NSDictionary) -> Bool {
        let keyexecute = dict1.value(forKey: "parent") as? String
        let keyparent = self.computeKey(dict2)
        
        if (keyparent == keyexecute) {
            return true
        } else {
            return false
        }
    }
    
    // Returning the set of executed tasks for å schedule.
    // Used for recalcutlate the parent key when task change schedule
    // from active to "stopped"
    private func getScheduleExecuted (_ hiddenID:Int) -> [NSMutableDictionary]? {
        var result = self.Schedule.filter({return ($0.hiddenID == hiddenID) && ($0.schedule == "stopped")})
        if result.count > 0 {
            let schedule = result.removeFirst()
            return schedule.executed
        } else {
            return nil
        }
    }
    
    // Computing new parentkeys AFTER new schedule is updated.
    // Returning set updated keys
    private func computeNewParentKeys (_ hiddenID:Int) -> [NSMutableDictionary]? {
        var dict:NSMutableDictionary?
        var result = self.Schedule.filter({return ($0.hiddenID == hiddenID) && ($0.schedule == "stopped")})
        var executed:[NSMutableDictionary]?
        if result.count > 0 {
            let scheduleConfig = result[0]
            
            dict = [
                "hiddenID":scheduleConfig.hiddenID,
                "schedule":scheduleConfig.schedule,
                "dateStart":scheduleConfig.dateStart
            ]
            
            if let dicts = self.getScheduleExecuted(hiddenID) {
                for i in 0 ..< dicts.count {
                    let key = self.computeKey(dict!)
                    dicts[i].setValue(key, forKey: "parent")
                }
                executed = dicts
            }
        }
        return executed
    }
    
    // Setting updated executes to schedule.
    // Used when a group is set from active to "stopped"
    private func updateExecutedNewKey (_ hiddenID:Int) {
        let executed:[NSMutableDictionary]? = self.computeNewParentKeys(hiddenID)
        loop : for i in 0 ..< self.Schedule.count {
            if self.Schedule[i].hiddenID == hiddenID {
                if executed != nil {
                    self.Schedule[i].executed = executed!
                }
                break loop
            }
        }
    }

}

