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
    var cleanedschedules: [ConfigurationSchedule]?
    init() {
        var array = [NSDictionary]()
        if let schedules = self.schedules?.getSchedule() {
            for i in 0 ..< schedules.count {
                let dict: NSMutableDictionary = [
                    "hiddenID": schedules[i].hiddenID,
                    "dateStart": schedules[i].dateStart,
                    "schedule": schedules[i].schedule,
                    "offsiteserver": schedules[i].offsiteserver ?? "localhost",
                ]
                if let log = schedules[i].logrecords {
                    var logrecords = [NSDictionary]()
                    for i in 0 ..< log.count {
                        let dict: NSDictionary = [
                            "dateExecuted": log[i].dateExecuted ?? "",
                            "resultExecuted": log[i].resultExecuted ?? "",
                        ]
                        logrecords.append(dict)
                    }
                    dict.setObject(logrecords, forKey: "executed" as NSCopying)
                }
                if schedules[i].dateStop != nil {
                    dict.setValue(schedules[i].dateStop, forKey: "dateStop")
                }
                if schedules[i].delete ?? false == false {
                    array.append(dict)
                } else {
                    if schedules[i].logrecords?.isEmpty == false {
                        if schedules[i].delete ?? false == false {
                            array.append(dict)
                        }
                    }
                }
            }
        }
        self.schedules = array
    }

    init(schedules: [ConfigurationSchedule]?) {
        var cleaned = [ConfigurationSchedule]()
        for i in 0 ..< (schedules?.count ?? 0) {
            if schedules![i].delete ?? false == false {
                cleaned.append(schedules![i])
            } else {
                if schedules?[i].logrecords?.isEmpty == false {
                    if schedules?[i].delete ?? false == false {
                        if let schedule = schedules?[i] {
                            cleaned.append(schedule)
                        }
                    }
                }
            }
        }
        self.cleanedschedules = cleaned
    }
}
