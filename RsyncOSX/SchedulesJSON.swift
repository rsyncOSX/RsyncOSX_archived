//
//  SchedulesJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

class SchedulesJSON: Schedules {
    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    override func readschedules() {
        // var store = PersistentStorageScheduling(profile: self.profile).getScheduleandhistory(nolog: false)
        // guard store != nil else { return }
        let store = ReadWriteSchedulesJSON(profile: self.profile).decodejson
        var data = [ConfigurationSchedule]()

        for i in 0 ..< (store?.count ?? 0) {
            var transformed = transform(object: (store?[i] as? ScheduleJSON)!)
            // where store?[i].logrecords.isEmpty == false || store?[i].dateStop != nil

            transformed.profilename = self.profile
            data.append(transformed)
        }
        // Sorting schedule after hiddenID
        data.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
        // Setting self.Schedule as data
        self.schedules = data
    }
}

extension Schedules {
    func transform(object: ScheduleJSON) -> ConfigurationSchedule {
        var log: [Any]?
        let dict: NSDictionary = [
            "hiddenID": object.hiddenID ?? 0,
            "offsiteserver": object.offsiteserver ?? "",
            "dateStop": object.dateStop ?? "",
            "dateStart": object.dateStart ?? "",
            "schedule": object.schedule ?? "",
            "profilename": object.profilename ?? "",
        ]
        for i in 0 ..< (object.logrecords?.count ?? 0) {
            if i == 0 { log = Array() }
            let logdict: NSMutableDictionary = [
                "dateExecuted": object.logrecords![i].dateExecuted ?? "",
                "resultExecuted": object.logrecords![i].resultExecuted ?? "",
            ]
            log?.append(logdict)
        }
        return ConfigurationSchedule(dictionary: dict, log: log as NSArray?, nolog: false)
    }
}
