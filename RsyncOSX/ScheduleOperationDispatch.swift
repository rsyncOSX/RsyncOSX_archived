//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class ScheduleOperationDispatch: SetSchedules, SecondsBeforeStart {

    private var pendingRequestWorkItem: DispatchWorkItem?

    private func executetask() {
        globalBackgroundQueue.async(execute: {
            _ = ExecuteTaskDispatch()
        })
    }

    private func cancel() {
        self.pendingRequestWorkItem?.cancel()
    }

    private func dispatchtask(_ seconds: Int) {
        let requestWorkItem = DispatchWorkItem {
            self.executetask()
        }
        self.pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: self.pendingRequestWorkItem!)
    }

   func initiate() {
    if self.schedules != nil {
        self.schedules!.cancelTaskWaiting()
        let seconds = self.secondsbeforestart()
        guard seconds > 0 else { return }
        self.dispatchtask(Int(seconds))
        self.schedules!.setDispatchTaskWaiting(taskitem: self.pendingRequestWorkItem!)
        }
    }

}
