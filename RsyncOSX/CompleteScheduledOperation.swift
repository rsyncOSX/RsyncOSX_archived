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
final class CompleteScheduledOperation {

    // configurations
    weak var configurationsDelegate: GetConfigurationsObject?
    var configurations: Configurations?
    weak var schedulesDelegate: GetSchedulesObject?
    var schedules: Schedules?
    // configurations

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
    // The Operation object sets reference to the completeScheduledOperation in self.schedules!.operation
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(output: OutputProcess) {

        // Write result to Schedule
        let datestring = self.dateformatter!.string(from: date!)
        let dateStartstring = self.dateformatter!.string(from: dateStart!)
        let number = Numbers(output: output.getOutput())
        number.setNumbers()
        let numberstring = number.stats(numberOfFiles: nil, sizeOfFiles: nil)
        self.schedules!.addresultschedule(self.hiddenID!,
                                           dateStart: dateStartstring,
                                           result: numberstring[0],
                                           date: datestring, schedule: schedule!)
        // Writing timestamp to configuration
        _ = self.configurations!.setCurrentDateonConfiguration(self.index!)
        // Start next job, if any, by delegate and notify completed, by delegate
        globalMainQueue.async(execute: { () -> Void in
            self.startnextjobDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
                as? ViewControllertabMain
            self.notifyDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
                as? ViewControllertabMain
            self.startnextjobDelegate?.startProcess()
            self.notifyDelegate?.completed()
        })
        globalMainQueue.async(execute: { () -> Void in
            self.startTimerDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule)
                as? ViewControllertabSchedule
            self.startTimerDelegate?.startTimerNextJob()
        })
        // Reset reference til scheduled job
        self.schedules!.scheduledJob = nil
    }

    init (dict: NSDictionary) {
        self.date = dict.value(forKey: "start") as? Date
        self.dateStart = dict.value(forKey: "dateStart") as? Date
        self.dateformatter = Tools().setDateformat()
        self.hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
        self.schedule = dict.value(forKey: "schedule") as? String
        self.index = self.configurations!.getIndex(hiddenID!)
        // configurations
        self.configurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        self.configurations = self.configurationsDelegate?.getconfigurationsobject()
        self.schedulesDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        self.schedules = self.schedulesDelegate?.getschedulesobject()
        // configurations
    }
}
