//
//  Allschedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 06.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class Allschedules {

    // Configurations object
    private var allschedules: [ConfigurationSchedule]?
    private var allprofiles: [String]?

    private func readallschedules() {
        guard self.allprofiles != nil else { return }
        var configurationschedule: [ConfigurationSchedule]?
        for i in 0 ..< self.allprofiles!.count {
            let profilename = self.allprofiles![i]
            if self.allschedules == nil {
                self.allschedules = []
            }
            if profilename == "Default profile" {
                configurationschedule = PersistentStorageAPI(profile: nil, forceread: true).getScheduleandhistory(nolog: true)
            } else {
                configurationschedule = PersistentStorageAPI(profile: profilename, forceread: true).getScheduleandhistory(nolog: true)
            }
            guard configurationschedule != nil else { return }
            for j in 0 ..< configurationschedule!.count {
                configurationschedule![j].profilename = profilename
                self.allschedules!.append(configurationschedule![j])
            }
        }
    }

    func getallschedules() -> [ConfigurationSchedule]? {
        return self.allschedules
    }

    init() {
        self.allprofiles = AllProfilenames().allprofiles
        self.readallschedules()
    }
}
