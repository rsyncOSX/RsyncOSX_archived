//
//  ViewControllerAllOutput.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerAllOutput: NSViewController {

    @IBOutlet weak var detailsTable: NSTableView!
    var output: [String]?

    weak var getoutputDelegate: StoreAllOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getoutputDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.detailsTable.delegate = self
        self.detailsTable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.output = self.getoutputDelegate?.getalloutput()
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }

}

extension ViewControllerAllOutput: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.output?.count ?? 0
    }
}

extension ViewControllerAllOutput: NSTableViewDelegate {
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
