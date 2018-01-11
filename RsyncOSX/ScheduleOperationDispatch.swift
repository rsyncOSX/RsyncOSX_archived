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

    private func dispatchtask(_ seconds: Int) {
        let scheduledtask = DispatchWorkItem { [weak self] in
            _ = ExecuteTaskDispatch()
        }
        self.pendingRequestWorkItem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }

    init() {
        if self.schedules != nil {
            let seconds = self.secondsbeforestart()
            guard seconds > 0 else { return }
            self.dispatchtask(Int(seconds))
            // Set reference to schedule for later cancel if any
            ViewControllerReference.shared.dispatchTaskWaiting = self.pendingRequestWorkItem
        }
    }

    init(seconds: Int) {
        self.dispatchtask(seconds)
        // Set reference to schedule for later cancel if any
        ViewControllerReference.shared.dispatchTaskWaiting = self.pendingRequestWorkItem
    }

}
