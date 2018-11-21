//
//  completeScheduledOperation.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

// Class for completion of Operation objects when Process object termination.
// The object does also kicks of next scheduled job by setting new waiter time.
final class CompleteQuickbackupOperation: SetConfigurations, SetSchedules {

    weak var startTimerDelegate: StartTimer?
    private var date: Date?
    private var dateStart: Date?
    private var dateformatter: DateFormatter?
    private var hiddenID: Int?
    private var schedule: String?
    private var index: Int?

    // Function for finalizing the Scheduled job
    // The Operation object sets reference to the completeScheduledOperation in self.schedules!.operation
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(outputprocess: OutputProcess?) {
        // Write result to Schedule
        let datestring = self.dateformatter!.string(from: date!)
        let dateStartstring = self.dateformatter!.string(from: dateStart!)
        let number = Numbers(outputprocess: outputprocess)
        let numberstring = number.stats()
        self.schedules!.addresultschedule(self.hiddenID!, dateStart: dateStartstring, result: numberstring, date: datestring, schedule: schedule!)
        // Writing timestamp to configuration
        self.configurations!.setCurrentDateonConfigurationQuickbackup(index: self.index!, outputprocess: outputprocess)
        self.startTimerDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
        self.startTimerDelegate?.startTimerNextJob()
        self.schedulesDelegate?.reloadschedulesobject()
    }

    init (dict: NSDictionary) {
        self.date = dict.value(forKey: "start") as? Date
        self.dateStart = dict.value(forKey: "dateStart") as? Date
        self.dateformatter = Dateandtime().setDateformat()
        self.hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
        self.schedule = dict.value(forKey: "schedule") as? String
        self.index = self.configurations!.getIndex(hiddenID!)
    }
}
