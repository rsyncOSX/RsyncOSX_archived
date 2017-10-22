//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum OperationObject {
    case timer
    case dispatch
}
class OperationFactory {

    private var factory: OperationObject?
    var operationTimer: ScheduleOperation?
    var operationDispatch: ScheduleOperationDispatch?

    func initiate() {
        switch self.factory! {
        case .timer:
            self.operationTimer = ScheduleOperation()
            self.operationTimer?.initiate()
        case .dispatch:
            self.operationDispatch = ScheduleOperationDispatch()
            self.operationDispatch?.initiate()
        }
    }

    init(factory: OperationObject) {
        self.factory = factory
    }
}

class ScheduleOperationDispatch: SetSchedules, SecondsBeforeStart {

    private var pendingRequestWorkItem: DispatchWorkItem?

    private func executetask() {
        globalBackgroundQueue.async(execute: {
            _ = ExecuteTaskDispatch()
        })
    }

    func cancel() {
        self.pendingRequestWorkItem?.cancel()
    }

    func dispatchtask(_ seconds: Int) {
        let requestWorkItem = DispatchWorkItem {
            self.executetask()
        }
        self.pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: self.pendingRequestWorkItem!)
    }

   func initiate() {
    if self.schedules != nil {
        let seconds = self.secondsbeforestart()
        guard seconds > 0 else { return }
        self.dispatchtask(Int(seconds))
        }
    }

}
