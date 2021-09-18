//
//  ScheduleWriteLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 19.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ScheduleWriteLoggData: SetConfigurations, ReloadTable, Deselect {
    var schedules: [ConfigurationSchedule]?
    var profile: String?

    typealias Row = (Int, Int)
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
        WriteScheduleJSON(profile, schedules)
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
                    WriteScheduleJSON(profile, schedules)
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

    init(profile: String?) {
        self.profile = profile
        schedules = nil
    }
}
