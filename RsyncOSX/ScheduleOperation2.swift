//
//  ScheduleOperation2.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class ScheduleOperation2: SetSchedules {

    // We keep track of the pending work item as a property
    private var pendingRequestWorkItem: DispatchWorkItem?
    private var scheduledJobs: ScheduleSortedAndExpand?
    private var infoschedulessorted: InfoScheduleSortedAndExpand?
    private var secondsToWait: Double?

    private func executetask() {
        globalBackgroundQueue.async(execute: {
            _ = ExecuteTask2()
        })
    }

    func cancel() {
        self.pendingRequestWorkItem?.cancel()
    }

    func initiate(_ seconds: Int) {
        let requestWorkItem = DispatchWorkItem {
            self.executetask()
        }
        self.pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds),
                                      execute: self.pendingRequestWorkItem!)
    }

    init () {
        // Cancel any current job waiting for execution
        if self.schedules != nil {
            self.schedules!.cancelJobWaiting()
            // Create a new Schedules object
            self.scheduledJobs = ScheduleSortedAndExpand()
            self.infoschedulessorted = InfoScheduleSortedAndExpand(sortedandexpanded: scheduledJobs)
            // Removes the job of the stack
            if let dict = self.scheduledJobs!.allscheduledtasks() {
                let dateStart: Date = (dict.value(forKey: "start") as? Date)!
                self.secondsToWait = Tools().timeDoubleSeconds(dateStart, enddate: nil)
                guard self.secondsToWait != nil else { return }

                self.initiate(Int(self.secondsToWait!))

                // Reference is set for cancel job if requiered
                // self.schedules!.setJobWaiting(timer: self.waitForTask!)
            } else {
                // No jobs to execute, no need to keep reference to object
                self.scheduledJobs = nil
            }
        }
    }
}
