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

protocol Readfiltereddata: class {
    func readfiltereddata(data: Filtereddata)
}

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

struct Filtereddata {
    var filtereddata: [NSMutableDictionary]?
}

final class ScheduleLoggData: SetConfigurations, SetSchedules, Sorting {

    var loggdata: [NSMutableDictionary]?

    // Function for filter loggdata
    func filter(search: String?, what: Sortandfilter?) {
        guard search != nil || self.loggdata != nil else { return }
        var valueforkeystring: String?
        globalDefaultQueue.async(execute: {() -> Void in
            var filtereddata = Filtereddata()
            switch what! {
            case .executedate:
                valueforkeystring = "dateExecuted"
            case .localcatalog:
                 valueforkeystring = "localCatalog"
            case .remoteserver:
                 valueforkeystring = "offsiteServer"
            case .task:
                 valueforkeystring = "task"
            case .backupid:
                 valueforkeystring = "backupid"
            default:
                return
            }
            filtereddata.filtereddata = self.loggdata?.filter({
                ($0.value(forKey: valueforkeystring!) as? String)!.contains(search!)
            })
            self.loggdata = filtereddata.filtereddata
        })
    }

    // Loggdata is only read and sorted once
    private func readAndSortAllLoggdata() {
        var data = [NSMutableDictionary]()
        let input: [ConfigurationSchedule] = self.schedules!.getSchedule()
        for i in 0 ..< input.count {
            let hiddenID = self.schedules!.getSchedule()[i].hiddenID
            if input[i].logrecords.count > 0 {
                for j in 0 ..< input[i].logrecords.count {
                    let dict = input[i].logrecords[j]
                    let logdetail: NSMutableDictionary = [
                        "localCatalog": self.configurations!.getResourceConfiguration(hiddenID, resource: .localCatalog),
                        "offsiteServer": self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteServer),
                        "task": self.configurations!.getResourceConfiguration(hiddenID, resource: .task),
                        "backupID": self.configurations!.getResourceConfiguration(hiddenID, resource: .backupid),
                        "dateExecuted": (dict.value(forKey: "dateExecuted") as? String)!,
                        "resultExecuted": (dict.value(forKey: "resultExecuted") as? String)!,
                        "hiddenID": hiddenID,
                        "parent": i,
                        "sibling": j]
                    data.append(logdetail)
                }
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
}
