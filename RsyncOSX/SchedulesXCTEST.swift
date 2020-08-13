//
//  Schedules_XCTEST.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/09/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

class SchedulesXCTEST: Schedules {
    override func addschedule(hiddenID: Int, schedule: Scheduletype, start: Date) {
        var stop: Date?
        if schedule == .once {
            stop = start
        } else {
            stop = "01 Jan 2100 00:00".en_us_date_from_string()
        }
        let dict = NSMutableDictionary()
        let offsiteserver = self.configurations?.getResourceConfiguration(hiddenID, resource: .offsiteServer)
        dict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
        dict.setObject(start.en_us_string_from_date(), forKey: "dateStart" as NSCopying)
        dict.setObject(stop!.en_us_string_from_date(), forKey: "dateStop" as NSCopying)
        dict.setObject(offsiteserver as Any, forKey: "offsiteserver" as NSCopying)
        switch schedule {
        case .once:
            dict.setObject(Scheduletype.once.rawValue, forKey: "schedule" as NSCopying)
        case .daily:
            dict.setObject(Scheduletype.daily.rawValue, forKey: "schedule" as NSCopying)
        case .weekly:
            dict.setObject(Scheduletype.weekly.rawValue, forKey: "schedule" as NSCopying)
        default:
            return
        }
        let newSchedule = ConfigurationSchedule(dictionary: dict, log: nil, nolog: true)
        self.schedules?.append(newSchedule)
    }

    override init(profile: String?) {
        super.init(profile: profile)
    }
}
