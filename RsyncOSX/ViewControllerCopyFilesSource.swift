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
    @IBOutlet weak var closeButton: NSButton!

    weak var setIndexDelegate: ViewControllerCopyFiles?
    weak var getSourceDelegate: ViewControllerCopyFiles?
    weak var getSourceDelegate2: ViewControllerSsh?
    private var index: Int?

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
        if (self.presenting as? ViewControllerCopyFiles) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        } else if (self.presenting as? ViewControllerSsh) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcssh)
        }
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.mainTableView.doubleAction = #selector(ViewControllerCopyFilesSource.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.index = nil
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
        if (self.presenting as? ViewControllerCopyFiles) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        } else if (self.presenting as? ViewControllerSsh) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcssh)
        }
    }

    // when row is selected, setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            if let pvc = self.presenting as? ViewControllerCopyFiles {
                self.setIndexDelegate = pvc
                let object = self.configurations!.getConfigurationsDataSourcecountBackupOnlyRemote()![index]
                let hiddenID = object.value(forKey: "hiddenID") as? Int
                guard hiddenID != nil else { return }
                self.index = self.configurations!.getIndex(hiddenID!)
                self.setIndexDelegate?.setIndex(index: self.index!)
            } else if self.presenting as? ViewControllerSsh != nil {
                let object = self.configurations!.getConfigurationsDataSourcecountBackupOnlyRemote()![index]
                let hiddenID = object.value(forKey: "hiddenID") as? Int
                guard hiddenID != nil else { return }
                self.index = hiddenID!
            }
        }
    }

}

extension ViewControllerCopyFilesSource: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard self.configurations != nil else {
            return 0
        }
        return self.configurations!.getConfigurationsDataSourcecountBackupOnlyRemote()?.count ?? 0
    }
}

extension ViewControllerCopyFilesSource: NSTableViewDelegate {

    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let object: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackupOnlyRemote()![row]
        return object[tableColumn!.identifier] as? String
    }

}
