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
        return configurations?.configurations?.count ?? 0
    }
}

extension ViewControllerMain: NSTableViewDelegate {
    // setting which table row is selected, force new estimation
    func tableViewSelectionDidChange(_ notification: Notification) {
        info.stringValue = ""
        // If change row during estimation
        if SharedReference.shared.process != nil, localindex != nil { abortOperations() }
        info.stringValue = Infoexecute().info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            localindex = index
            indexset = mainTableView.selectedRowIndexes
            if lastindex != index {
                singletask = nil
            }
            lastindex = index
        } else {
            localindex = nil
            indexset = nil
            singletask = nil
            reloadtabledata()
        }
        reset()
    }

    func tableView(_: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        guard SharedReference.shared.process == nil else { return [] }
        if edge == .leading {
            let delete = NSTableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Main")) { _, _ in
                self.deleterow(index: row)
            }
            return [delete]
        } else {
            let execute = NSTableViewRowAction(style: .regular, title: NSLocalizedString("Execute", comment: "Main")) { _, _ in
                if self.localindex != nil, self.singletask != nil {
                    if self.localindex == row { self.executeSingleTask() }
                } else {
                    self.executetask(index: row)
                }
            }
            execute.backgroundColor = NSColor.gray
            return [execute]
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard configurations != nil else { return nil }
        if row > (configurations?.configurations?.count ?? 0) - 1 { return nil }
        if let object = configurations?.configurations?[row],
           let markdays: Bool = configurations?.getConfigurations()?[row].markdays,
           let tableColumn = tableColumn
        {
            let cellIdentifier: String = tableColumn.identifier.rawValue
            switch cellIdentifier {
            case DictionaryStrings.taskCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.task
                    cell.imageView?.image = nil
                    cell.imageView?.alignment = .right
                    if row == localindex {
                        if singletask != nil {
                            cell.imageView?.image = NSImage(#imageLiteral(resourceName: "green"))
                        }
                    }
                    return cell
                }
            case DictionaryStrings.offsiteServerCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.offsiteServer
                    if cell.textField?.stringValue.isEmpty ?? true {
                        cell.textField?.stringValue = DictionaryStrings.localhost.rawValue
                    }
                    return cell
                }
            case DictionaryStrings.ShellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = ""
                    cell.imageView?.image = nil
                    let pre = object.executepretask
                    let post = object.executeposttask
                    if pre == 1 || post == 1 {
                        cell.imageView?.image = NSImage(#imageLiteral(resourceName: "green"))
                        cell.imageView?.alignment = .right
                    }
                    return cell
                }
            case DictionaryStrings.snapCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    let snap = object.snapshotnum ?? -1
                    if snap > 0 {
                        cell.textField?.stringValue = String(snap - 1)
                    } else {
                        cell.textField?.stringValue = ""
                    }
                    return cell
                }
            case DictionaryStrings.runDateCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    let stringdate = object.dateRun ?? ""
                    if stringdate.isEmpty {
                        if singletask == nil {
                            cell.textField?.stringValue = "not verified (dryrun)"
                        }
                        if singletask != nil && row == localindex {
                            cell.textField?.stringValue = Date().localized_string_from_date()
                        }
                        cell.textField?.textColor = setcolor(nsviewcontroller: self, color: .red)
                    } else {
                        cell.textField?.stringValue = stringdate.en_us_date_from_string().localized_string_from_date()
                        cell.textField?.textColor = setcolor(nsviewcontroller: self, color: .black)
                    }
                    return cell
                }
            case DictionaryStrings.daysID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    var dayssincelastbackup: String? {
                        if let date = object.dateRun {
                            let lastbackup = date.en_us_date_from_string()
                            let seconds: TimeInterval = lastbackup.timeIntervalSinceNow * -1
                            return String(format: "%.2f", seconds / (60 * 60 * 24))
                        } else {
                            return nil
                        }
                    }

                    cell.textField?.stringValue = dayssincelastbackup ?? ""
                    cell.textField?.alignment = .right
                    if markdays {
                        cell.textField?.textColor = setcolor(nsviewcontroller: self, color: .red)
                    } else {
                        cell.textField?.textColor = setcolor(nsviewcontroller: self, color: .black)
                    }
                    return cell
                }
            case DictionaryStrings.localCatalogCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.localCatalog
                    return cell
                }
            case DictionaryStrings.offsiteCatalogCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.offsiteCatalog
                    return cell
                }
            case DictionaryStrings.offsiteServerCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.offsiteServer
                    return cell
                }
            case DictionaryStrings.backupIDCellID.rawValue:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.backupID
                    return cell
                }
            default:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = ""
                    return cell
                }
            }
        }
        return nil
    }
}
