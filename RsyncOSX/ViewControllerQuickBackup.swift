//
//  ViewControllerQuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity

import Cocoa
import Foundation

protocol SynchronizeallCompleted: AnyObject {
    func synchronizeallcompleted()
}

class ViewControllerQuickBackup: NSViewController, SetDismisser, Abort, Delay, Setcolor {
    var seconds: Int?
    var row: Int?
    var filterby: Sortandfilter?
    var synchronizealltasksnow: SynchronizeAlltasksNow?
    var executing: Bool = true
    var max: Double?
    var maxInt: Int?
    var diddissappear: Bool = false
    var indexinitiated: Int = -1

    @IBOutlet var mainTableView: NSTableView!
    @IBOutlet var abortbutton: NSButton!
    @IBOutlet var completed: NSTextField!
    @IBOutlet var inwork: NSProgressIndicator!

    // Either abort or close
    @IBAction func abort(_: NSButton) {
        synchronizealltasksnow?.abort()
        synchronizealltasksnow = nil
        abort()
        if (presentingViewController as? ViewControllerMain) != nil {
            dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (presentingViewController as? ViewControllerNewConfigurations) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcnewconfigurations)
        } else if (presentingViewController as? ViewControllerRestore) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcrestore)
        } else if (presentingViewController as? ViewControllerSnapshots) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        } else if (presentingViewController as? ViewControllerSsh) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcssh)
        } else if (presentingViewController as? ViewControllerLoggData) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SharedReference.shared.setvcref(viewcontroller: .vcquickbackup, nsviewcontroller: self)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        completed.isHidden = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard diddissappear == false else {
            globalMainQueue.async { () in
                self.mainTableView.reloadData()
            }
            return
        }
        synchronizealltasksnow = SynchronizeAlltasksNow()
        globalMainQueue.async { () in
            self.mainTableView.reloadData()
        }
        inwork.startAnimation(self)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        diddissappear = true
        // release the quickobject
        synchronizealltasksnow = nil
    }

    private func initiateProgressbar(progress: NSProgressIndicator) {
        progress.isHidden = false
        if let calculatedNumberOfFiles = synchronizealltasksnow?.maxcount {
            progress.maxValue = Double(calculatedNumberOfFiles)
            max = Double(calculatedNumberOfFiles)
            maxInt = calculatedNumberOfFiles
        }
        progress.minValue = 0
        progress.doubleValue = 0
        progress.startAnimation(self)
    }

    private func updateProgressbar(progress: NSProgressIndicator) {
        let value = Double((synchronizealltasksnow?.outputprocess?.getOutput()?.count) ?? 0)
        progress.doubleValue = value
    }
}

extension ViewControllerQuickBackup: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return synchronizealltasksnow?.sortedlist?.count ?? 0
    }
}

extension ViewControllerQuickBackup: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard synchronizealltasksnow?.sortedlist != nil else { return nil }
        guard row < (synchronizealltasksnow?.sortedlist?.count ?? 0) else { return nil }
        if let object: NSDictionary = synchronizealltasksnow?.sortedlist?[row],
           let cellIdentifier: String = tableColumn?.identifier.rawValue
        {
            let hiddenID = object.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int
            switch cellIdentifier {
            case "percentCellID":
                guard hiddenID == synchronizealltasksnow?.hiddenID else { return nil }
                if let cell: NSProgressIndicator = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSProgressIndicator {
                    if row > indexinitiated {
                        indexinitiated = row
                        initiateProgressbar(progress: cell)
                    } else {
                        updateProgressbar(progress: cell)
                    }
                    return cell
                }
            case "countCellID":
                guard hiddenID == synchronizealltasksnow?.hiddenID else { return nil }
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    let filestodo = (maxInt ?? 0) - (synchronizealltasksnow?.outputprocess?.getOutput()?.count ?? 0)
                    if filestodo > 0 {
                        cell.textField?.stringValue = String(filestodo)
                        return cell
                    } else {
                        cell.textField?.stringValue = ""
                        return cell
                    }
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

extension ViewControllerQuickBackup: Reloadandrefresh {
    func reloadtabledata() {
        globalMainQueue.async { () in
            self.mainTableView.reloadData()
        }
    }
}

extension ViewControllerQuickBackup: SynchronizeallCompleted {
    func synchronizeallcompleted() {
        completed.isHidden = false
        completed.textColor = setcolor(nsviewcontroller: self, color: .green)
        executing = false
        inwork.stopAnimation(self)
    }
}
