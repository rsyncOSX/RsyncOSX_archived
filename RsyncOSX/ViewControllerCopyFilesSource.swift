//
//  ViewControllerCopyFilesSource.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerCopyFilesSource: NSViewController, SetConfigurations, SetDismisser {

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var selectButton: NSButton!

    weak var getSourceDelegateSsh: ViewControllerSsh?
    weak var getSourceDelegateSnapshots: ViewControllerSnapshots?
    private var index: Int?

    private func dismissview() {
        if (self.presenting as? ViewControllerCopyFiles) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        } else if (self.presenting as? ViewControllerSsh) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcssh)
        } else if (self.presenting as? ViewControllerSnapshots) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        }
    }

    private func select() {
        if let pvc = self.presenting as? ViewControllerSsh {
            self.getSourceDelegateSsh = pvc
            if let index = self.index {
                self.getSourceDelegateSsh?.getSourceindex(index: index)
            }
        } else if let pvc = self.presenting as? ViewControllerSnapshots {
            self.getSourceDelegateSnapshots = pvc
            if let index = self.index {
                self.getSourceDelegateSnapshots?.getSourceindex(index: index)
            }
        }
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissview()
    }

    @IBAction func select(_ sender: NSButton) {
        self.select()
        self.dismissview()
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.mainTableView.doubleAction = #selector(ViewControllerCopyFilesSource.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        self.selectButton.isEnabled = false
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        self.select()
        self.dismissview()
    }

    // when row is selected, setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        self.selectButton.isEnabled = true
        if let index = indexes.first {
            if self.presenting as? ViewControllerSsh != nil {
                let object = self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()![index]
                let hiddenID = object.value(forKey: "hiddenID") as? Int
                guard hiddenID != nil else { return }
                self.index = hiddenID!
            } else if self.presenting as? ViewControllerSnapshots != nil {
                let object = self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()![index]
                let hiddenID = object.value(forKey: "hiddenID") as? Int
                guard hiddenID != nil else { return }
                self.index = hiddenID!
            }
        }
    }
}

extension ViewControllerCopyFilesSource: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard self.configurations != nil else { return 0 }
        if self.presenting as? ViewControllerEncrypt != nil {
            return self.configurations!.getConfigurationsDataSourcecountBackupCombined()?.count ?? 0
        } else {
             return self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()?.count ?? 0
        }
    }
}

extension ViewControllerCopyFilesSource: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if self.presenting as? ViewControllerEncrypt != nil {
            let object: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackupCombined()![row]
            return object[tableColumn!.identifier] as? String
        } else {
            let object: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()![row]
            return object[tableColumn!.identifier] as? String
        }
    }
}
