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
//   swiftlint:disable line_length

import Foundation

final class PersistentStorageScheduling: ReadWriteDictionary, SetSchedules {

    weak var readloggdataDelegate: ReadLoggdata?
    var schedulesasdictionary: [NSDictionary]?

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        let dicts: [NSDictionary] = ConvertSchedules().convertschedules()
        self.writeToStore(array: dicts)
    }

    // Writing schedules to persistent store
    // Schedule is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        if self.writeNSDictionaryToPersistentStorage(array) {
            self.schedulesDelegate?.reloadschedulesobject()
            self.readloggdataDelegate?.readloggdata()
        }
    }

    init (profile: String?) {
        super.init(whattoreadwrite: .schedule, profile: profile, configpath: ViewControllerReference.shared.configpath)
        self.readloggdataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        if self.schedules == nil {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }

    init (profile: String?, allprofiles: Bool) {
        super.init(whattoreadwrite: .schedule, profile: profile, configpath: ViewControllerReference.shared.configpath)
        self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}
