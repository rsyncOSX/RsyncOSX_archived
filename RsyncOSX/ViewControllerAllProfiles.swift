//
//  ViewControllerAllProfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 07.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerAllProfiles: NSViewController {

    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!

    private var allprofiles: AllProfiles?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
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
        if row > self.allprofiles?.allconfigurationsasdictionary?.count ?? 0 - 1 { return nil }
        let object: NSDictionary = self.allprofiles!.allconfigurationsasdictionary![row]
        return object[tableColumn!.identifier] as? String
    }
}
