//
//  ViewControllerInformationCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 14/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa

class ViewControllerInformationCopyFiles: NSViewController, SetDismisser, OutPut {

    @IBOutlet weak var detailsTable: NSTableView!
    var output: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailsTable.delegate = self
        self.detailsTable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.output = self.getinfo(viewcontroller: .vccopyfiles)
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
    }
}

extension ViewControllerInformationCopyFiles: NSTableViewDataSource {

    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.output?.count ?? 0
    }
}

extension ViewControllerInformationCopyFiles: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue =  self.output?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}
