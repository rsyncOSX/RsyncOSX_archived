//
//  ScheduleOperation.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 07/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

// Class for creating and preparing the scheduled task
// The class set up a Timer for waiting for the first task to be
// executed. The class creates a object holding all jobs in
// queue for execution. The class calculates the number of
// seconds to wait before the firste scheduled task is executed.
// It set up a Timer to wait for the first job to execute. And when
// time is due it create a Operation object and dump the object onto the 
// OperationQueue for imidiate execution.

final class ScheduleOperationTimer: SetSchedules, SecondsBeforeStart {

    private var timerTaskWaiting: Timer?

    @objc private func executetask() {
        // Start the task in BackgroundQueue
        // The Process itself is executed in GlobalMainQueue
        globalBackgroundQueue.async(execute: { [weak self] in
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
            let seconds = self.secondsbeforestart()
            guard seconds > 0 else { return }
            self.timerTaskWaiting = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(executetask),
                                                          userInfo: nil, repeats: false)
            self.schedules!.setTimerTaskWaiting(timer: self.timerTaskWaiting!)
        }
    }
}
