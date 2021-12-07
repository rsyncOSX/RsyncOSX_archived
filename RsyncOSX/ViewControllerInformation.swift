//
//  ViewControllerInformation.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerInformation: NSViewController, SetDismisser, OutPut {
    @IBOutlet var detailsTable: NSTableView!

    var output: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTable.delegate = self
        detailsTable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        output = getinfo()
        globalMainQueue.async { () in
            self.detailsTable.reloadData()
        }
    }

    @IBAction func close(_: NSButton) {
        dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func pastetabeltomacospasteboard(_: NSButton) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        for i in 0 ..< (output?.count ?? 0) {
            pasteboard.writeObjects([output?[i] as! NSPasteboardWriting])
        }
    }
}

extension ViewControllerInformation: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return output?.count ?? 0
    }
}

extension ViewControllerInformation: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = output?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}
