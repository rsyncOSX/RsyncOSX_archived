//
//  Allschedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 06.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class Allschedules {
    private var allschedules: [ConfigurationSchedule]?
    private var allprofiles: [String]?

    private func readallschedules(nolog: Bool) {
        var configurationschedule: [ConfigurationSchedule]?
        for i in 0 ..< (self.allprofiles?.count ?? 0) {
            let profilename = self.allprofiles?[i]
            if self.allschedules == nil {
                self.allschedules = []
            }
            if profilename == NSLocalizedString("Default profile", comment: "default profile") {
                configurationschedule = PersistentStorageAllprofilesAPI(profile: nil).getScheduleandhistory(nolog: nolog)
            } else {
                configurationschedule = PersistentStorageAllprofilesAPI(profile: profilename).getScheduleandhistory(nolog: nolog)
            }
            for j in 0 ..< (configurationschedule?.count ?? 0) {
                configurationschedule?[j].profilename = profilename
                if let configurationschedule = configurationschedule?[j] {
                    self.allschedules?.append(configurationschedule)
                }
            }
        }
    }

    func getallschedules() -> [ConfigurationSchedule]? {
        return self.allschedules
    }

    init(nolog: Bool) {
        self.allprofiles = AllProfilenames().allprofiles
        self.readallschedules(nolog: nolog)
    }
}
