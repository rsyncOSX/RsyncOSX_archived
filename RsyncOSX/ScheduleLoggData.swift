//
//  ScheduleLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  Object for sorting and holding logg data about all tasks.
//  Detailed logging must be set on if logging data.
//
//  swiftlint:disable line_length

import Foundation

enum Sortandfilter {
    case remotecatalog
    case localcatalog
    case profile
    case remoteserver
    case task
    case backupid
    case numberofdays
    case executedate
}

final class ScheduleLoggData: SetConfigurations, SetSchedules, Sorting {

    var loggdata: [NSMutableDictionary]?
    private var scheduleConfiguration: [ConfigurationSchedule]?

    // Function for filter loggdata
    func filter(search: String?, filterby: Sortandfilter?) {
        guard search != nil && self.loggdata != nil && filterby != nil else { return }
        globalDefaultQueue.async(execute: {() -> Void in
            let valueforkey = self.filterbystring(filterby: filterby!)
            self.loggdata = self.loggdata?.filter({
                ($0.value(forKey: valueforkey) as? String)!.contains(search!)
            })
        })
    }

    // Loggdata is only read and sorted once
    private func readAndSortAllLoggdata() {
        var data = [NSMutableDictionary]()
        let input: [ConfigurationSchedule] = self.schedules!.getSchedule()
        for i in 0 ..< input.count {
            let hiddenID = self.schedules!.getSchedule()[i].hiddenID
            for j in 0 ..< input[i].logrecords.count {
                let dict = input[i].logrecords[j]
                let logdetail: NSMutableDictionary = [
                    "localCatalog": self.configurations!.getResourceConfiguration(hiddenID, resource: .localCatalog),
                    "offsiteServer": self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteServer),
                    "task": self.configurations!.getResourceConfiguration(hiddenID, resource: .task),
                    "backupID": self.configurations!.getResourceConfiguration(hiddenID, resource: .backupid),
                    "dateExecuted": dict.value(forKey: "dateExecuted") as? String ?? "",
                    "resultExecuted": dict.value(forKey: "resultExecuted") as? String ?? "",
                    "deleteCellID": dict.value(forKey: "deleteCellID") as? Int ?? 0,
                    "hiddenID": hiddenID,
                    "parent": i,
                    "sibling": j]
                data.append(logdetail)
            }
        }
        self.loggdata = self.sortbyrundate(notsorted: data, sortdirection: true)
    }

    // Loggdata is only read and sorted once
    private func readAndSortAllLoggdata(hiddenID: Int) {
        var data = [NSMutableDictionary]()
        let input: [ConfigurationSchedule] = self.schedules!.getSchedule()
        for i in 0 ..< input.count {
            for j in 0 ..< input[i].logrecords.count where self.schedules!.getSchedule()[i].hiddenID == hiddenID {
                let dict = input[i].logrecords[j]
                let logdetail: NSMutableDictionary = [
                    "localCatalog": self.configurations!.getResourceConfiguration(hiddenID, resource: .localCatalog),
                    "offsiteServer": self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteServer),
                    "task": self.configurations!.getResourceConfiguration(hiddenID, resource: .task),
                    "backupID": self.configurations!.getResourceConfiguration(hiddenID, resource: .backupid),
                    "dateExecuted": dict.value(forKey: "dateExecuted") as? String ?? "",
                    "resultExecuted": dict.value(forKey: "resultExecuted") as? String ?? "",
                    "deleteCellID": dict.value(forKey: "deleteCellID") as? Int ?? 0,
                    "hiddenID": hiddenID,
                    "parent": i,
                    "sibling": j]
                data.append(logdetail)
            }
        }
        self.loggdata = self.sortbyrundate(notsorted: data, sortdirection: true)
    }

    private func allreadAndSortAllLoggdata() {
        var data = [NSMutableDictionary]()
        let input: [ConfigurationSchedule]? = self.scheduleConfiguration
        guard input != nil else { return }
        for i in 0 ..< input!.count where input![i].logrecords.count > 0 {
            let profilename = input![i].profilename
            for j in 0 ..< input![i].logrecords.count {
                let dict = input![i].logrecords[j]
                dict.setValue(profilename, forKey: "profilename")
                data.append(dict)
            }
        }
        self.loggdata = self.sortbyrundate(notsorted: data, sortdirection: true)
    }

    init () {
        // Read and sort loggdata
        if self.loggdata == nil {
            self.readAndSortAllLoggdata()
        }
    }

    init (allschedules: Allschedules?) {
        guard allschedules != nil else { return }
        self.scheduleConfiguration = allschedules!.getallschedules()
        self.allreadAndSortAllLoggdata()
    }

    init (hiddenID: Int) {
        // Read and sort loggdata
        if self.loggdata == nil {
            self.readAndSortAllLoggdata(hiddenID: hiddenID)
        }
    }
}
