//
//  OperationFactory.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

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

enum OperationObject {
    case timer
    case dispatch
}

protocol Sendprocessreference: class {
    func sendprocessreference(process: Process?)
}

class OperationFactory {

    private var factory: OperationObject?
    var operationTimer: ScheduleOperationTimer?
    var operationDispatch: ScheduleOperationDispatch?

    func initiate() {
        switch self.factory! {
        case .timer:
            self.operationTimer = ScheduleOperationTimer()
        case .dispatch:
            self.operationDispatch = ScheduleOperationDispatch()
        }
    }

    init(factory: OperationObject) {
        self.factory = factory
    }

    init() {
        self.operationDispatch = ScheduleOperationDispatch(seconds: 0)
    }
}
