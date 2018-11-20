//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class ScheduleOperationDispatch: SetSchedules, SecondsBeforeStart {

    private var workitem: DispatchWorkItem?

    private func dispatchtaskmocup(_ seconds: Int) {
        let scheduledtask = DispatchWorkItem { [weak self] in
            weak var reloadDelegate: Reloadsortedandrefresh?
            reloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            reloadDelegate?.reloadsortedandrefreshtabledata()
            _ = Alerts.showInfo("Dispatch - scheduled task is executed, reload configuration...")
        }
        self.workitem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }

    private func dispatchtask(_ seconds: Int) {
        let scheduledtask = DispatchWorkItem { [weak self] in
            _ = ExecuteScheduledTask()
        }
        self.workitem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }

    init() {
        if self.schedules != nil {
            let seconds = self.secondsbeforestart()
            guard seconds > 0 else { return }
            guard ViewControllerReference.shared.executescheduledtasksmenuapp == false else {
                self.dispatchtaskmocup(Int(seconds))
                // Set reference to schedule for later cancel if any
                ViewControllerReference.shared.dispatchTaskWaiting = self.workitem
                return
            }
            self.dispatchtask(Int(seconds))
            // Set reference to schedule for later cancel if any
            ViewControllerReference.shared.dispatchTaskWaiting = self.workitem
        }
    }

    init(seconds: Int) {
        self.dispatchtask(seconds)
        // Set reference to schedule for later cancel if any
        ViewControllerReference.shared.dispatchTaskWaiting = self.workitem
    }

}
