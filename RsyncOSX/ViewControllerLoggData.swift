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

    var scheduleloggdata: ScheduleLoggData?
    var row: NSDictionary?
    var filterby: Filterlogs?
    var index: Int?
    var viewispresent: Bool = false

    @IBOutlet weak var scheduletable: NSTableView!
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var server: NSButton!
    @IBOutlet weak var catalog: NSButton!
    @IBOutlet weak var date: NSButton!
    @IBOutlet weak var sorting: NSProgressIndicator!
    @IBOutlet weak var numberOflogfiles: NSTextField!

    // Selecting what to filter
    @IBAction func radiobuttons(_ sender: NSButton) {
        if self.server.state == .on {
            self.filterby = .remoteServer
        } else if self.catalog.state == .on {
            self.filterby = .localCatalog
        } else if self.date.state == .on {
            self.filterby = .executeDate
        }
    }

    // Delete row
    @IBOutlet weak var deleteButton: NSButton!
    @IBAction func deleteRow(_ sender: NSButton) {
        guard self.row != nil else {
            self.deleteButton.state = .off
            return
        }
        self.schedules!.deletelogrow(parent: (self.row!.value(forKey: "parent") as? Int)!, sibling: (self.row!.value(forKey: "sibling") as? Int)!)
        self.deleteButton.state = .off
        self.deselectRow()
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
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.sorting.startAnimation(self)
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
            guard self.server.state.rawValue == 1 ||
                self.catalog.state.rawValue == 1 ||
                self.date.state.rawValue == 1 else { return }
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
                    self.scheduleloggdata!.filter(search: filterstring, what: self.filterby)
                    self.scheduletable.reloadData()
                    self.sorting.stopAnimation(self)
                })
            }
        }
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.index = nil
        globalMainQueue.async(execute: { () -> Void in
            // self.scheduleloggdata = ScheduleLoggData().getallloggdata()
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
            self.numberOflogfiles.stringValue = "Number of rows: " + String(self.scheduleloggdata!.getallloggdata()!.count)
            return self.scheduleloggdata!.getallloggdata()!.count
        }
    }

}

extension ViewControllerLoggData: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.scheduleloggdata != nil else { return nil }
        let object: NSDictionary = self.scheduleloggdata!.getallloggdata()![row]
        return object[tableColumn!.identifier] as? String
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.row = self.scheduleloggdata?.getallloggdata()![self.index!]
        }
        let column = myTableViewFromNotification.selectedColumn
        if column == 0 {
            self.filterby = .task
        } else if column == 1 {
            self.filterby = .localCatalog
            self.scheduleloggdata!.sortbystring(sortby: .localcatalog)
        } else if column == 2 {
            self.filterby = .remoteServer
        } else if column == 3 {
            self.filterby = .executeDate
        }
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
    }

}

extension ViewControllerLoggData: Reloadandrefresh {

    func reloadtabledata() {
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
        self.row = nil
    }
}

extension ViewControllerLoggData: ReadLoggdata {
    func readloggdata() {
        if viewispresent {
            self.scheduleloggdata = nil
            globalMainQueue.async(execute: { () -> Void in
                self.sorting.startAnimation(self)
                self.scheduleloggdata = ScheduleLoggData()
                self.scheduletable.reloadData()
                self.sorting.stopAnimation(self)
            })
            self.catalog.state = .on
            self.filterby = .localCatalog
            self.deleteButton.state = .off
        }
    }
}
