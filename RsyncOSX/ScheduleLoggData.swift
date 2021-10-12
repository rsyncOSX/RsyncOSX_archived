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

final class ScheduleLoggData: SetConfigurations, ReloadTable, Deselect {
    var loggrecords: [Logrecordsschedules]?
    var schedules: [ConfigurationSchedule]?

    typealias Row = (Int, Int)

    func filter(search: String?) {
        globalDefaultQueue.async { () -> Void in
            self.loggrecords = self.loggrecords?.filter { $0.dateExecuted.contains(search ?? "") }
        }
    }

    private func readandsortallloggdata(hiddenID: Int?) {
        var data = [Logrecordsschedules]()
        if let input: [ConfigurationSchedule] = schedules {
            for i in 0 ..< input.count {
                for j in 0 ..< (input[i].logrecords?.count ?? 0) {
                    if let hiddenID = schedules?[i].hiddenID {
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

    func deleteselectedrows(scheduleloggdata: ScheduleLoggData?) {
        guard scheduleloggdata?.loggrecords != nil else { return }
        var deletes = [Row]()
        let selectdeletes = scheduleloggdata?.loggrecords?.filter { $0.delete == 1 }.sorted { dict1, dict2 -> Bool in
            if dict1.parent > dict2.parent {
                return true
            } else {
                return false
            }
        }
        for i in 0 ..< (selectdeletes?.count ?? 0) {
            let parent = selectdeletes?[i].parent ?? 0
            let sibling = selectdeletes?[i].sibling ?? 0
            deletes.append((parent, sibling))
        }
        deletes.sort(by: { obj1, obj2 -> Bool in
            if obj1.0 == obj2.0, obj1.1 > obj2.1 {
                return obj1 > obj2
            }
            return obj1 > obj2
        })
        for i in 0 ..< deletes.count {
            schedules?[deletes[i].0].logrecords?.remove(at: deletes[i].1)
        }
        WriteScheduleJSON(configurations?.getProfile(), schedules)
        reloadtable(vcontroller: .vcloggdata)
    }

    func addlogpermanentstore(hiddenID: Int, result: String) {
        if SharedReference.shared.detailedlogging {
            // Set the current date
            let currendate = Date()
            let date = currendate.en_us_string_from_date()
            if let config = getconfig(hiddenID: hiddenID) {
                var resultannotaded: String?
                if config.task == SharedReference.shared.snapshot {
                    let snapshotnum = String(config.snapshotnum ?? 1)
                    resultannotaded = "(" + snapshotnum + ") " + result
                } else {
                    resultannotaded = result
                }
                var inserted: Bool = addlogexisting(hiddenID: hiddenID, result: resultannotaded ?? "", date: date)
                // Record does not exist, create new Schedule (not inserted)
                if inserted == false {
                    inserted = addlognew(hiddenID: hiddenID, result: resultannotaded ?? "", date: date)
                }
                if inserted {
                    WriteScheduleJSON(configurations?.getProfile(), schedules)
                    deselectrowtable(vcontroller: .vctabmain)
                }
            }
        }
    }

    func addlogexisting(hiddenID: Int, result: String, date: String) -> Bool {
        if SharedReference.shared.synctasks.contains(configurations?.getResourceConfiguration(hiddenID, resource: .task) ?? "") {
            if let index = schedules?.firstIndex(where: { $0.hiddenID == hiddenID
                    && $0.schedule == Scheduletype.manuel.rawValue
                    && $0.dateStart == "01 Jan 1900 00:00"
            }) {
                var log = Log()
                log.dateExecuted = date
                log.resultExecuted = result
                schedules?[index].logrecords?.append(log)
                return true
            }
        }
        return false
    }

    func addlognew(hiddenID: Int, result: String, date: String) -> Bool {
        if SharedReference.shared.synctasks.contains(configurations?.getResourceConfiguration(hiddenID, resource: .task) ?? "") {
            var newrecord = ConfigurationSchedule()
            newrecord.hiddenID = hiddenID
            newrecord.dateStart = "01 Jan 1900 00:00"
            newrecord.schedule = Scheduletype.manuel.rawValue
            var log = Log()
            log.dateExecuted = date
            log.resultExecuted = result
            newrecord.logrecords = [Log]()
            newrecord.logrecords?.append(log)
            if schedules == nil {
                schedules = [ConfigurationSchedule]()
            }
            schedules?.append(newrecord)
            return true
        }
        return false
    }

    func getconfig(hiddenID: Int) -> Configuration? {
        let index = configurations?.getIndex(hiddenID) ?? 0
        return configurations?.getConfigurations()?[index]
    }

    deinit {
        schedules = nil
        print("deinit ScheduleLoggData")
    }

    init(hiddenID: Int?) {
        schedules = ReadScheduleJSON(configurations?.getProfile(), configurations?.validhiddenID).schedules
        if loggrecords == nil {
            readandsortallloggdata(hiddenID: hiddenID)
        }
    }
}
