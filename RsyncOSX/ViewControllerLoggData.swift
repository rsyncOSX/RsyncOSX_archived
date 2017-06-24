//
//  ViewControllerLoggData.swift
//  RsyncOSX
//  The ViewController is the logview
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa


class ViewControllerLoggData : NSViewController {
    
    // Reference to variable holding tabledata
    var tabledata:[NSDictionary]?
    // Reference to variable selected row as NSDictionary
    var row:NSDictionary?
    // Search after
    var what:filterLogs?
    // Index selected row
    var index:Int?


    @IBOutlet weak var scheduletable: NSTableView!
    // Search field
    @IBOutlet weak var search: NSSearchField!
    // Buttons
    @IBOutlet weak var server: NSButton!
    @IBOutlet weak var Catalog: NSButton!
    @IBOutlet weak var date: NSButton!
    // Progressview loading loggdata
    @IBOutlet weak var sorting: NSProgressIndicator!
    @IBOutlet weak var numberOflogfiles: NSTextField!
    
    // Selecting what to filter
    @IBAction func Radiobuttons(_ sender: NSButton) {
        if (self.server.state == NSControl.StateValue.onState) {
            self.what = .remoteServer
        } else if (self.Catalog.state == NSControl.StateValue.onState) {
            self.what = .localCatalog
        } else if (self.date.state == NSControl.StateValue.onState) {
            self.what = .executeDate
        }
        self.filterLogg()
    }
    
    // Delete row
    @IBOutlet weak var deleteButton: NSButton!
    @IBAction func deleteRow(_ sender: NSButton) {
        guard self.row != nil else {
            self.deleteButton.state = NSControl.StateValue.offState
            return
        }
        /* ScheduleWriteLoggData
        let delete = ScheduleWriteLoggData(schedule: SharingManagerSchedule.sharedInstance.getSchedule())
        delete.deleteLogRow(hiddenID: self.row?.value(forKey: "hiddenID") as! Int,
                            parent: self.row?.value(forKey: "parent") as! String,
                            resultExecuted: self.row?.value(forKey: "resultExecuted") as! String,
                            dateExecuted:self.row?.value(forKey: "dateExecuted") as! String)
        */
        
        SharingManagerSchedule.sharedInstance.deleteLogRow(hiddenID: self.row?.value(forKey: "hiddenID") as! Int,
                                                           parent: self.row?.value(forKey: "parent") as! String,
                                                           resultExecuted: self.row?.value(forKey: "resultExecuted") as! String,
                                                           dateExecuted:self.row?.value(forKey: "dateExecuted") as! String)
        self.deleteButton.state = NSControl.StateValue.offState
        self.deselectRow()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        self.search.delegate = self
        self.sorting.usesThreadedAnimation = true
        // Reference to LogViewController
        SharingManagerConfiguration.sharedInstance.ViewControllerLoggData = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        GlobalMainQueue.async(execute: { () -> Void in
            self.sorting.startAnimation(self)
            self.tabledata = ScheduleLoggData().filter(search: nil, what:nil)
            self.scheduletable.reloadData()
            self.sorting.stopAnimation(self)
        })
        self.server.state = NSControl.StateValue.offState
        self.Catalog.state = NSControl.StateValue.offState
        self.date.state = NSControl.StateValue.offState
        self.what = .remoteServer
        self.deleteButton.state = NSControl.StateValue.offState
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.sorting.startAnimation(self)
        self.tabledata = nil
    }
    
    // deselect a row after row is deleted
    private func deselectRow() {
        guard self.index != nil else {
            return
        }
        self.scheduletable.deselectRow(self.index!)
    }
    
    // filter data
    fileprivate func filterLogg() {
        
        guard self.index != nil else {
            return
        }
        
        guard self.index! < self.tabledata!.count else {
            return
        }
        
        self.row = self.tabledata?[self.index!]
        if (self.server.state == NSControl.StateValue.onState) {
            if let server = self.row?.value(forKey: "offsiteServer") as? String {
                self.search.stringValue = server
                self.searchFieldDidStartSearching(self.search)
            }
        } else if (self.Catalog.state == NSControl.StateValue.onState) {
            if let server = self.row?.value(forKey: "localCatalog") as? String {
                self.search.stringValue = server
                self.searchFieldDidStartSearching(self.search)
            }
        } else if (self.date.state == NSControl.StateValue.onState) {
            if let server = self.row?.value(forKey: "dateExecuted") as? String {
                self.search.stringValue = server
                self.searchFieldDidStartSearching(self.search)
            }
        }
    
    }
}


extension ViewControllerLoggData : NSSearchFieldDelegate {
    
    func searchFieldDidStartSearching(_ sender: NSSearchField){
        self.sorting.startAnimation(self)
        if (sender.stringValue.isEmpty) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.tabledata = ScheduleLoggData().filter(search: nil, what:nil)
                self.scheduletable.reloadData()
                self.sorting.stopAnimation(self)
            })
        } else {
            GlobalMainQueue.async(execute: { () -> Void in
                self.tabledata = ScheduleLoggData().filter(search: sender.stringValue, what:self.what)
                self.scheduletable.reloadData()
                self.sorting.stopAnimation(self)
            })
        }
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField){
        self.index = nil
        GlobalMainQueue.async(execute: { () -> Void in
            self.tabledata = ScheduleLoggData().filter(search: nil, what:nil)
            self.scheduletable.reloadData()
        })
        self.server.state = NSControl.StateValue.offState
        self.Catalog.state = NSControl.StateValue.offState
        self.date.state = NSControl.StateValue.offState
    }
    
}

extension ViewControllerLoggData : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if (self.tabledata == nil ) {
            self.numberOflogfiles.stringValue = "Number of logs: 0"
            return 0
        } else {
            self.numberOflogfiles.stringValue = "Number of logs: " + String(self.tabledata!.count)
            return (self.tabledata!.count)
        }
    }
    
}

extension ViewControllerLoggData : NSTableViewDelegate {
    
    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let object:NSDictionary = self.tabledata![row]
        return object[tableColumn!.identifier] as? String
    }
    
    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = notification.object as! NSTableView
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.filterLogg()
        }
    }

}

extension ViewControllerLoggData: RefreshtableView {
    
    // Refresh tableView
    func refresh() {
        GlobalMainQueue.async(execute: { () -> Void in
            self.tabledata = ScheduleLoggData().filter(search: nil, what:nil)
            self.scheduletable.reloadData()
        })
        self.row = nil
    }
}



