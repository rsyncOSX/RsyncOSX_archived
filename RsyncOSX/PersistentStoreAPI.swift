//
//  persistentStoreAPI.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStoreAPI {

    // Creates a singelton of this class
    class var  sharedInstance: PersistentStoreAPI {
        struct Singleton {
            static let instance = PersistentStoreAPI()
        }
        return Singleton.instance
    }

    // Delegate function for starting next scheduled operatin if any
    // Delegate function is triggered when Process.didTerminateNotification
    // is discovered (e.g previous job is done)
    weak var startnextjobDelegate: StartNextScheduledTask?

    // CONFIGURATIONS

    // Reading and writing configurations.
    // StoreAPI : API to class persistentStore.
    // If data is dirty read new data from persisten store else
    // return Configuration already in memory

    // Read configurations from persisten store
    func getConfigurations() -> [Configuration] {
        let read = PersistentStoreConfiguration()
        // Either read from persistent store or
        // return Configurations already in memory
        if read.readConfigurationsFromPermanentStore() != nil {
            var Configurations = [Configuration]()
            for dict in read.readConfigurationsFromPermanentStore()! {
                let conf = Configuration(dictionary: dict)
                Configurations.append(conf)
            }
            return Configurations
        } else {
            // Return configuration from memory
            return SharingManagerConfiguration.sharedInstance.getConfigurations()
        }
    }

    // Saving configuration from memory to persistent store
    func saveConfigFromMemory() {
        let save = PersistentStoreConfiguration()
        save.saveconfigInMemoryToPersistentStore()
    }

    // Saving added configuration from meory
    func saveNewConfigurations() {
        let save = PersistentStoreConfiguration()
        let newConfigurations = SharingManagerConfiguration.sharedInstance.getnewConfigurations()
        if (newConfigurations != nil) {
            for i in 0 ..< newConfigurations!.count {
                    save.addConfigurationsToMemory(newConfigurations![i])
                }
            save.saveconfigInMemoryToPersistentStore()
        }
        // Reset structure holding new configurations
        SharingManagerConfiguration.sharedInstance.destroyNewConfigurations()
        // Read all Configurations again to get all arguments
        SharingManagerConfiguration.sharedInstance.readAllConfigurationsAndArguments()
    }

    // SCHEDULE

    // Saving Schedules from memory to persistent store
    func saveScheduleFromMemory() {
        let store = PersistentStoreScheduling()
        store.savescheduleInMemoryToPersistentStore()
        SharingManagerSchedule.sharedInstance.readAllSchedules()
        // Kick off Scheduled job again
        // This is because saving schedule from memory might have
        // changed the schedule and this kicks off the changed
        // schedule again.
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain as? ViewControllertabMain {
            startnextjobDelegate = pvc
            startnextjobDelegate?.startProcess()
        }
    }

    // Read schedules and history
    // If no Schedule from persistent store return nil
    func getScheduleandhistory () -> [ConfigurationSchedule]? {
        let read = PersistentStoreScheduling()
        var schedule = [ConfigurationSchedule]()
        // Either read from persistent store or
        // return Schedule already in memory
        if read.readSchedulesFromPermanentStore() != nil {
            for dict in read.readSchedulesFromPermanentStore()! {
                if let log = dict.value(forKey: "executed") {
                    let conf = ConfigurationSchedule(dictionary: dict, log: log as? NSArray)
                    schedule.append(conf)
                } else {
                    let conf = ConfigurationSchedule(dictionary: dict, log: nil)
                    schedule.append(conf)
                }
            }
            return schedule
        } else {
            return nil
        }
    }

    // Reading and writing scheduling data and results of executions.
    // StoreAPI : API to class persistentStorescheduling.
    // Readig schedules only (not sorted and expanden)
    // Sorted and expanded are only stored in memory
    func getScheduleonly () -> [ConfigurationSchedule] {
        let read = PersistentStoreScheduling()
        if read.readSchedulesFromPermanentStore() != nil {
            var schedule = [ConfigurationSchedule]()
            for dict in read.readSchedulesFromPermanentStore()! {
                let conf = ConfigurationSchedule(dictionary: dict, log: nil)
                schedule.append(conf)
            }
            return schedule
        } else {
            return SharingManagerSchedule.sharedInstance.getSchedule()
        }
    }

    // USERCONFIG

    // Saving user configuration
    func saveUserconfiguration() {
        let store = PersistentStoreUserconfiguration()
        store.saveUserconfiguration()
    }

    func getUserconfiguration () -> [NSDictionary]? {
        let store = PersistentStoreUserconfiguration()
        return store.readUserconfigurationsFromPermanentStore()
    }

}
