//
//  Allschedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 06.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

import Cocoa
import Foundation

class Allschedules {
    private var allschedules: [ConfigurationSchedule]?
    private var allprofiles: [String]?

    private func readallschedules() {
        var configurationschedule: [ConfigurationSchedule]?
        for i in 0 ..< (allprofiles?.count ?? 0) {
            let profilename = allprofiles?[i]
            if allschedules == nil {
                allschedules = []
            }
            if profilename == NSLocalizedString("Default profile", comment: "default profile") {
                configurationschedule = ReadScheduleJSON(nil, nil).schedules
            } else {
                configurationschedule = ReadScheduleJSON(profilename, nil).schedules
            }
            for j in 0 ..< (configurationschedule?.count ?? 0) {
                configurationschedule?[j].profilename = profilename
                if let configurationschedule = configurationschedule?[j] {
                    allschedules?.append(configurationschedule)
                }
            }
        }
    }

    func getallschedules() -> [ConfigurationSchedule]? {
        return allschedules
    }

    init() {
        allprofiles = Catalogsandfiles(.configurations).getcatalogsasstringnames()
        readallschedules()
    }

    deinit {
        // print("deinit Allschedules")
    }
}
