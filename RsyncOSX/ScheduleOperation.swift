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

// Protocol when a Scehduled job is starting and stopping
// Used to informed the presenting viewcontroller about what
// is going on
protocol ScheduledJobInProgress : class {
    func start()
    func completed()
    func notifyScheduledJob(config: Configuration?)
}

// Class for creating and preparing the scheduled task
// The class set up a Timer for waiting for the first task to be
// executed. The class creates a object holding all jobs in
// queue for execution. The class calculates the number of
// seconds to wait before the firste scheduled task is executed.
// It set up a Timer to wait for the first job to execute. And when
// time is due it create a Operation object and dump the object onto the 
// OperationQueue for imidiate execution.

final class ScheduleOperation {

    private var scheduledJobs: ScheduleSortedAndExpand?
    private var waitForTask: Timer?
    private var queue: OperationQueue?
    private var secondsToWait: Double?

    @objc private func startJob() {
        // Start the task in BackgroundQueue
        // The Process itself is executed in GlobalMainQueue
        globalBackgroundQueue.async(execute: {
            let queue = OperationQueue()
            // Create the Operation object which executes the
            // scheduled job
            let task = ExecuteTask()
            // Add the Operation object to the queue for execution.
            // The queue executes the main() task whenever everything is ready for execution
            queue.addOperation(task)
        })
    }

    init () {
        // Cancel any current job waiting for execution
        SharingManagerSchedule.sharedInstance.cancelJobWaiting()
        // Create a new Schedules object
        self.scheduledJobs = ScheduleSortedAndExpand()
        // Removes the job of the stack
        if let dict = self.scheduledJobs!.jobToExecute() {
            let dateStart: Date = (dict.value(forKey: "start") as? Date)!
            self.secondsToWait = self.scheduledJobs!.timeDoubleSeconds(dateStart, enddate: nil)

            guard self.secondsToWait != nil else {
                return
            }

            self.waitForTask = Timer.scheduledTimer(timeInterval: self.secondsToWait!, target: self, selector: #selector(startJob), userInfo: nil, repeats: false)
            // Set reference to Timer that kicks of the Scheduled job
            // Reference is set for cancel job if requiered
            SharingManagerSchedule.sharedInstance.setJobWaiting(timer: self.waitForTask!)
        } else {
            // No jobs to execute, no need to keep reference to object
            self.scheduledJobs = nil
        }
    }
}
