//
//  ViewControllerInformation.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar line_length

import Foundation
import Cocoa

class ViewControllerInformation: NSViewController, SetDismisser, GetInformation {

    @IBOutlet weak var detailsTable: NSTableView!

    var output: Array<String>?

    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTable.delegate = self
        detailsTable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.output = self.getinfo(viewcontroller: .vctabmain)
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

}

extension ViewControllerInformation: NSTableViewDataSource {

    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.output?.count ?? 0
    }

}

extension ViewControllerInformation: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if tableColumn == tableView.tableColumns[0] {
            text = self.output![row]
            cellIdentifier = "outputID"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
