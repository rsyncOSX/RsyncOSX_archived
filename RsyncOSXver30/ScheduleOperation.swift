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

// Class for starting scheduled task
class ScheduleOperation {
    
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

// Execute scheduled jobs
class executeTask : Operation {
    
    override func main() {
        // Delegate function for starting next scheduled operatin if any
        // Delegate function is triggered when NSTaskDidTerminationNotification 
        // is discovered (e.g previous job is done)
        weak var start_next_job_delegate:StartNextScheduledTask?
        // Delegate function for start and completion of scheduled jobs
        weak var notify_delegate : ScheduledJobInProgress?
        // Delegate to notify starttimer()
        weak var startTimer_delegate : StartTimer?
        
        // Variables used for rsync parameters
        let output = outputProcess()
        let job = rsyncProcess(notification: true)
        let getArguments = rsyncProcessArguments()
        var arguments:[String]?
        // var localCatalog:String?
        // var offsiteServer:String?
        // Dates
        // date is used as key for updating configuration with result of job
        var date:Date?
        // dateStart
        var dateStart:Date?
        // Schedule
        var schedule:String?
        // Observators
        var obs : NSObjectProtocol!
        // Index 
        var index:Int = -1
        // The config
        var config:configuration?
        
        // Get the first job of the queue
        if let dict:NSDictionary = SharingManagerSchedule.sharedInstance.scheduledJob {
            if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                notify_delegate = pvc
                notify_delegate?.start()
            }
            // Set the correct date style
            let dateformatter = Utils.sharedInstance.setDateformat()
            if let hiddenID:Int = dict.value(forKey: "hiddenID") as? Int {
                
                let store:[configuration] = storeAPI.sharedInstance.getConfigurations()
                config = store.filter({return ($0.hiddenID == hiddenID)})[0]
                date = dict.value(forKey: "start") as? Date
                dateStart = dict.value(forKey: "dateStart") as? Date
                schedule = dict.value(forKey: "schedule") as? String
                
                if (hiddenID >= 0 && config != nil) {
                    
                    arguments = getArguments.argumentsRsync(config!, dryRun: false, forDisplay: false)
                    index = SharingManagerConfiguration.sharedInstance.getIndex(hiddenID)
                    
                    // localCatalog = config!.localCatalog
                    // offsiteServer = config!.offsiteServer
                    
                    // Start NSTaskDidTerminationNotification
                    obs = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: nil, queue: nil) {
                        notification -> Void in
                        // Remove observer
                        NotificationCenter.default.removeObserver(obs)
                        // Write result to Schedule
                        let datestring = dateformatter.string(from: date!)
                        let dateStartstring = dateformatter.string(from: dateStart!)
                        let numberstring = output.statistics()
                        SharingManagerSchedule.sharedInstance.addScheduleResult(hiddenID, dateStart: dateStartstring, result: numberstring[0], date: datestring, schedule: schedule!)
                        // Writing timestamp to configuration
                        // Update memory configuration with rundate
                        _ = SharingManagerConfiguration.sharedInstance.setCurrentDateonConfiguration(index)
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
                    // End Process.didTerminateNotification
                    
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
