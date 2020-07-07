//
//  extensionVCMaintableviewDelegate.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable cyclomatic_complexity function_body_length

import Cocoa
import Foundation

// Dismiss view when rsync error
protocol ReportonandhaltonError: AnyObject {
    func reportandhaltonerror()
}

protocol Attributedestring: AnyObject {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString
}

extension Attributedestring {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: str)
        let range = (str as NSString).range(of: str)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        attributedString.setAlignment(align, range: range)
        return attributedString
    }
}

extension ViewControllerMain: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in _: NSTableView) -> Int {
        return self.configurations?.configurationsDataSourcecount() ?? 0
    }
}

extension ViewControllerMain: NSTableViewDelegate, Attributedestring {
    // TableView delegates
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
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
                return stringdate.en_us_date_from_string().localized_string_from_date()
            }
        } else {
            if self.configurations?.tcpconnections?.connectionscheckcompleted ?? false == true {
                if (self.configurations?.tcpconnections?.gettestAllremoteserverConnections()?[row]) ?? false,
                    tableColumn!.identifier.rawValue == "offsiteServerCellID" {
                    return self.attributedstring(str: celltext ?? "", color: NSColor.red, align: .left)
                } else {
                    return object[tableColumn!.identifier] as? String
                }
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
        return nil
    }

    // when row is selected
    // setting which table row is selected, force new estimation
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.seterrorinfo(info: "")
        // If change row during estimation
        if ViewControllerReference.shared.process != nil { self.abortOperations() }
        self.backupdryrun.state = .on
        self.info.stringValue = Infoexecute().info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.indexes = self.mainTableView.selectedRowIndexes
        } else {
            self.index = nil
            self.indexes = nil
        }
        self.reset()
        self.showrsynccommandmainview()
        self.reloadtabledata()
    }
}
