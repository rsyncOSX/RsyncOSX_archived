//
//  ViewControllerAllProfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 07.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerAllProfiles: NSViewController, Delay {

    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var search: NSSearchField!

    private var allprofiles: AllProfiles?
    private var column: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.search.delegate = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.allprofiles = AllProfiles()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerAllProfiles: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.allprofiles?.allconfigurationsasdictionary?.count ?? 0
    }
}

extension ViewControllerAllProfiles: NSTableViewDelegate, Attributedestring {

    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row > self.allprofiles!.allconfigurationsasdictionary!.count - 1 { return nil }
        let object: NSDictionary = self.allprofiles!.allconfigurationsasdictionary![row]
        return object[tableColumn!.identifier] as? String
    }
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let column = myTableViewFromNotification.selectedColumn
        self.column = column
        switch column {
        case 0:
            // Profile
            return
        case 1:
            // Task
            return
        case 2:
            // local catalog
            return
        case 3:
            // remote catalog
            return
        case 4:
            // remote server
            return
        case 5:
            // ID
            return
        case 6:
             // Days
            return
        case 7:
            // Last run
            self.allprofiles!.sortrundate()
        default:
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerAllProfiles: NSSearchFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        self.delayWithSeconds(0.25) {
            guard self.column != nil else { return }
            let filterstring = self.search.stringValue
            if filterstring.isEmpty {
                globalMainQueue.async(execute: { () -> Void in
                    self.allprofiles = AllProfiles()
                    self.mainTableView.reloadData()
                })
            } else {
                globalMainQueue.async(execute: { () -> Void in
                    self.allprofiles?.filter(search: filterstring, column: self.column!)
                    self.mainTableView.reloadData()
                })
            }
        }
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        globalMainQueue.async(execute: { () -> Void in
            self.allprofiles = AllProfiles()
            self.mainTableView.reloadData()
        })
    }
}
