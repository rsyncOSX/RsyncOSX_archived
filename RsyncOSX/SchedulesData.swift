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
    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    func readschedulesplist() {
        var store = PersistentStorageScheduling(profile: self.profile).getScheduleandhistory(nolog: false)
        guard store != nil else { return }
        // var data = [ConfigurationSchedule]()
        for i in 0 ..< (store?.count ?? 0) where store?[i].logrecords?.isEmpty == false || store?[i].dateStop != nil {
            store?[i].profilename = self.profile
            if let store = store?[i] {
                self.schedules?.append(store)
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
            if let scheduleitem = (store?[i] as? DecodeScheduleJSON) {
                var transformed = transform.transform(object: scheduleitem)
                transformed.profilename = self.profile
                self.schedules?.append(transformed)
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

    init(profile: String?) {
        self.profile = profile
        self.schedules = nil
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
