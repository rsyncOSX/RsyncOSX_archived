//
//  Schedules_XCTEST.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/09/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

class SchedulesXCTEST: Schedules {
    override func addschedule(_ hiddenID: Int, schedule: Scheduletype, start: Date) {
        var stop: Date?
        let dateformatter = Dateandtime().setDateformat()
        if schedule == .once {
            stop = start
        } else {
            stop = dateformatter.date(from: "01 Jan 2100 00:00")
        }
        let dict = NSMutableDictionary()
        let offsiteserver = self.configurations?.getResourceConfiguration(hiddenID, resource: .offsiteServer)
        dict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
        dict.setObject(dateformatter.string(from: start), forKey: "dateStart" as NSCopying)
        dict.setObject(dateformatter.string(from: stop!), forKey: "dateStop" as NSCopying)
        dict.setObject(offsiteserver as Any, forKey: "offsiteserver" as NSCopying)
        switch schedule {
        case .once:
            dict.setObject("once", forKey: "schedule" as NSCopying)
        case .daily:
            dict.setObject("daily", forKey: "schedule" as NSCopying)
        case .weekly:
            dict.setObject("weekly", forKey: "schedule" as NSCopying)
        }
        let newSchedule = ConfigurationSchedule(dictionary: dict, log: nil, nolog: true)
        self.schedules!.append(newSchedule)
    }
    override init(profile: String?) {
        super.init(profile: profile)
    }
}
