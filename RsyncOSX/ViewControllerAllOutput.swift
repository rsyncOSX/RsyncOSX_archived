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

class ViewControllerAllOutput: NSViewController, Delay {

    @IBOutlet weak var outputtable: NSTableView!
    weak var getoutputDelegate: ViewOutputDetails?

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcalloutput, nsviewcontroller: self)
        self.getoutputDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.outputtable.delegate = self
        self.outputtable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.getoutputDelegate?.enableappend()
        globalMainQueue.async(execute: { () -> Void in
            self.outputtable.reloadData()
        })
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.getoutputDelegate?.disableappend()
    }

}

extension ViewControllerAllOutput: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.getoutputDelegate?.getalloutput().count ?? 0
    }
}

extension ViewControllerAllOutput: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = self.getoutputDelegate?.getalloutput()[row] ?? ""
            return cell
        } else {
             return nil
        }
    }
}

extension ViewControllerAllOutput: Reloadandrefresh {
    func reloadtabledata() {
        globalMainQueue.async(execute: { () -> Void in
            self.outputtable.reloadData()
        })
    }
}
