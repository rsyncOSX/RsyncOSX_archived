//
//  ViewControllerCopyFilesSource.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerCopyFilesSource: NSViewController {

    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var closeButton: NSButton!

    // Dismisser
    weak var dismissDelegate: DismissViewController?
    // Set index
    weak var setIndexDelegate: ViewControllerCopyFiles?
    // GetSource
    weak var getSourceDelegate: ViewControllerCopyFiles?
    weak var getSourceDelegate2: ViewControllerSsh?
    // Index
    private var index: Int?

    // ACTIONS AND BUTTONS
    @IBAction func close(_ sender: NSButton) {
        if let pvc = self.presenting as? ViewControllerCopyFiles {
            self.getSourceDelegate = pvc
            if let index = self.index {
                self.getSourceDelegate?.getSource(index: index)
            }
        } else if let pvc = self.presenting as? ViewControllerSsh {
            self.getSourceDelegate2 = pvc
            if let index = self.index {
                self.getSourceDelegate2?.getSource(index: index)
            }
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        // Dismisser is root controller
        if let pvc = self.presenting as? ViewControllerCopyFiles {
            self.dismissDelegate = pvc
        } else if let pvc = self.presenting as? ViewControllerSsh {
            self.dismissDelegate = pvc
        }
        // Double click on row to select
        self.mainTableView.doubleAction = #selector(ViewControllerCopyFilesSource.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        // Dismisser is root controller
        if let pvc = self.presenting as? ViewControllerCopyFiles {
            self.dismissDelegate = pvc
        } else if let pvc = self.presenting as? ViewControllerSsh {
            self.dismissDelegate = pvc
        }
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        if let pvc = self.presenting as? ViewControllerCopyFiles {
            self.getSourceDelegate = pvc
            if let index = self.index {
                self.getSourceDelegate?.getSource(index: index)
            }
        } else if let pvc = self.presenting as? ViewControllerSsh {
            self.getSourceDelegate2 = pvc
            if let index = self.index {
                self.getSourceDelegate2?.getSource(index: index)
            }
        }

        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            if let pvc = self.presenting as? ViewControllerCopyFiles {
                self.setIndexDelegate = pvc
                let object = SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly()![index]
                let hiddenID = object.value(forKey: "hiddenID") as? Int
                guard hiddenID != nil else {
                    return
                }
                self.index = SharingManagerConfiguration.sharedInstance.getIndex(hiddenID!)
                self.setIndexDelegate?.setIndex(index: self.index!)
            } else if let _ = self.presenting as? ViewControllerSsh {
                let object = SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly()![index]
                let hiddenID = object.value(forKey: "hiddenID") as? Int
                guard hiddenID != nil else {
                    return
                }
                self.index = hiddenID!
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
        let object: NSDictionary = SharingManagerConfiguration.sharedInstance.getConfigurationsDataSourcecountBackupOnly()![row]
        return object[tableColumn!.identifier] as? String
    }

}
