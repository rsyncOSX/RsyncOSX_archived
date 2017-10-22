//
//  ScheduleOperation2.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class OperationFactory {

    private var factory: Int?

    init(factory: Int) {
        self.factory = factory
    }
}

class ScheduleOperation2: SetSchedules, SecondsBeforeStart {

    private var pendingRequestWorkItem: DispatchWorkItem?
    private var timereTaskWaiting: Double?

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
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: self.pendingRequestWorkItem!)
    }

    init () {
        if self.schedules != nil {
            let seconds = self.secondsbeforestart()
            guard seconds > 0 else { return }
            self.initiate(Int(seconds))
        }
    }
}
