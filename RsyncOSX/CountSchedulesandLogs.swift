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
                self.schedulerecords = +self.schedulerecords
                for j in 0 ..< schedules[i].logrecords.count {
                    self.logrecords = +self.logrecords + schedules[j].logrecords.count
                }
            }
        }
    }
}
