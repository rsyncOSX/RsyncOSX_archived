//
//  storeAPI.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

class storeAPI {
    
    // Creates a singelton of this class
    class var  sharedInstance: storeAPI {
        struct Singleton {
            static let instance = storeAPI()
        }
        return Singleton.instance
    }
    
    // Delegate function for starting next scheduled operatin if any
    // Delegate function is triggered when NSTaskDidTerminationNotification
    // is discovered (e.g previous job is done)
    weak var start_next_job_delegate:StartNextScheduledTask?
    
    // CONFIGURATIONS
    
    // Reading and writing configurations.
    // StoreAPI : API to class persistentStore.
    // If data is dirty read new data from persisten store else
    // return Configuration already in memory
    
    // Read configurations from persisten store
    func getConfigurations() -> [configuration] {
        let read = persistentStoreConfiguration()
        // Either read from persistent store or
        // return Configurations already in memory
        if read.getconfigurationFromStore() != nil {
            var Configurations = [configuration]()
            for dict in read.getconfigurationFromStore()! {
                let conf = configuration(dictionary: dict)
                Configurations.append(conf)
            }
            return Configurations
        } else {
            return SharingManagerConfiguration.sharedInstance.getConfigurations()
        }
    }
    
    // Saving configuration from memory to persistent store
    func saveConfigFromMemory() {
        let save = persistentStoreConfiguration()
        save.saveconfigInMemoryToPersistentStore()
    }
    
    // Saving added configuration from meory
    func saveNewConfigurations() {
        let save = persistentStoreConfiguration()
        let newConfigurations = SharingManagerConfiguration.sharedInstance.getnewConfigurations()
        if (newConfigurations != nil) {
            for i in 0 ..< newConfigurations!.count  {
                    save.addConfigurationsToMemory(newConfigurations![i])
                }
            save.saveconfigInMemoryToPersistentStore()
        }
        // Reset structure holding new configurations
        SharingManagerConfiguration.sharedInstance.destroyNewConfigurations()
        // Read all Configurations again to get all arguments
        SharingManagerConfiguration.sharedInstance.getAllConfigurationsandArguments()
    }
    
    
    // SCHEDULE
 
    
    // Saving Schedules from memory to persistent store
    func saveScheduleFromMemory() {
        let store = persistentStoreScheduling()
        store.savescheduleInMemoryToPersistentStore()
        SharingManagerSchedule.sharedInstance.getAllSchedules()
        // Kick off Scheduled job again
        // This is because saving schedule from memory might have
        // changed the schedule and this kicks off the changed
        // schedule again.
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
            start_next_job_delegate = pvc
            start_next_job_delegate?.startProcess()
        }
    }
    
    // Read schedules and history
    // If no Schedule from persistent store return nil
    func getScheduleandhistory () -> [configurationSchedule]? {
        let read = persistentStoreScheduling()
        var schedule = [configurationSchedule]()
        // Either read from persistent store or
        // return Schedule already in memory
        if read.getschedulesFromFile() != nil {
            for dict in read.getschedulesFromFile()! {
                if let executed = dict.value(forKey: "executed") {
                    let conf = configurationSchedule(dictionary: dict, executed: executed as? NSArray)
                    schedule.append(conf)
                } else {
                    let conf = configurationSchedule(dictionary: dict, executed: nil)
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
    func getScheduleonly () -> [configurationSchedule] {
        let read = persistentStoreScheduling()
        if read.getschedulesFromFile() != nil {
            var schedule = [configurationSchedule]()
            for dict in read.getschedulesFromFile()! {
                let conf = configurationSchedule(dictionary: dict, executed: nil)
                schedule.append(conf)
            }
            return schedule
        } else {
            return SharingManagerSchedule.sharedInstance.getSchedule()
        }
    }
    
    
    // USERCONFIG
    
    // Saving user configuration
    func saveuserconfig () -> Bool {
        var version3Rsync:Int?
        var detailedlogging:Int?
        var rsyncPath:String?
        
        if (SharingManagerConfiguration.sharedInstance.rsyncVer3) {
            version3Rsync = 1
        } else {
            version3Rsync = 0
        }
        if (SharingManagerConfiguration.sharedInstance.detailedlogging) {
            detailedlogging = 1
        } else {
            detailedlogging = 0
        }
        if (SharingManagerConfiguration.sharedInstance.rsyncPath != nil) {
            rsyncPath = SharingManagerConfiguration.sharedInstance.rsyncPath!
        }
        
        let array = NSMutableArray()
        let dict:NSMutableDictionary = [
            "version3Rsync" : version3Rsync! as Int,
            "detailedlogging" : detailedlogging! as Int,
            "scheduledTaskdisableExecute": SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute]
        if ((rsyncPath != nil)) {
            dict.setObject(rsyncPath!, forKey: "rsyncPath" as NSCopying)
        }
        array.add(dict)
        let save = readwritefiles(whattoread: enumtask.none)
        return save.writeDatatofile(array, task: .userconfig)
    }
    
}


