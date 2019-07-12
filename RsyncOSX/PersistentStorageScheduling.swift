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

import Foundation

final class PersistentStorageScheduling: ReadWriteDictionary, SetSchedules {

    var schedulesasdictionary: [NSDictionary]?

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        if let dicts: [NSDictionary] = ConvertSchedules().schedules {
            self.writeToStore(array: dicts)
        }
    }

    // Writing schedules to persistent store
    // Schedule is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        if self.writeNSDictionaryToPersistentStorage(array) {
            self.schedulesDelegate?.reloadschedulesobject()
        }
    }

    init (profile: String?) {
        super.init(whattoreadwrite: .schedule, profile: profile, configpath: ViewControllerReference.shared.configpath)
        if self.schedules == nil {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }

    init (profile: String?, allprofiles: Bool) {
        super.init(whattoreadwrite: .schedule, profile: profile, configpath: ViewControllerReference.shared.configpath)
        self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}
