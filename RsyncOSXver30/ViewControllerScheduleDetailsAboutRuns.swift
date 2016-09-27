//
//  ViewControllerScheduleDetailsAboutRuns.swift
//  RsyncOSX
//  The ViewController is the logview
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerScheduleDetailsAboutRuns : NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate {
    
    @IBOutlet weak var scheduletable: NSTableView!
    var tabledata:[NSMutableDictionary]?
    // Search field
    @IBOutlet weak var search: NSSearchField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        self.search.delegate = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        GlobalMainQueue.async(execute: { () -> Void in
            self.tabledata = ScheduleDetailsAboutRuns().filter(search: nil)
            self.scheduletable.reloadData()
        })
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField){
        if (sender.stringValue.isEmpty) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.tabledata = ScheduleDetailsAboutRuns().filter(search: nil)
                self.scheduletable.reloadData()
            })
        } else {
            GlobalMainQueue.async(execute: { () -> Void in
                self.tabledata = ScheduleDetailsAboutRuns().filter(search: sender.stringValue)
                self.scheduletable.reloadData()
            })
        }
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField){
        GlobalMainQueue.async(execute: { () -> Void in
            self.tabledata = ScheduleDetailsAboutRuns().filter(search: nil)
            self.scheduletable.reloadData()
        })
    }

    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let object:NSMutableDictionary = self.tabledata![row]
        return object[tableColumn!.identifier] as? String
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if (self.tabledata == nil ) {
            return 0
        } else {
            return (self.tabledata!.count)
        }
    }

    
}
