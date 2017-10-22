//
//  ScheduleOperation.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 07/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

// Protocol for starting next scheduled job
protocol StartNextTask: class {
    func startanyscheduledtask()
}

protocol NextTask {
    weak var nexttaskDelegate: StartNextTask? { get }
}

extension NextTask {
    weak var nexttaskDelegate: StartNextTask? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func nexttask() {
        self.nexttaskDelegate?.startanyscheduledtask()
    }
}

// Protocol when a Scehduled job is starting and stopping
// Used to informed the presenting viewcontroller about what
// is going on
protocol ScheduledTaskWorking: class {
    func start()
    func completed()
    func notifyScheduledTask(config: Configuration?)
}

protocol ScheduledTask {
    weak var scheduleJob: ScheduledTaskWorking? { get }
}

extension ScheduledTask {
    weak var scheduleJob: ScheduledTaskWorking? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func notify(config: Configuration?) {
        self.scheduleJob?.notifyScheduledTask(config: config)
    }
}

protocol SecondsBeforeStart {
    func secondsbeforestart() -> Double
}

extension SecondsBeforeStart {

     func secondsbeforestart() -> Double {
        var secondsToWait: Double?
        let scheduledJobs = ScheduleSortedAndExpand()
        if let dict = scheduledJobs.allscheduledtasks() {
            let dateStart: Date = (dict.value(forKey: "start") as? Date)!
            secondsToWait = Tools().timeDoubleSeconds(dateStart, enddate: nil)
        }
        return secondsToWait ?? 0
    }

}

// Class for creating and preparing the scheduled task
// The class set up a Timer for waiting for the first task to be
// executed. The class creates a object holding all jobs in
// queue for execution. The class calculates the number of
// seconds to wait before the firste scheduled task is executed.
// It set up a Timer to wait for the first job to execute. And when
// time is due it create a Operation object and dump the object onto the 
// OperationQueue for imidiate execution.

final class ScheduleOperationTimer: SetSchedules, SecondsBeforeStart {

    private var timereTaskWaiting: Timer?

    @objc private func executetask() {
        // Start the task in BackgroundQueue
        // The Process itself is executed in GlobalMainQueue
        globalBackgroundQueue.async(execute: {
            let queue = OperationQueue()
            // Create the Operation object which executes the scheduled job
            let task = ExecuteTaskTimer()
            // Add the Operation object to the queue for execution.
            // The queue executes the main() task whenever everything is ready for execution
            queue.addOperation(task)
        })
    }

    func initiate() {
        if self.schedules != nil {
            // Cancel any current job waiting for execution
            self.schedules!.cancelTaskWaiting()
            let seconds = self.secondsbeforestart()
            guard seconds > 0 else { return }
            self.timereTaskWaiting = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(executetask),
                                                          userInfo: nil, repeats: false)
            self.schedules!.setTimerTaskWaiting(timer: self.timereTaskWaiting!)
        }
    }
}
