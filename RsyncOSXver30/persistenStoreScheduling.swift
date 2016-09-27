//
//  persistenStorescheduling.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Interface between Schedule in memory and
// presistent store. Class is a interface
// for Schedule.

class persistentStoreScheduling {
    
    // Holding all scheduledata
    private var schedulesFromFile: [NSDictionary]?
    
    func getschedulesFromFile() -> [NSDictionary]? {
        return self.schedulesFromFile
    }
        
    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore(){
        
        let array = NSMutableArray()
        // Reading Schedules from memory
        let data = SharingManagerSchedule.sharedInstance.getSchedule()
        
        for i in 0 ..< data.count {
            let schedule = data[i]
            let dict:NSMutableDictionary = [
                "hiddenID" : schedule.hiddenID,
                "dateStart":schedule.dateStart,
                "schedule":schedule.schedule,
                "executed":schedule.executed]
            if (schedule.dateStop != nil) {
                dict.setValue(schedule.dateStop, forKey: "dateStop")
            }
            if let delete = schedule.delete {
                if (!delete) {
                    array.add(dict)
                }
            } else {
                array.add(dict)
            }
        }
        // Write array to persistent store
        writeFile(array)
    }

    
    // Saving not deleted schedule records to persistent store
    // Deleted Schedule by hiddenID
    func savescheduleDeletedRecordsToFile (_ hiddenID : Int) {
        let array  = NSMutableArray()
        let schedule = SharingManagerSchedule.sharedInstance.getSchedule()
        for i in 0 ..< schedule.count {
            let sched = schedule[i]
            if ((sched.delete == nil) && (sched.hiddenID != hiddenID)) {
                let dict:NSMutableDictionary = [
                    "hiddenID" : sched.hiddenID,
                    "dateStart":sched.dateStart,
                    "schedule":sched.schedule,
                    "executed":sched.executed]
                if (sched.dateStop != nil) {
                    dict.setValue(sched.dateStop, forKey: "dateStop")
                }
                array.add(dict)
            }
        }
        // Write array to persistent store
        _ = writeFile(array)
    }
    
    
    // Write schedules to disk
    private func writeFile (_ array: NSMutableArray){
        // Getting the object just for the write method, no read from persistent store
        let save = readwritefiles(whattoread: enumtask.none)
        _ = save.writeDatatofile(array, task: enumtask.schedule)
    }
    
    init () {
        // Reading schedules
        // Configuration from memory or disk, if dirty read from disk
        // if not dirty from memory
        let read = readwritefiles(whattoread: enumtask.schedule)
        if let schedulesFromFile = read.datafromStore {
            self.schedulesFromFile = schedulesFromFile
        } else {
            self.schedulesFromFile = nil
        }
    }
}
