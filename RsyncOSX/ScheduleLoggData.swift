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

enum Filterlogs {
    case localCatalog
    case remoteServer
    case executeDate
    case numberofdays
    case remoteCatalog
    case task
}

struct Filtereddata {
    var filtereddata: [NSMutableDictionary]?
}

final class ScheduleLoggData: SetConfigurations, SetSchedules {

    private var loggdata: [NSMutableDictionary]?
    private var sortedascendigdesending: Bool = false

    func getallloggdata() -> [NSMutableDictionary]? {
        return self.loggdata
    }

    // Function for filter loggdata
    func filter(search: String?, what: Filterlogs?) {
        guard search != nil || self.loggdata != nil else { return }
        globalDefaultQueue.async(execute: {() -> Void in
            var filtereddata = Filtereddata()
            switch what! {
            case .executeDate:
                filtereddata.filtereddata =  self.loggdata?.filter({
                    ($0.value(forKey: "dateExecuted") as? String)!.contains(search!)
                })
            case .localCatalog:
                filtereddata.filtereddata = self.loggdata?.filter({
                    ($0.value(forKey: "localCatalog") as? String)!.contains(search!)
                })
            case .remoteServer:
                filtereddata.filtereddata = self.loggdata?.filter({
                    ($0.value(forKey: "offsiteServer") as? String)!.contains(search!)
                })
            case .numberofdays:
                return
            case .remoteCatalog:
                return
            default:
                return
            }
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
                        "backupid": self.configurations!.getResourceConfiguration(hiddenID, resource: .backupid),
                        "dateExecuted": (dict.value(forKey: "dateExecuted") as? String)!,
                        "resultExecuted": (dict.value(forKey: "resultExecuted") as? String)!,
                        "hiddenID": hiddenID,
                        "parent": i,
                        "sibling": j]
                    data.append(logdetail)
                }
            }
        }
        let dateformatter = Tools().setDateformat()
        self.loggdata = data.sorted { (dict1, dict2) -> Bool in
            guard dateformatter.date(from: (dict1.value(forKey: "dateExecuted") as? String)!) != nil && (dateformatter.date(from: (dict2.value(forKey: "dateExecuted") as? String)!) != nil) else {
                return true
            }
            if (dateformatter.date(from: (dict1.value(forKey: "dateExecuted") as? String)!))!.timeIntervalSince(dateformatter.date(from: (dict2.value(forKey: "dateExecuted") as? String)!)!) > 0 {
                return true
            } else {
                return false
            }
        }
    }

    func sortbyrundate() {
        guard self.loggdata != nil else { return }
        if self.sortedascendigdesending == true {
            self.sortedascendigdesending = false
        } else {
            self.sortedascendigdesending = true
        }
        let dateformatter = Tools().setDateformat()
        guard self.loggdata != nil else { return }
        let sorted = self.loggdata!.sorted { (dict1, dict2) -> Bool in
            if (dateformatter.date(from: (dict1.value(forKey: "dateExecuted") as? String) ?? "") ?? dateformatter.date(from: "01 Jan 1900 00:00")!).timeIntervalSince(dateformatter.date(from: (dict2.value(forKey: "dateExecuted") as? String) ?? "") ?? dateformatter.date(from: "01 Jan 1900 00:00")!) > 0 {
                return self.sortedascendigdesending
            } else {
                return !self.sortedascendigdesending
            }
        }
        self.loggdata = sorted
    }

    func sortbystring(sortby: Sortstring) {
        guard self.loggdata != nil else { return }
        if self.sortedascendigdesending == true {
            self.sortedascendigdesending = false
        } else {
            self.sortedascendigdesending = true
        }
        var sortstring: String?
        switch sortby {
        case .localcatalog:
            sortstring = "localCatalog"
        case .remoteserver:
            sortstring = "offsiteServer"
        case .task:
            sortstring = "taskCellID"
        case .backupid:
            sortstring = "backupid"
        default:
            sortstring = "localCatalog"
        }
        let sorted = self.loggdata!.sorted { (dict1, dict2) -> Bool in
            if (dict1.value(forKey: sortstring!) as? String) ?? "" > (dict2.value(forKey: sortstring!) as? String) ?? "" {
                return self.sortedascendigdesending
            } else {
                return !self.sortedascendigdesending
            }
        }
        self.loggdata = sorted
    }

    init () {
        // Read and sort loggdata
        if self.loggdata == nil {
            self.readAndSortAllLoggdata()
        }
    }
}
