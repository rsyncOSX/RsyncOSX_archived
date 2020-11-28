//
//  extensionVCMaintableviewDelegate.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable cyclomatic_complexity line_length function_body_length

import Cocoa
import Foundation

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
        return self.configurations?.configurationsDataSource?.count ?? 0
    }
}

extension ViewControllerMain: NSTableViewDelegate {
    // setting which table row is selected, force new estimation
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.seterrorinfo(info: "")
        // If change row during estimation
        if ViewControllerReference.shared.process != nil, self.index != nil { self.abortOperations() }
        self.backupdryrun.state = .on
        self.info.stringValue = Infoexecute().info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.indexes = self.mainTableView.selectedRowIndexes
            if self.lastindex != index {
                self.singletask = nil
            }
            self.lastindex = index
        } else {
            self.index = nil
            self.indexes = nil
            self.singletask = nil
            self.reloadtabledata()
        }
        self.reset()
        self.showrsynccommandmainview()
    }

    func tableView(_: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        if edge == .leading {
            let delete = NSTableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Main")) { _, _ in
                self.deleterow(index: row)
            }
            return [delete]
        } else {
            let execute = NSTableViewRowAction(style: .regular, title: NSLocalizedString("Execute", comment: "Main")) { _, _ in
                if self.index != nil, self.singletask != nil {
                    if self.index == row { self.executeSingleTask() }
                } else {
                    self.executetask(index: row)
                }
            }
            execute.backgroundColor = NSColor.gray
            return [execute]
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard self.configurations != nil else { return nil }
        if row > (self.configurations?.configurationsDataSource?.count ?? 0) - 1 { return nil }
        if let object: NSDictionary = self.configurations?.getConfigurationsDataSource()?[row],
           let hiddenID: Int = self.configurations?.getConfigurations()?[row].hiddenID,
           let markdays: Bool = self.configurations?.getConfigurations()?[row].markdays,
           let tableColumn = tableColumn
        {
            let cellIdentifier: String = tableColumn.identifier.rawValue
            switch cellIdentifier {
            case DictionaryStrings.taskCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                    cell.imageView?.image = nil
                    cell.imageView?.alignment = .right
                    if row == self.index {
                        if self.singletask != nil {
                            cell.imageView?.image = NSImage(#imageLiteral(resourceName: "green"))
                        }
                    }
                    return cell
                }
            case DictionaryStrings.offsiteServerCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                    if cell.textField?.stringValue.isEmpty ?? true {
                        cell.textField?.stringValue = DictionaryStrings.localhost.rawValue
                    }
                    if self.configurations?.tcpconnections?.connectionscheckcompleted ?? false == true {
                        if (self.configurations?.tcpconnections?.gettestAllremoteserverConnections()?[row]) ?? false,
                           tableColumn.identifier.rawValue == DictionaryStrings.offsiteServerCellID.rawValue
                        {
                            cell.textField?.textColor = setcolor(nsviewcontroller: self, color: .red)
                        } else {
                            cell.textField?.textColor = setcolor(nsviewcontroller: self, color: .black)
                        }
                    }
                    return cell
                }
            case DictionaryStrings.ShellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = ""
                    cell.imageView?.image = nil
                    let pre = object.value(forKey: DictionaryStrings.executepretask.rawValue) as? Int ?? 0
                    let post = object.value(forKey: DictionaryStrings.executeposttask.rawValue) as? Int ?? 0
                    if pre == 1 || post == 1 {
                        cell.imageView?.image = NSImage(#imageLiteral(resourceName: "green"))
                        cell.imageView?.alignment = .right
                    }
                    return cell
                }
            case DictionaryStrings.schedCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    if let obj = self.schedulesortedandexpanded {
                        cell.textField?.stringValue = ""
                        cell.imageView?.image = nil
                        if obj.numberoftasks(hiddenID).0 > 0 {
                            if obj.numberoftasks(hiddenID).1 > 3600 {
                                cell.imageView?.image = NSImage(#imageLiteral(resourceName: "yellow"))
                            } else {
                                cell.imageView?.image = NSImage(#imageLiteral(resourceName: "green"))
                            }
                            cell.imageView?.alignment = .right
                        }
                    }
                    return cell
                }
            case DictionaryStrings.snapCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    let snap = object.value(forKey: DictionaryStrings.snapCellID.rawValue) as? Int ?? -1
                    if snap > 0 {
                        cell.textField?.stringValue = String(snap - 1)
                    } else {
                        cell.textField?.stringValue = ""
                    }
                    return cell
                }
            case DictionaryStrings.runDateCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    let stringdate = object.value(forKey: DictionaryStrings.runDateCellID.rawValue) as? String ?? ""
                    if stringdate.isEmpty {
                        cell.textField?.stringValue = ""
                    } else {
                        cell.textField?.stringValue = stringdate.en_us_date_from_string().localized_string_from_date()
                    }
                    return cell
                }
            case DictionaryStrings.daysID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                    cell.textField?.alignment = .right
                    if markdays {
                        cell.textField?.textColor = setcolor(nsviewcontroller: self, color: .red)
                    } else {
                        cell.textField?.textColor = setcolor(nsviewcontroller: self, color: .black)
                    }
                    return cell
                }
            default:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                    return cell
                }
            }
        }
        return nil
    }
}
