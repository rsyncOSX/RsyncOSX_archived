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
        if let schedules = self.schedulesDelegate?.getschedulesobject()?.getSchedule() {
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
                if let delete = schedule.delete {
                    if delete == false {
                        array.append(dict)
                    }
                } else {
                    array.append(dict)
                }
            }
        }
        self.schedules = array
    }
}
