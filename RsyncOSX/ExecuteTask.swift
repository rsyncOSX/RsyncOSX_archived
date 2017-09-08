//
//  executeTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

// The Operation object to execute a scheduled job.
// The object get the hiddenID for the job, reads the
// rsync parameters for the job, creates a object to finalize the
// job after execution as logging. The reference to the finalize object
// is set in the static object. The finalize object is invoked
// when the job discover (observs) the termination of the process.

class ExecuteTask: Operation {

    override func main() {
        // Storage API
        var storageapi: PersistentStorageAPI?
        // Delegate function for start and completion of scheduled jobs
        weak var notifyDelegate: ScheduledJobInProgress?
        // Variables used for rsync parameters
        let output = OutputProcess()
        var arguments: Array<String>?
        var config: Configuration?

        // Get the first job of the queue
        if let dict: NSDictionary = Schedules.shared.scheduledJob {
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                if let profile = Configurations.shared.getProfile() {
                    storageapi = PersistentStorageAPI(profile : profile)
                } else {
                    storageapi = PersistentStorageAPI(profile : nil)
                }
                let store: [Configuration] = storageapi!.getConfigurations()
                let configArray = store.filter({return ($0.hiddenID == hiddenID)})
                guard configArray.count > 0 else {
                    notifyDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
                        as? ViewControllertabMain
                    if Configurations.shared.allowNotifyinMain == true {
                        notifyDelegate?.notifyScheduledJob(config: nil)
                    }
                    return
                }
                config = configArray[0]
                // Notify that scheduled task is executing
                notifyDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
                    as? ViewControllertabMain
                notifyDelegate?.start()
                // Trying to notify when not in main view will crash RSyncOSX
                if Configurations.shared.allowNotifyinMain == true {
                    notifyDelegate?.notifyScheduledJob(config: config)
                }
                if hiddenID >= 0 && config != nil {
                    arguments = RsyncProcessArguments().argumentsRsync(config!, dryRun: false, forDisplay: false)
                    // Setting reference to finalize the job
                    // Finalize job is done when rsynctask ends (in process termination)
                    ViewControllerReference.shared.operation = CompleteScheduledOperation(dict: dict)
                    // Start the rsync job
                    globalMainQueue.async(execute: {
                        if arguments != nil {
                            let process = RsyncScheduled(arguments: arguments)
                            process.executeProcess(output: output)
                        }
                    })
                }
            }
        }
    }
}
