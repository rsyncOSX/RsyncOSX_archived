//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class QuickbackupDispatch: SetSchedules {
    weak var workitem: DispatchWorkItem?
    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void

    private func dispatchtask(seconds: Int) {
        let work = DispatchWorkItem { () -> Void in
            _ = ExecuteQuickbackupTask(processtermination: self.processtermination, filehandler: self.filehandler)
        }
        self.workitem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: work)
    }

    init(processtermination: @escaping () -> Void, filehandler: @escaping () -> Void) {
        self.processtermination = processtermination
        self.filehandler = filehandler
        self.dispatchtask(seconds: 0)
    }
}
