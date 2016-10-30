//
//  ScheduleTaskOperation.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 07/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Protocol for starting next scheduled job
protocol StartNextScheduledTask : class {
    func startProcess()
}

// Protocol inform about Scheduled task
protocol scheduledTask : class {
    func notifyScheduledTask(config:configuration)
}

// Protocol when a Scehduled job is starting and stopping
// USed to informed the presenting viewcontroller about what
// is going on
protocol ScheduledJobInProgress : class {
    func start()
    func completed()
    func notifyScheduledJob(config:configuration?)
}

// Class for starting scheduled task
final class ScheduleOperation {
    
    let schedules:ScheduleSortedAndExpand?
    var waitForTask : Timer?
    var queue : OperationQueue?
    
    @objc private func startJob() {
        // Start the task in BackgroundQueue
        // The Process itself is executed in GlobalMainQueue
        GlobalBackgroundQueue.async(execute: {
            let queue = OperationQueue()
            let task = executeTask()
            queue.addOperation(task)
        })
    }
    
    init () {
        SharingManagerSchedule.sharedInstance.cancelJobWaiting()
        // Create a new Schedules object
        self.schedules = ScheduleSortedAndExpand()
        // Removes the job of the stack
        if let dict = self.schedules!.jobToExecute() {
            let dateStart:Date = dict.value(forKey: "start") as! Date
            let secondsToWait:Double = self.schedules!.timeDoubleSeconds(dateStart, enddate: nil)
            self.waitForTask = Timer.scheduledTimer(timeInterval: secondsToWait, target: self, selector: #selector(startJob), userInfo: nil, repeats: false)
            // Set reference to Timer that kicks of the Scheduled job
            // Reference is set for cancel job if requiered
            SharingManagerSchedule.sharedInstance.setJobWaiting(timer: self.waitForTask!)
        } 
    }
}

// Class for completion of Operation objects when Process object termination
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
    
    // Function for completing the Scheduled job
    // The Operation object sets reference to the completeScheduledOperation in SharingManagerConfiguration.sharedInstance.operation
    // This function is executed when rsyn process terminates
    func complete(output:outputProcess) {
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
            start_next_job_delegate = pvc2
            notify_delegate = pvc2
            start_next_job_delegate?.startProcess()
            notify_delegate?.completed()
        }
        if let pvc3 = SharingManagerSchedule.sharedInstance.ViewObjectSchedule as? ViewControllertabSchedule {
            startTimer_delegate = pvc3
            startTimer_delegate?.startTimerNextJob()
        }
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

// Execute scheduled jobs
class executeTask : Operation {
    
    override func main() {
        // Delegate function for start and completion of scheduled jobs
        weak var notify_delegate : ScheduledJobInProgress?
        // Variables used for rsync parameters
        let output = outputProcess()
        let job = rsyncProcess(notification: true, tabMain: false, command : nil)
        let getArguments = rsyncProcessArguments()
        var arguments:[String]?
        var config:configuration?
        
        // Get the first job of the queue
        if let dict:NSDictionary = SharingManagerSchedule.sharedInstance.scheduledJob {
            if let hiddenID:Int = dict.value(forKey: "hiddenID") as? Int {
                let store:[configuration] = storeAPI.sharedInstance.getConfigurations()
                config = store.filter({return ($0.hiddenID == hiddenID)})[0]
                guard (config != nil) else {
                    if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                        notify_delegate = pvc
                        notify_delegate?.notifyScheduledJob(config: nil)
                    }
                    return
                }
                // Notify that scheduled task is executing
                if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                    notify_delegate = pvc
                    notify_delegate?.start()
                    notify_delegate?.notifyScheduledJob(config: config)
                }
                
                if (hiddenID >= 0 && config != nil) {
                    arguments = getArguments.argumentsRsync(config!, dryRun: false, forDisplay: false)
                    // Setting reference to finalize the job
                    // Finalize job is done when rsynctask ends (in process termination)
                    SharingManagerConfiguration.sharedInstance.operation = completeScheduledOperation(dict: dict)
                    // Start the rsync job
                    GlobalMainQueue.async(execute: {
                        if (arguments != nil) {
                            job.executeProcess(arguments!, output: output)
                        }
                    })
                }
            }
        }
    }
}
