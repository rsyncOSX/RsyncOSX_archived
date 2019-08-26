//
//  extensionVCMaintableviewDelegate.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable cyclomatic_complexity function_body_length

import Foundation
import Cocoa

extension ViewControllerMain: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configurations?.configurationsDataSourcecount() ?? 0
    }
}

extension ViewControllerMain: NSTableViewDelegate, Attributedestring {

    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let dateformatter = Dateandtime().setDateformat()
        if row > self.configurations!.configurationsDataSourcecount() - 1 { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSource()![row]
        let hiddenID: Int = self.configurations!.getConfigurations()[row].hiddenID
        let markdays: Bool = self.configurations!.getConfigurations()[row].markdays
        let celltext = object[tableColumn!.identifier] as? String
        if tableColumn!.identifier.rawValue == "daysID" {
            if markdays {
                return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
            } else {
                return object[tableColumn!.identifier] as? String
            }
        } else if tableColumn!.identifier.rawValue == "offsiteServerCellID",
            ((object[tableColumn!.identifier] as? String)?.isEmpty) == true {
            return "localhost"
        } else if tableColumn!.identifier.rawValue == "schedCellID" {
            if let obj = self.schedulesortedandexpanded {
                if obj.numberoftasks(hiddenID).0 > 0 {
                    if obj.numberoftasks(hiddenID).1 > 3600 {
                        return #imageLiteral(resourceName: "yellow")
                    } else {
                        return #imageLiteral(resourceName: "green")
                    }
                }
            }
        } else if tableColumn!.identifier.rawValue == "statCellID" {
            if row == self.index {
                if self.singletask == nil {
                    return #imageLiteral(resourceName: "yellow")
                } else {
                    return #imageLiteral(resourceName: "green")
                }
            }
        } else if tableColumn!.identifier.rawValue == "snapCellID" {
            let snap = object.value(forKey: "snapCellID") as? Int ?? -1
            if snap > 0 {
                return String(snap - 1)
            } else {
                return ""
            }
        } else if tableColumn!.identifier.rawValue == "runDateCellID" {
            let stringdate: String = object[tableColumn!.identifier] as? String ?? ""
            if stringdate.isEmpty {
                return ""
            } else {
                let date = dateformatter.date(from: stringdate)
                return date?.localizeDate()
            }
        } else {
            if tableColumn!.identifier.rawValue == "batchCellID" {
                return object[tableColumn!.identifier] as? Int
            } else {
                if (self.tcpconnections?.gettestAllremoteserverConnections()?[row]) ?? false && celltext != nil {
                    return self.attributedstring(str: celltext!, color: NSColor.red, align: .left)
                } else {
                    return object[tableColumn!.identifier] as? String
                }
            }
        }
        return nil
    }

    // Toggling batch
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if self.process != nil {
            self.abortOperations()
        }
        if self.configurations!.getConfigurations()[row].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[row].task == ViewControllerReference.shared.snapshot {
            self.configurations!.togglebatch(row)
        }
    }
}
