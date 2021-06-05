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
// swiftlint:disable line_length

import Foundation

enum Sortandfilter {
    case offsitecatalog
    case localcatalog
    case profile
    case offsiteserver
    case task
    case backupid
    case numberofdays
    case executedate
    case none
}

struct Logrecordsschedules {
    var hiddenID: Int
    var localCatalog: String
    var remoteCatalog: String
    var offsiteServer: String
    var task: String
    var backupID: String
    var dateExecuted: String
    var date: Date
    var resultExecuted: String
    var parent: Int
    var sibling: Int
    var delete: Int
    // Snapshots
    var selectCellID: Int?
    var period: String?
    var days: String?
    var snapshotCatalog: String?
    var seconds: Int = 0
}

final class ScheduleLoggData: SetConfigurations, SetSchedules {
    var loggrecords: [Logrecordsschedules]?

    func filter(search: String?) {
        globalDefaultQueue.async { () -> Void in
            self.loggrecords = self.loggrecords?.filter { $0.dateExecuted.contains(search ?? "") }
        }
    }

    private func readandsortallloggdata(hiddenID: Int?) {
        var data = [Logrecordsschedules]()
        if let input: [ConfigurationSchedule] = schedules?.getSchedule() {
            for i in 0 ..< input.count {
                for j in 0 ..< (input[i].logrecords?.count ?? 0) {
                    if let hiddenID = schedules?.getSchedule()?[i].hiddenID {
                        var datestring: String?
                        var date: Date?
                        if let stringdate = input[i].logrecords?[j].dateExecuted {
                            if stringdate.isEmpty == false {
                                datestring = stringdate.en_us_date_from_string().localized_string_from_date()
                                date = stringdate.en_us_date_from_string()
                            }
                        }
                        let record =
                            Logrecordsschedules(hiddenID: hiddenID,
                                                localCatalog: configurations?.getResourceConfiguration(hiddenID, resource: .localCatalog) ?? "",
                                                remoteCatalog: configurations?.getResourceConfiguration(hiddenID, resource: .remoteCatalog) ?? "",
                                                offsiteServer: configurations?.getResourceConfiguration(hiddenID, resource: .offsiteServer) ?? "",
                                                task: configurations?.getResourceConfiguration(hiddenID, resource: .task) ?? "",
                                                backupID: configurations?.getResourceConfiguration(hiddenID, resource: .backupid) ?? "",
                                                dateExecuted: datestring ?? "",
                                                date: date ?? Date(),
                                                resultExecuted: input[i].logrecords?[j].resultExecuted ?? "",
                                                parent: i,
                                                sibling: j,
                                                delete: 0)
                        data.append(record)
                    }
                }
            }
        }
        if hiddenID != nil { data = data.filter { $0.hiddenID == hiddenID } }
        loggrecords = data.sorted(by: \.date, using: >)
    }

    init(hiddenID: Int?) {
        if loggrecords == nil {
            readandsortallloggdata(hiddenID: hiddenID)
        }
    }
}
