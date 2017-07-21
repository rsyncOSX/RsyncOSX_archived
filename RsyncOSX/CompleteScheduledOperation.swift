//
//  completeScheduledOperation.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//swiftlint:disable line_length

import Foundation

// Class for completion of Operation objects when Process object termination.
// The object does also kicks of next scheduled job by setting new
// waiter time.
final class CompleteScheduledOperation {

    // Delegate function for starting next scheduled operatin if any
    // Delegate function is triggered when NSTaskDidTerminationNotification
    // is discovered (e.g previous job is done)
    weak var startnextjobDelegate: StartNextScheduledTask?
    // Delegate function for start and completion of scheduled jobs
    weak var notifyDelegate: ScheduledJobInProgress?
    // Delegate to notify starttimer()
    weak var startTimerDelegate: StartTimer?
    // Initialize variables
    private var date: Date?
    private var dateStart: Date?
    private var dateformatter: DateFormatter?
    private var hiddenID: Int?
    private var schedule: String?
    private var index: Int?

    // Function for finalizing the Scheduled job
    // The Operation object sets reference to the completeScheduledOperation in Schedules.shared.operation
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(output: OutputProcess) {

        // Write result to Schedule
        let datestring = self.dateformatter!.string(from: date!)
        let dateStartstring = self.dateformatter!.string(from: dateStart!)
        let number = Numbers(output: output.getOutput())
        number.setNumbers()
        let numberstring = number.statistics(numberOfFiles: nil, sizeOfFiles: nil)

        Schedules.shared.addScheduleResult(self.hiddenID!, dateStart: dateStartstring, result: numberstring[0], date: datestring, schedule: schedule!)
        // Writing timestamp to configuration
        // Update memory configuration with rundate
        _ = Configurations.shared.setCurrentDateonConfiguration(self.index!)
        // Saving updated configuration from memory
        _ = PersistentStoreageAPI.shared.saveConfigFromMemory()
        // Start next job, if any, by delegate
        // and notify completed, by delegate
        if let pvc2 = Configurations.shared.viewControllertabMain as? ViewControllertabMain {
            globalMainQueue.async(execute: { () -> Void in
                self.startnextjobDelegate = pvc2
                self.notifyDelegate = pvc2
                self.startnextjobDelegate?.startProcess()
                self.notifyDelegate?.completed()
            })
        }
        if let pvc3 = Schedules.shared.viewObjectSchedule as? ViewControllertabSchedule {
            globalMainQueue.async(execute: { () -> Void in
                self.startTimerDelegate = pvc3
                self.startTimerDelegate?.startTimerNextJob()
            })
        }
        // Reset reference til scheduled job
        Schedules.shared.scheduledJob = nil
    }

    init (dict: NSDictionary) {
        self.date = dict.value(forKey: "start") as? Date
        self.dateStart = dict.value(forKey: "dateStart") as? Date
        self.dateformatter = Utils.shared.setDateformat()
        self.hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
        self.schedule = dict.value(forKey: "schedule") as? String
        self.index = Configurations.shared.getIndex(hiddenID!)
    }
}
