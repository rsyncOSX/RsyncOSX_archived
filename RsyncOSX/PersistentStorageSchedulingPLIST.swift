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

class PersistentStorageSchedulingPLIST: ReadWriteDictionary, SetSchedules {
    // Variable holds all schedule data from persisten storage
    var schedulesasdictionary: [NSDictionary]?

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        if let dicts: [NSDictionary] = ConvertSchedules(JSON: false).schedules {
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
                } else {
                    self.savescheduleInMemoryToPersistentStore()
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
        super.init(profile: profile, whattoreadwrite: .schedule)
        if self.schedules == nil {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }

    init(profile: String?, readonly: Bool) {
        super.init(profile: profile, whattoreadwrite: .schedule)
        if readonly {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        } else {
            self.writeschedulestostoreasplist()
        }
    }
}
