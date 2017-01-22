//
//  completeScheduledOperation.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

// Class for completion of Operation objects when Process object termination.
// The object does also kicks of next scheduled job by setting new
// waiter time.
final class completeScheduledOperation {
    
    // Delegate function for starting next scheduled operatin if any
    // Delegate function is triggered when NSTaskDidTerminationNotification
    // is discovered (e.g previous job is done)
    weak var start_next_job_delegate:StartNextScheduledTask?
    // Delegate function for start and completion of scheduled jobs
    weak var notify_delegate : ScheduledJobInProgress?
    // Delegate to notify starttimer()
    weak var startTimer_delegate : StartTimer?
    // Initialize variables
    private var date:Date?
    private var dateStart:Date?
    private var dateformatter:DateFormatter?
    private var hiddenID:Int?
    private var schedule:String?
    private var index:Int?
    
    // Function for finalizing the Scheduled job
    // The Operation object sets reference to the completeScheduledOperation in SharingManagerConfiguration.sharedInstance.operation
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(output:outputProcess) {
        // Write result to Schedule
        let datestring = self.dateformatter!.string(from: date!)
        let dateStartstring = self.dateformatter!.string(from: dateStart!)
        let numberstring = output.statistics(numberOfFiles: nil)
        SharingManagerSchedule.sharedInstance.addScheduleResult(self.hiddenID!, dateStart: dateStartstring, result: numberstring[0], date: datestring, schedule: schedule!)
        // Writing timestamp to configuration
        // Update memory configuration with rundate
        _ = SharingManagerConfiguration.sharedInstance.setCurrentDateonConfiguration(self.index!)
        // Saving updated configuration from memory
        _ = storeAPI.sharedInstance.saveConfigFromMemory()
        // Start next job, if any, by delegate
        // and notify completed, by delegate
        if let pvc2 = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
            GlobalMainQueue.async(execute: { () -> Void in
                self.start_next_job_delegate = pvc2
                self.notify_delegate = pvc2
                self.start_next_job_delegate?.startProcess()
                self.notify_delegate?.completed()
            })
            
        }
        if let pvc3 = SharingManagerSchedule.sharedInstance.ViewObjectSchedule as? ViewControllertabSchedule {
            GlobalMainQueue.async(execute: { () -> Void in
                self.startTimer_delegate = pvc3
                self.startTimer_delegate?.startTimerNextJob()
            })
        }
        // Reset reference til scheduled job
        SharingManagerSchedule.sharedInstance.scheduledJob = nil
    }
    
    init (dict : NSDictionary) {
        self.date = dict.value(forKey: "start") as? Date
        self.dateStart = dict.value(forKey: "dateStart") as? Date
        self.dateformatter = Utils.sharedInstance.setDateformat()
        self.hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
        self.schedule = dict.value(forKey: "schedule") as? String
        self.index = SharingManagerConfiguration.sharedInstance.getIndex(hiddenID!)
    }
}
