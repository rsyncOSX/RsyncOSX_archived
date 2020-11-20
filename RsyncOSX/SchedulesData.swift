//
//  SchedulesData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 15/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class SchedulesData {
    var schedules: [ConfigurationSchedule]?
    var profile: String?
    var validhiddenID: Set<Int>?

    func readschedulesplist() {
        let schedulesfromstore = PersistentStorageScheduling(profile: self.profile).schedulesasdictionary
        var schedule: ConfigurationSchedule?
        for i in 0 ..< (schedulesfromstore?.count ?? 0) {
            if let dict = schedulesfromstore?[i], let validhiddenID = self.validhiddenID {
                if let hiddenID = dict.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int {
                    if validhiddenID.contains(hiddenID) {
                        if let log = dict.value(forKey: DictionaryStrings.executed.rawValue) {
                            schedule = ConfigurationSchedule(dictionary: dict, log: log as? NSArray, includelog: true)
                        } else {
                            schedule = ConfigurationSchedule(dictionary: dict, log: nil, includelog: true)
                        }
                        if let schedule = schedule {
                            self.schedules?.append(schedule)
                        }
                    }
                }
            }
        }
        // Sorting schedule after hiddenID
        self.schedules?.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
    }

    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    func readschedulesjson() {
        let store = PersistentStorageSchedulingJSON(profile: self.profile).decodedjson
        // var data = [ConfigurationSchedule]()
        let transform = TransformSchedulefromJSON()
        for i in 0 ..< (store?.count ?? 0) {
            if let scheduleitem = (store?[i] as? DecodeScheduleJSON), let validhiddenID = self.validhiddenID {
                var transformed = transform.transform(object: scheduleitem)
                transformed.profilename = self.profile
                if validhiddenID.contains(transformed.hiddenID) {
                    self.schedules?.append(transformed)
                }
            }
        }
        // Sorting schedule after hiddenID
        self.schedules?.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
    }

    init(profile: String?, validhiddenID: Set<Int>?) {
        self.profile = profile
        self.schedules = nil
        self.validhiddenID = validhiddenID
        self.schedules = [ConfigurationSchedule]()
        if ViewControllerReference.shared.json {
            self.readschedulesjson()
        } else {
            self.readschedulesplist()
        }
        if ViewControllerReference.shared.checkinput {
            self.schedules = Reorgschedule().mergerecords(data: self.schedules)
        }
    }
}
