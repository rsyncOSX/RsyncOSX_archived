//
//  PersistenStorescheduling.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//   Interface between Schedule in memory and
//   presistent store. Class is a interface
//   for Schedule.
//
// swiftlint:disable line_length

import Files
import Foundation

class PersistentStorageScheduling: ReadWriteDictionary, SetSchedules {
    // Variable holds all schedule data from persisten storage
    var schedulesasdictionary: [NSDictionary]?

    // Read schedules and history
    // If no Schedule from persistent store return nil
    func getScheduleandhistory(nolog: Bool) -> [ConfigurationSchedule]? {
        var schedule = [ConfigurationSchedule]()
        guard self.schedulesasdictionary != nil else { return nil }
        for dict in self.schedulesasdictionary! {
            if let log = dict.value(forKey: "executed") {
                let conf = ConfigurationSchedule(dictionary: dict, log: log as? NSArray, nolog: nolog)
                schedule.append(conf)
            } else {
                let conf = ConfigurationSchedule(dictionary: dict, log: nil, nolog: nolog)
                schedule.append(conf)
            }
        }
        return schedule
    }

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        if let dicts: [NSDictionary] = ConvertSchedules().schedules {
            self.writeToStore(array: dicts)
        }
    }

    func writeschedulestostoreasplist() {
        let root = NamesandPaths(profileorsshrootpath: .profileroot)
        if var atpath = root.fullroot {
            if self.profile != nil {
                atpath += "/" + (self.profile ?? "")
            }
            do {
                if try Folder(path: atpath).containsFile(named: ViewControllerReference.shared.scheduleplist) {
                    let question: String = NSLocalizedString("PLIST file exists: ", comment: "Logg")
                    let text: String = NSLocalizedString("Cancel or Save", comment: "Logg")
                    let dialog: String = NSLocalizedString("Save", comment: "Logg")
                    let answer = Alerts.dialogOrCancel(question: question + " " + ViewControllerReference.shared.scheduleplist, text: text, dialog: dialog)
                    if answer {
                        self.savescheduleInMemoryToPersistentStore()
                    }
                }
            } catch {}
        }
    }

    // Writing schedules to persistent store
    // Schedule is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        if self.writeNSDictionaryToPersistentStorage(array: array) {
            self.schedulesDelegate?.reloadschedulesobject()
        }
    }

    init(profile: String?) {
        super.init(whattoreadwrite: .schedule, profile: profile)
        if self.schedules == nil {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }

    init(profile: String?, readonly: Bool) {
        super.init(whattoreadwrite: .schedule, profile: profile)
        if readonly == true {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        } else {
            self.writeschedulestostoreasplist()
        }
    }
}
