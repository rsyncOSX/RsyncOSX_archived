//
//  This object stays in memory runtime and holds key data and operations on Schedules.
//  The obect is the model for the Schedules but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  Created by Thomas Evensen on 09/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma line_length

import Cocoa
import Foundation

enum Scheduletype: String {
    case once
    case daily
    case weekly
    case manuel
    case stopped
}

class Schedules: SetConfigurations, Deselect {
    var schedules: [ConfigurationSchedule]?

    // Function adds new Shcedules (plans). Functions writes
    // schedule plans to permanent store.
    func addschedule(_ hiddenID: Int, _ schedule: Scheduletype, _ startdate: Date) {
        var stop: Date?
        var scheduletype: Scheduletype = .once
        if schedule == .once {
            stop = startdate
        } else {
            stop = "01 Jan 2100 00:00".en_us_date_from_string()
        }
        switch schedule {
        case .once:
            scheduletype = .once
        case .daily:
            scheduletype = .daily
        case .weekly:
            scheduletype = .weekly
        default:
            scheduletype = .once
        }
        var newrecord = ConfigurationSchedule()
        newrecord.hiddenID = hiddenID
        newrecord.dateStart = startdate.en_us_string_from_date()
        newrecord.dateStop = stop!.en_us_string_from_date()
        newrecord.schedule = scheduletype.rawValue

        schedules?.append(newrecord)
        WriteScheduleJSON(configurations?.getProfile(), schedules)
    }

    // Function deletes all Schedules by hiddenID. Invoked when Configurations are
    // deleted. When a Configuration are deleted all tasks connected to
    func deletescheduleonetask(hiddenID: Int) {
        var delete: Bool = false
        for i in 0 ..< (schedules?.count ?? 0) where schedules?[i].hiddenID == hiddenID {
            // Mark Schedules for delete
            // Cannot delete in memory, index out of bound is result
            self.schedules?[i].delete = true
            delete = true
        }
        if delete {
            WriteScheduleJSON(configurations?.getProfile(), schedules)
        }
    }

    // Function reads all Schedule data for one task by hiddenID
    func readscheduleonetask(hiddenID: Int?) -> [NSMutableDictionary]? {
        if let hiddenID = hiddenID {
            var data = [NSMutableDictionary]()
            let allschedulesonetask = schedules?.filter { $0.hiddenID == hiddenID }
            for i in 0 ..< (allschedulesonetask?.count ?? 0) {
                let row: NSMutableDictionary = [
                    DictionaryStrings.dateStart.rawValue: allschedulesonetask?[i].dateStart ?? "",
                    "dayinweek": allschedulesonetask?[i].dateStart.en_us_date_from_string().dayNameShort() ?? "",
                    DictionaryStrings.stopCellID.rawValue: 0,
                    DictionaryStrings.deleteCellID.rawValue: 0,
                    DictionaryStrings.dateStop.rawValue: "",
                    DictionaryStrings.schedule.rawValue: allschedulesonetask?[i].schedule ?? "",
                    DictionaryStrings.hiddenID.rawValue: allschedulesonetask?[i].hiddenID ?? 0,
                    "numberoflogs": String(allschedulesonetask?[i].logrecords?.count ?? 0),
                ]
                if allschedulesonetask?[i].dateStop == nil {
                    row.setValue("no stopdate", forKey: DictionaryStrings.dateStop.rawValue)
                } else {
                    row.setValue(allschedulesonetask?[i].dateStop, forKey: DictionaryStrings.dateStop.rawValue)
                }
                if allschedulesonetask?[i].schedule == Scheduletype.stopped.rawValue {
                    row.setValue(1, forKey: DictionaryStrings.stopCellID.rawValue)
                }
                data.append(row)
            }
            // Sorting schedule after dateStart, last startdate on top
            data.sort { sched1, sched2 -> Bool in
                if let date1 = (sched1.value(forKey: DictionaryStrings.dateStart.rawValue) as? String)?.en_us_date_from_string(),
                   let date2 = (sched2.value(forKey: DictionaryStrings.dateStart.rawValue) as? String)?.en_us_date_from_string()
                {
                    if date1 > date2 { return true } else { return false }
                }
                return false
            }
            return data
        }
        return nil
    }

    // Function either deletes or stops Schedules.
    func deleteandstopschedules(data: [NSMutableDictionary]?) {
        var update: Bool = false
        if (data?.count ?? 0) > 0 {
            if let stop = data?.filter({ ($0.value(forKey: DictionaryStrings.stopCellID.rawValue) as? Int) == 1 }) {
                // Stop Schedules
                if stop.count > 0 {
                    update = true
                    for i in 0 ..< stop.count {
                        self.stop(dict: stop[i])
                    }
                }
            }
            if let delete = data?.filter({ ($0.value(forKey: DictionaryStrings.deleteCellID.rawValue) as? Int) == 1 }) {
                if delete.count > 0 {
                    update = true
                    for i in 0 ..< delete.count {
                        self.delete(dict: delete[i])
                    }
                }
            }
            if update {
                WriteScheduleJSON(configurations?.getProfile(), schedules)
            }
        }
    }

    // Test if Schedule record in memory is set to delete or not
    func delete(dict: NSDictionary) {
        if let hiddenID = dict.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int {
            if let schedule = dict.value(forKey: DictionaryStrings.schedule.rawValue) as? String {
                if let datestart = dict.value(forKey: DictionaryStrings.dateStart.rawValue) as? String {
                    if let i = schedules?.firstIndex(where: { $0.hiddenID == hiddenID
                            && $0.schedule == schedule
                            && $0.dateStart == datestart
                    }) {
                        schedules?[i].delete = true
                    }
                }
            }
        }
    }

    // Test if Schedule record in memory is set to stop er not
    func stop(dict: NSDictionary) {
        if let hiddenID = dict.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int {
            if let schedule = dict.value(forKey: DictionaryStrings.schedule.rawValue) as? String {
                if let datestart = dict.value(forKey: DictionaryStrings.dateStart.rawValue) as? String {
                    if let i = schedules?.firstIndex(where: { $0.hiddenID == hiddenID
                            && $0.schedule == schedule
                            && $0.dateStart == datestart
                    }) {
                        schedules?[i].schedule = Scheduletype.stopped.rawValue
                        schedules?[i].dateStop = Date().en_us_string_from_date()
                    }
                }
            }
        }
    }

    deinit {
        schedules = nil
        // print("deinit Schedules")
    }

    init() {
        schedules = ReadScheduleJSON(configurations?.getProfile(), configurations?.validhiddenID).schedules
        if schedules == nil {
            schedules = [ConfigurationSchedule]()
        }
    }
}
