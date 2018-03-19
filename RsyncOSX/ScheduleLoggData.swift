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

final class ScheduleLoggData: SetConfigurations, SetSchedules {

    var loggdata: [NSMutableDictionary]?
    private var sortedascendigdesending: Bool = false
    weak var sortdirection: Sortdirection?

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
        self.loggdata = self.sortbyrundate(notsorted: data)
    }

    func sortbyrundate(notsorted: [NSMutableDictionary]?) -> [NSMutableDictionary]? {
        guard notsorted != nil else { return nil }
        if self.sortedascendigdesending == true {
            self.sortedascendigdesending = false
            self.sortdirection?.sortdirection(directionup: false)
        } else {
            self.sortedascendigdesending = true
            self.sortdirection?.sortdirection(directionup: true)
        }
        let dateformatter = Tools().setDateformat()
        let sorted = notsorted!.sorted { (dict1, dict2) -> Bool in
            let date1 = (dateformatter.date(from: (dict1.value(forKey: "dateExecuted") as? String) ?? "") ?? dateformatter.date(from: "01 Jan 1900 00:00")!)
            let date2 = (dateformatter.date(from: (dict2.value(forKey: "dateExecuted") as? String) ?? "") ?? dateformatter.date(from: "01 Jan 1900 00:00")!)
            if date1.timeIntervalSince(date2) > 0 {
                return self.sortedascendigdesending
            } else {
                return !self.sortedascendigdesending
            }
        }
        return sorted
    }

    func sortbystring(notsorted: [NSMutableDictionary]?, sortby: Sortandfilter) -> [NSMutableDictionary]? {
         guard notsorted != nil else { return nil }
        if self.sortedascendigdesending == true {
            self.sortedascendigdesending = false
            self.sortdirection?.sortdirection(directionup: false)
        } else {
            self.sortedascendigdesending = true
            self.sortdirection?.sortdirection(directionup: true)
        }
        var sortstring: String?
        switch sortby {
        case .localcatalog:
            sortstring = "localCatalog"
        case .remoteserver:
            sortstring = "offsiteServer"
        case .task:
            sortstring = "task"
        case .backupid:
            sortstring = "backupID"
        default:
            sortstring = "localCatalog"
        }
        let sorted = notsorted!.sorted { (dict1, dict2) -> Bool in
            if (dict1.value(forKey: sortstring!) as? String) ?? "" > (dict2.value(forKey: sortstring!) as? String) ?? "" {
                return self.sortedascendigdesending
            } else {
                return !self.sortedascendigdesending
            }
        }
        return sorted
    }

    init () {
        // Read and sort loggdata
        if self.loggdata == nil {
            self.readAndSortAllLoggdata()
        }
        self.sortdirection = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
    }
}
