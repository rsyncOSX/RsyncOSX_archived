//
//  extensionVCScheduletableviewDelegate.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22/08/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable cyclomatic_complexity function_body_length line_length

import Cocoa
import Foundation

extension ViewControllerSchedule: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.scheduletable {
            return self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
        } else {
            return self.scheduledetails?.count ?? 0
        }
    }
}

extension ViewControllerSchedule: NSTableViewDelegate, Attributedestring {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let tableColumn = tableColumn {
            if tableView == self.scheduletable {
                if row < self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0 {
                    if let object: NSDictionary = self.configurations?.getConfigurationsDataSourceSynchronize()?[row],
                       let hiddenID: Int = object.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int
                    {
                        switch tableColumn.identifier.rawValue {
                        case "scheduleID":
                            if self.sortedandexpanded != nil {
                                let schedule: String? = self.sortedandexpanded?.sortandcountscheduledonetask(hiddenID, profilename: nil, number: false)
                                if schedule?.isEmpty == false {
                                    switch schedule {
                                    case Scheduletype.once.rawValue:
                                        return NSLocalizedString("once", comment: "main")
                                    case Scheduletype.daily.rawValue:
                                        return NSLocalizedString("daily", comment: "main")
                                    case Scheduletype.weekly.rawValue:
                                        return NSLocalizedString("weekly", comment: "main")
                                    case Scheduletype.manuel.rawValue:
                                        return NSLocalizedString("manuel", comment: "main")
                                    default:
                                        return ""
                                    }
                                } else {
                                    return ""
                                }
                            }
                        case DictionaryStrings.offsiteServerCellID.rawValue:
                            if (object[tableColumn.identifier] as? String)!.isEmpty {
                                if self.index() ?? -1 == row, self.index == nil {
                                    return self.attributedstring(str: "localhost", color: NSColor.green, align: .left)
                                } else {
                                    return "localhost"
                                }
                            } else {
                                if self.index() ?? -1 == row, self.index == nil {
                                    let text = object[tableColumn.identifier] as? String
                                    return self.attributedstring(str: text ?? "", color: NSColor.green, align: .left)
                                } else {
                                    return object[tableColumn.identifier] as? String
                                }
                            }
                        case "inCellID":
                            if self.sortedandexpanded != nil {
                                let taskintime: String? = self.sortedandexpanded?.sortandcountscheduledonetask(hiddenID, profilename: nil, number: true)
                                return taskintime ?? ""
                            }
                        case DictionaryStrings.delta.rawValue:
                            let delta = self.sortedandexpanded?.sortedschedules?.filter { $0.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int == hiddenID }
                            if (delta?.count ?? 0) > 0 {
                                if (delta?.count ?? 0) > 1 {
                                    return (delta?[0].value(forKey: DictionaryStrings.delta.rawValue) as? String ?? "") + "(+)"
                                } else {
                                    return delta?[0].value(forKey: DictionaryStrings.delta.rawValue) as? String
                                }
                            }
                        default:
                            if self.index() ?? -1 == row, self.index == nil {
                                let text = object[tableColumn.identifier] as? String
                                return self.attributedstring(str: text!, color: NSColor.green, align: .left)
                            } else {
                                return object[tableColumn.identifier] as? String
                            }
                        }
                    }

                } else {
                    return nil
                }
            } else {
                if row < self.scheduledetails?.count ?? 0 {
                    if let object: NSMutableDictionary = self.scheduledetails?[row],
                       let hiddenID: Int = object.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int
                    {
                        switch tableColumn.identifier.rawValue {
                        case "active":
                            let datestopstring = object.value(forKey: DictionaryStrings.dateStop.rawValue) as? String ?? ""
                            let schedule = object.value(forKey: DictionaryStrings.schedule.rawValue) as? String ?? ""
                            guard datestopstring.isEmpty == false, datestopstring != "no stopdate" else { return nil }
                            let dateStop: Date = datestopstring.en_us_date_from_string()
                            if dateStop.timeIntervalSinceNow > 0, schedule != Scheduletype.stopped.rawValue {
                                return #imageLiteral(resourceName: "complete")
                            } else {
                                return nil
                            }
                        case DictionaryStrings.stopCellID.rawValue, DictionaryStrings.deleteCellID.rawValue:
                            return object[tableColumn.identifier] as? Int
                        case DictionaryStrings.schedule.rawValue:
                            switch object[tableColumn.identifier] as? String {
                            case Scheduletype.once.rawValue:
                                return NSLocalizedString("once", comment: "main")
                            case Scheduletype.daily.rawValue:
                                return NSLocalizedString("daily", comment: "main")
                            case Scheduletype.weekly.rawValue:
                                return NSLocalizedString("weekly", comment: "main")
                            case Scheduletype.manuel.rawValue:
                                return NSLocalizedString("manuel", comment: "main")
                            case Scheduletype.stopped.rawValue:
                                return NSLocalizedString("stopped", comment: "main")
                            default:
                                return ""
                            }
                        case DictionaryStrings.dateStart.rawValue:
                            if object[tableColumn.identifier] as? String == "01 Jan 1900 00:00" {
                                return NSLocalizedString("no startdate", comment: "Schedule details")
                            } else {
                                let stringdate: String = object[tableColumn.identifier] as? String ?? ""
                                if stringdate.isEmpty {
                                    return ""
                                } else {
                                    return stringdate.en_us_date_from_string().localized_string_from_date()
                                }
                            }
                        case DictionaryStrings.dateStop.rawValue:
                            if object[tableColumn.identifier] as? String == "01 Jan 2100 00:00" {
                                return NSLocalizedString("no stopdate", comment: "Schedule details")
                            } else {
                                let stringdate: String = object[tableColumn.identifier] as? String ?? ""
                                if stringdate.isEmpty || stringdate == "no stopdate" {
                                    return ""
                                } else {
                                    return stringdate.en_us_date_from_string().localized_string_from_date()
                                }
                            }
                        case "numberoflogs", "dayinweek":
                            return object[tableColumn.identifier] as? String
                        case "inCellID":
                            let delta = self.sortedandexpanded?.sortedschedules?.filter { $0.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int == hiddenID }
                            if (delta?.count ?? 0) > 0, row < (delta?.count ?? 0) {
                                return delta?[row].value(forKey: DictionaryStrings.startsin.rawValue)
                            } else {
                                return ""
                            }
                        default:
                            return nil
                        }
                    }
                } else {
                    return nil
                }
            }
        }
        return nil
    }

    func tableView(_: NSTableView, setObjectValue _: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if tableColumn!.identifier.rawValue == DictionaryStrings.stopCellID.rawValue || tableColumn!.identifier.rawValue == DictionaryStrings.deleteCellID.rawValue {
            var stop: Int = (self.scheduledetails![row].value(forKey: DictionaryStrings.stopCellID.rawValue) as? Int)!
            var delete: Int = (self.scheduledetails![row].value(forKey: DictionaryStrings.deleteCellID.rawValue) as? Int)!
            if stop == 0 { stop = 1 } else if stop == 1 { stop = 0 }
            if delete == 0 { delete = 1 } else if delete == 1 { delete = 0 }
            switch tableColumn!.identifier.rawValue {
            case DictionaryStrings.stopCellID.rawValue:
                self.scheduledetails![row].setValue(stop, forKey: DictionaryStrings.stopCellID.rawValue)
            case DictionaryStrings.deleteCellID.rawValue:
                self.scheduledetails![row].setValue(delete, forKey: DictionaryStrings.deleteCellID.rawValue)
            default:
                break
            }
        }
    }
}
