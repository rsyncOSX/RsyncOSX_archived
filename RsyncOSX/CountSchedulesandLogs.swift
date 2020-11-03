//
//  CountSchedulesandLogs.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 30/11/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct CountSchedulesandLogs: SetSchedules {
    var schedulerecords: Int = 0
    var logrecords: Int = 0

    init() {
        if let schedules = self.schedules?.getSchedule() {
            for i in 0 ..< schedules.count {
                self.schedulerecords = i + 1
                self.logrecords = +self.logrecords + (schedules[i].logrecords?.count ?? 0)
            }
        }
    }
}
