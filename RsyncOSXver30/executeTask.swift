//
//  executeTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

// The Operation object to execute a scheduled job.
// The object get the hiddenID for the job, reads the
// rsync parameters for the job, creates a object to finalize the
// job after execution as logging. The reference to the finalize object
// is set in the static object. The finalize object is invoked
// when the job discover (observs) the termination of the process.

class executeTask : Operation {
    
    override func main() {
        // Delegate function for start and completion of scheduled jobs
        weak var notify_delegate : ScheduledJobInProgress?
        // Variables used for rsync parameters
        let output = outputProcess()
        let job = RsyncProcess(operation: true, tabMain: false, command : nil)
        var arguments:[String]?
        var config:configuration?
        
        // Get the first job of the queue
        if let dict:NSDictionary = SharingManagerSchedule.sharedInstance.scheduledJob {
            if let hiddenID:Int = dict.value(forKey: "hiddenID") as? Int {
                let store:[configuration] = persistentStoreAPI.sharedInstance.getConfigurations()
                let configArray = store.filter({return ($0.hiddenID == hiddenID)})
                
                guard configArray.count > 0 else {
                    if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                        notify_delegate = pvc
                        if (SharingManagerConfiguration.sharedInstance.allowNotifyinMain == true) {
                            notify_delegate?.notifyScheduledJob(config: nil)
                        }
                    }
                    return
                }
                
                config = configArray[0]
                
                guard (config != nil) else {
                    if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                        notify_delegate = pvc
                        if (SharingManagerConfiguration.sharedInstance.allowNotifyinMain == true) {
                            notify_delegate?.notifyScheduledJob(config: nil)
                        }
                    }
                    return
                }
                
                // Notify that scheduled task is executing
                if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                    notify_delegate = pvc
                    notify_delegate?.start()
                    // Trying to notify when not in main view will crash RSyncOSX
                    if (SharingManagerConfiguration.sharedInstance.allowNotifyinMain == true) {
                        notify_delegate?.notifyScheduledJob(config: config)
                    }
                }
                
                if (hiddenID >= 0 && config != nil) {
                    arguments = rsyncProcessArguments().argumentsRsync(config!, dryRun: false, forDisplay: false)
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

