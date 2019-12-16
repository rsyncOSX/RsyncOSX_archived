//
//  ConvertSchedules.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/04/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Foundation

struct ConvertSchedules: SetSchedules {
    var schedules: [NSDictionary]?

    init() {
        var array = [NSDictionary]()
        // Reading Schedules from memory
        if let schedules = self.schedules?.getSchedule() {
            for i in 0 ..< schedules.count {
                let dict: NSMutableDictionary = [
                    "hiddenID": schedules[i].hiddenID,
                    "dateStart": schedules[i].dateStart,
                    "schedule": schedules[i].schedule,
                    "executed": schedules[i].logrecords,
                    "offsiteserver": schedules[i].offsiteserver ?? "localhost",
                ]
                if schedules[i].dateStop != nil {
                    dict.setValue(schedules[i].dateStop, forKey: "dateStop")
                }
                if schedules[i].delete ?? false == false {
                    array.append(dict)
                } else {
                    if schedules[i].logrecords.isEmpty == false {
                        if schedules[i].delete ?? false == false {
                            array.append(dict)
                        }
                    }
                }
            }
        }
        self.schedules = array
    }
}
