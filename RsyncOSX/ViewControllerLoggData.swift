//
//  ViewControllerLoggData.swift
//  RsyncOSX
//  The ViewController is the logview
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

protocol ReadLoggdata: class {
    func readloggdata()
}

class ViewControllerLoggData: NSViewController, SetSchedules, Delay {

    private var scheduleloggdata: ScheduleLoggData?
    private var row: NSDictionary?
    private var filterby: Sortandfilter?
    private var index: Int?
    private var viewispresent: Bool = false
    private var sortedascendigdesending: Bool = true

    @IBOutlet weak var scheduletable: NSTableView!
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var sorting: NSProgressIndicator!
    @IBOutlet weak var numberOflogfiles: NSTextField!
    @IBOutlet weak var sortdirection: NSButton!

    // Delete row
    @IBOutlet weak var deleteButton: NSButton!
    @IBAction func deleteRow(_ sender: NSButton) {
        guard self.row != nil else {
            self.deleteButton.state = .off
            return
        }
        self.schedules!.deletelogrow(parent: (self.row!.value(forKey: "parent") as? Int)!, sibling: (self.row!.value(forKey: "sibling") as? Int)!)
        self.sorting.startAnimation(self)
        self.deleteButton.state = .off
        self.deselectRow()
    }

    @IBAction func sortdirection(_ sender: NSButton) {
        if self.sortedascendigdesending == true {
            self.sortedascendigdesending = false
            self.sortdirection.image = #imageLiteral(resourceName: "down")
        } else {
            self.sortedascendigdesending = true
            self.sortdirection.image = #imageLiteral(resourceName: "up")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        self.search.delegate = self
        self.sorting.usesThreadedAnimation = true
        ViewControllerReference.shared.setvcref(viewcontroller: .vcloggdata, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewispresent = true
        self.scheduleloggdata = ScheduleLoggData()
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
        self.row = nil
        self.sortdirection.image = #imageLiteral(resourceName: "up")
        self.sortedascendigdesending = true
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.scheduleloggdata = nil
        self.viewispresent = false
    }

    private func deselectRow() {
        guard self.index != nil else { return }
        self.scheduletable.deselectRow(self.index!)
    }
}

extension ViewControllerLoggData: NSSearchFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        self.delayWithSeconds(0.25) {
            let filterstring = self.search.stringValue
            self.sorting.startAnimation(self)
            if filterstring.isEmpty {
                globalMainQueue.async(execute: { () -> Void in
                    self.scheduleloggdata = ScheduleLoggData()
                    self.scheduletable.reloadData()
                    self.sorting.stopAnimation(self)
                })
            } else {
                globalMainQueue.async(execute: { () -> Void in
                    self.scheduleloggdata!.filter(search: filterstring, filterby: self.filterby)
                    self.scheduletable.reloadData()
                    self.sorting.stopAnimation(self)
                })
            }
        }
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.index = nil
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
    }

}

extension ViewControllerLoggData: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if self.scheduleloggdata == nil {
            self.numberOflogfiles.stringValue = "Number of rows:"
            return 0
        } else {
            self.numberOflogfiles.stringValue = "Number of rows: " + String(self.scheduleloggdata!.loggdata?.count ?? 0)
            return self.scheduleloggdata!.loggdata?.count ?? 0
        }
    }

}

extension ViewControllerLoggData: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.scheduleloggdata != nil else { return nil }
        guard row < self.scheduleloggdata!.loggdata!.count else { return nil }
        let object: NSDictionary = self.scheduleloggdata!.loggdata![row]
        return object[tableColumn!.identifier] as? String
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.row = self.scheduleloggdata?.loggdata![self.index!]
        }
        let column = myTableViewFromNotification.selectedColumn
        var sortbystring = true
        switch column {
        case 0:
             self.filterby = .task
        case 1:
            self.filterby = .backupid
        case 2:
            self.filterby = .localcatalog
        case 3:
            self.filterby = .remoteserver
        case 4:
            sortbystring = false
            self.filterby = .executedate
        default:
            return
        }
        if sortbystring {
            self.scheduleloggdata?.loggdata = self.scheduleloggdata!.sortbystring(notsorted: self.scheduleloggdata?.loggdata, sortby: self.filterby!, sortdirection: self.sortedascendigdesending)
        } else {
            self.scheduleloggdata?.loggdata = self.scheduleloggdata!.sortbyrundate(notsorted: self.scheduleloggdata?.loggdata, sortdirection: self.sortedascendigdesending)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
    }

}

extension ViewControllerLoggData: Reloadandrefresh {

    func reloadtabledata() {
        self.scheduleloggdata = ScheduleLoggData()
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
        self.row = nil
    }
}

extension ViewControllerLoggData: ReadLoggdata {
    func readloggdata() {
        // Triggered after a delete of log row
        if viewispresent {
            self.scheduleloggdata = nil
            globalMainQueue.async(execute: { () -> Void in
                self.scheduleloggdata = ScheduleLoggData()
                self.scheduletable.reloadData()
                self.sorting.stopAnimation(self)
            })
            self.deleteButton.state = .off
        }
    }
}
