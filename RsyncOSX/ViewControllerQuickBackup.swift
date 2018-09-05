//
//  ViewControllerQuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerQuickBackup: NSViewController, SetDismisser, AbortTask, Delay {

    var seconds: Int?
    var row: Int?
    var filterby: Sortandfilter?
    var quickbackup: QuickBackup?
    var executing: Bool = false
    weak var inprogresscountDelegate: Count?
    var max: Double?

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet weak var abortbutton: NSButton!
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var noestimates: NSTextField!
    @IBOutlet weak var completed: NSTextField!
    
    // Either abort or close
    @IBAction func abort(_ sender: NSButton) {
        self.quickbackup = nil
        self.abort()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Execute batch
    @IBAction func execute(_ sender: NSButton) {
        self.executing = true
        self.executeButton.isEnabled = false
        self.quickbackup?.prepareandstartexecutetasks()
        if self.checkforestimates() == true {
            self.initiateProgressbar()
        }
        self.reloadtabledata()
    }

    private func loadtasks() {
        self.completed.isHidden = true
        self.quickbackup = QuickBackup()
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inprogresscountDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        ViewControllerReference.shared.setvcref(viewcontroller: .vcquickbackup, nsviewcontroller: self)
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.search.delegate = self
        self.loadtasks()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.executeButton.isEnabled = false
        self.progress.isHidden = true
        if let execute = self.enableexecutebutton() {
            if execute {
                self.executing = true
                self.executeButton.isEnabled = false
                self.quickbackup?.prepareandstartexecutetasks()
                if self.checkforestimates() == true {
                    self.initiateProgressbar()
                }
            }
        }
        self.reloadtabledata()
        _ = self.checkforestimates()
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard self.executing == false else { return }
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let column = myTableViewFromNotification.selectedColumn
        if column == 3 {
            self.filterby = .localcatalog
            self.quickbackup?.sortbystrings(sort: .localCatalog)
        } else if column == 4 {
            self.filterby = .remotecatalog
            self.quickbackup?.sortbystrings(sort: .offsiteCatalog)
        } else if column == 5 {
            self.filterby = .remoteserver
            self.quickbackup?.sortbystrings(sort: .offsiteServer)
        } else if column == 6 {
            self.filterby = .numberofdays
            self.quickbackup?.sortbydays()
        } else {
            return
        }
    }

    private func enableexecutebutton() -> Bool? {
        let backup = self.quickbackup?.sortedlist!.filter({$0.value(forKey: "selectCellID") as? Int == 1})
        guard backup != nil else { return nil }
        guard self.executing == false else { return nil }
        if backup!.count > 0 {
            self.executeButton.isEnabled = true
            return true
        } else {
            self.executeButton.isEnabled = false
            return false
        }
    }

    // Progress bars
    private func initiateProgressbar() {
        self.progress.isHidden = false
        if let calculatedNumberOfFiles = self.quickbackup?.maxcount {
            self.progress.maxValue = Double(calculatedNumberOfFiles)
            self.max = Double(calculatedNumberOfFiles)
        }
        self.progress.minValue = 0
        self.progress.doubleValue = 0
        self.progress.startAnimation(self)
    }

    private func updateProgressbar() {
        let value = Double((self.inprogresscountDelegate?.inprogressCount())!)
        self.progress.doubleValue = value
    }

    private func checkforestimates() -> Bool {
        if self.quickbackup?.maxcount != nil && self.quickbackup?.maxcount ?? 0  > 0 {
            self.noestimates.isHidden = true
            return true
        } else {
            self.noestimates.isHidden = false
            self.max = nil
            return false
        }
    }

    private func progressintable() -> String {
        let value = Double((self.inprogresscountDelegate?.inprogressCount())!)
        guard self.max != nil else { return ""}
        if ((value/self.max!) * 100) > 100 {
            return "100"
        } else {
            return String(format: "%.0f", ((value/self.max!) * 100))
        }
    }
}

extension ViewControllerQuickBackup: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.quickbackup?.sortedlist?.count ?? 0
    }
}

extension ViewControllerQuickBackup: NSTableViewDelegate, Attributedestring {
    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.quickbackup?.sortedlist != nil else { return nil }
        guard row < self.quickbackup!.sortedlist!.count else { return nil }
        let object: NSDictionary = (self.quickbackup?.sortedlist![row])!
        let hiddenID = object.value(forKey: "hiddenID") as? Int
        if tableColumn!.identifier.rawValue == "daysID" {
            if object.value(forKey: "markdays") as? Bool == true {
                let celltext = object[tableColumn!.identifier] as? String
                return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
            }
        }
        if tableColumn!.identifier.rawValue == "selectCellID" {
            return object[tableColumn!.identifier] as? Int
        }
        if tableColumn!.identifier.rawValue == "completeCellID" {
            if object.value(forKey: "inprogressCellID") as? Bool == true {
                return #imageLiteral(resourceName: "leftarrow")
            }
            if object.value(forKey: "completeCellID") as? Bool == true {
                return #imageLiteral(resourceName: "complete")
            }
        }
        if tableColumn!.identifier.rawValue == "percentCellID" {
            if hiddenID == self.quickbackup?.hiddenID {
                return self.progressintable()
            } else {
                return ""
            }
        }
        return object[tableColumn!.identifier] as? String
    }

    // Toggling selection
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard  self.quickbackup?.sortedlist != nil else { return }
        if tableColumn!.identifier.rawValue == "selectCellID" {
            var select: Int = (self.quickbackup?.sortedlist![row].value(forKey: "selectCellID") as? Int)!
            if select == 0 { select = 1 } else if select == 1 { select = 0 }
            self.quickbackup?.sortedlist![row].setValue(select, forKey: "selectCellID")
        }
        _ = self.enableexecutebutton()
    }
}

extension ViewControllerQuickBackup: Reloadandrefresh {

    // Updates tableview according to progress of batch
    func reloadtabledata() {
        _ = self.enableexecutebutton()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerQuickBackup: CloseViewError {
    func closeerror() {
        self.quickbackup = nil
        self.abort()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }
}

extension ViewControllerQuickBackup: UpdateProgress {

    func processTermination() {
        self.quickbackup?.setcompleted()
        self.quickbackup?.processTermination()
        guard self.quickbackup?.stackoftasktobeexecuted != nil else {
            self.progress.isHidden = true
            self.completed.isHidden = false
            return
        }
        if self.checkforestimates() == true {
            self.progress.stopAnimation(self)
            self.initiateProgressbar()
        }
    }

    func fileHandler() {
        self.updateProgressbar()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerQuickBackup: NSSearchFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        guard self.executing == false else { return }
        self.delayWithSeconds(0.25) {
            let filterstring = self.search.stringValue
            if filterstring.isEmpty {
                globalMainQueue.async(execute: { () -> Void in
                    self.quickbackup?.sortbydays()
                })
            } else {
                globalMainQueue.async(execute: { () -> Void in
                    self.quickbackup?.filter(search: filterstring, filterby: self.filterby)
                })
            }
        }
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        guard self.executing == false else { return }
        globalMainQueue.async(execute: { () -> Void in
            self.loadtasks()
        })
    }
}
