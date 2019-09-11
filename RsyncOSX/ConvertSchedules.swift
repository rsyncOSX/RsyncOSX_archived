//
//  ConvertSchedules.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/04/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct ConvertSchedules: SetSchedules {

    var schedules: [NSDictionary]?

    init() {
        var array = [NSDictionary]()
        // Reading Schedules from memory
        if let schedules = self.schedules?.getSchedule() {
            for i in 0 ..< schedules.count {
                let schedule = schedules[i]
                let dict: NSMutableDictionary = [
                    "hiddenID": schedule.hiddenID,
                    "dateStart": schedule.dateStart,
                    "schedule": schedule.schedule,
                    "executed": schedule.logrecords,
                    "offsiteserver": schedule.offsiteserver ?? "localhost"]
                if schedule.dateStop != nil {
                    dict.setValue(schedule.dateStop, forKey: "dateStop")
                }
                if schedule.delete ?? false == false {
                    array.append(dict)
                } else {
                    if schedule.logrecords.isEmpty == false {
                         array.append(dict)
                    }
                }
            }
        }
        self.schedules = array
    }
}
