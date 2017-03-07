//
//  ViewControllerCopyFilesSource.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa


class ViewControllerCopyFilesSource : NSViewController {
    
    
    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var CloseButton: NSButton!
    
    // Dismisser
    weak var dismiss_delegate:DismissViewController?
    // Set index
    weak var setIndex_delegate:ViewControllerCopyFiles?
    // GetSource
    weak var getSource_delegate:ViewControllerCopyFiles?
    // Index
    private var index:Int?
    
    // ACTIONS AND BUTTONS
    @IBAction func Close(_ sender: NSButton) {
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        GlobalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        // Dismisser is root controller
        if let pvc = self.presenting as? ViewControllerCopyFiles {
            self.dismiss_delegate = pvc
        }
        // Double click on row to select
        self.mainTableView.doubleAction = #selector(ViewControllerCopyFilesSource.tableViewDoubleClick(sender:))
    }
    
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender:AnyObject) {
        if let pvc = self.presenting as? ViewControllerCopyFiles {
            self.getSource_delegate = pvc
            self.getSource_delegate?.GetSource(Index: self.index!)
        }
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = notification.object as! NSTableView
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            if let pvc = self.presenting as? ViewControllerCopyFiles {
                self.setIndex_delegate = pvc
                let object = SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly()![index]
                let hiddenID = object.value(forKey: "hiddenID") as? Int
                guard hiddenID != nil else {
                    return
                }
                self.index = SharingManagerConfiguration.sharedInstance.getIndex(hiddenID!)
                self.setIndex_delegate?.SetIndex(Index: self.index!)
            }
        }
    }
    
}

extension ViewControllerCopyFilesSource: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly() != nil else {
            return 0
        }
        return SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly()!.count
    }
}

extension ViewControllerCopyFilesSource: NSTableViewDelegate {
    
    // TableView delegates
    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly() != nil else {
            return nil
        }
        let object : NSDictionary = SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly()![row]
        return object[tableColumn!.identifier] as? String
    }
    
}

