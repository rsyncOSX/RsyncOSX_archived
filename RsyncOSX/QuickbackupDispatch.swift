//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class QuickbackupDispatch: SetSchedules {

    private var workitem: DispatchWorkItem?

    private func dispatchtask(seconds: Int) {
        let work = DispatchWorkItem { [weak self] in
            _ = ExecuteQuickbackupTask()
        }
        self.workitem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: work)
    }

    init() {
        self.dispatchtask(seconds: 0)
        // Set reference to schedule for later cancel if any
        ViewControllerReference.shared.dispatchTaskWaiting = self.workitem
    }
}
