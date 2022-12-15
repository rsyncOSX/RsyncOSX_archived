//
//  ViewControllerSource.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerSource: NSViewController, SetConfigurations {
    @IBOutlet var mainTableView: NSTableView!

    weak var getSourceDelegateSsh: ViewControllerSsh?
    private var index: Int?

    @IBAction func closeview(_: NSButton) {
        view.window?.close()
    }

    private func select() {
        if let pvc = SharedReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh {
            getSourceDelegateSsh = pvc
            if let index = index {
                getSourceDelegateSsh?.getSourceindex(index: index)
            }
        }
    }

    @IBAction func select(_: NSButton) {
        select()
        view.window?.close()
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.doubleAction = #selector(ViewControllerSource.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        globalMainQueue.async { () in
            self.mainTableView.reloadData()
        }
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        select()
        view.window?.close()
    }

    func uniqueserversandlogins() -> [NSDictionary]? {
        guard self.configurations != nil else { return nil }
        var configurations = configurations?.getConfigurations()?.filter {
            SharedReference.shared.synctasks.contains($0.task)
        }
        var data = [NSDictionary]()
        for i in 0 ..< (configurations?.count ?? 0) {
            if configurations?[i].offsiteServer.isEmpty == true {
                configurations?[i].offsiteServer = DictionaryStrings.localhost.rawValue
            }
            if let config = configurations?[i] {
                let row: NSDictionary = ConvertOneConfig(config: config).dict
                let server = config.offsiteServer
                let user = config.offsiteUsername
                if server != DictionaryStrings.localhost.rawValue {
                    if data.filter({ $0.value(forKey: DictionaryStrings.offsiteServerCellID.rawValue) as? String ?? "" ==
                            server && $0.value(forKey: DictionaryStrings.offsiteUsernameID.rawValue) as? String ?? "" == user }).count == 0
                    {
                        data.append(row)
                    }
                }
            }
        }
        return data
    }

    // when row is selected, setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            if let object = uniqueserversandlogins()?[index] {
                if let hiddenID = object.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int {
                    self.index = hiddenID
                }
            }
        }
    }
}

extension ViewControllerSource: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return uniqueserversandlogins()?.count ?? 0
    }
}

extension ViewControllerSource: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let object: NSDictionary = uniqueserversandlogins()?[row],
           let tableColumn = tableColumn
        {
            return object[tableColumn.identifier] as? String
        }
        return nil
    }
}
