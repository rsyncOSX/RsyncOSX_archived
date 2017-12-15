//
//  executeTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar line_length

import Foundation

// The Operation object to execute a scheduled job.
// The object get the hiddenID for the job, reads the
// rsync parameters for the job, creates a object to finalize the
// job after execution as logging. The reference to the finalize object
// is set in the static object. The finalize object is invoked
// when the job discover (observs) the termination of the process.

class ExecuteTaskTimer: Operation, SetSchedules, SetConfigurations, SetScheduledTask {

    override func main() {

        let outputprocess = OutputProcess()
        var arguments: Array<String>?
        var config: Configuration?
        // Get the first job of the queue
        if let dict: NSDictionary = ViewControllerReference.shared.scheduledTask {
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                let getconfigurations: [Configuration]? = configurations?.getConfigurations()
                guard getconfigurations != nil else { return }
                let configArray = getconfigurations!.filter({return ($0.hiddenID == hiddenID)})
                guard configArray.count > 0 else {
                    self.notify(config: nil)
                    return
                }
                config = configArray[0]
                // Inform and notify
                self.scheduleJob?.start()
                self.notify(config: config)
                if hiddenID >= 0 && config != nil {
                    arguments = RsyncProcessArguments().argumentsRsync(config!, dryRun: false, forDisplay: false)
                    // Setting reference to finalize the job, finalize job is done when rsynctask ends (in process termination)
                    ViewControllerReference.shared.completeoperation = CompleteScheduledOperation(dict: dict)
                    globalMainQueue.async(execute: {
                        if arguments != nil {
                            weak var sendprocess: Sendprocessreference?
                            sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
                            let process = RsyncScheduled(arguments: arguments)
                            process.executeProcess(outputprocess: outputprocess)
                            sendprocess?.sendprocessreference(process: process.getProcess())
                        }
                    })
                }
            }
        }
    }
}
