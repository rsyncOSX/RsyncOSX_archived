//
//  ViewControllerSource.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerSource: NSViewController, SetConfigurations {
    @IBOutlet var mainTableView: NSTableView!
    @IBOutlet var selectButton: NSButton!

    weak var getSourceDelegateSsh: ViewControllerSsh?
    private var index: Int?

    @IBAction func closeview(_: NSButton) {
        self.view.window?.close()
    }

    private func select() {
        if let pvc = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh {
            self.getSourceDelegateSsh = pvc
            if let index = self.index {
                self.getSourceDelegateSsh?.getSourceindex(index: index)
            }
        }
    }

    @IBAction func select(_: NSButton) {
        self.select()
        self.view.window?.close()
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.mainTableView.doubleAction = #selector(ViewControllerSource.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        self.selectButton.isEnabled = false
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        self.select()
        self.view.window?.close()
    }

    // when row is selected, setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        self.selectButton.isEnabled = true
        if let index = indexes.first {
            if let object = self.configurations?.uniqueserversandlogins()?[index] {
                if let hiddenID = object.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int {
                    self.index = hiddenID
                }
            }
        }
    }
}

extension ViewControllerSource: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.configurations?.uniqueserversandlogins()?.count ?? 0
    }
}

extension ViewControllerSource: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let object: NSDictionary = self.configurations!.uniqueserversandlogins()![row]
        return object[tableColumn!.identifier] as? String
    }
}
