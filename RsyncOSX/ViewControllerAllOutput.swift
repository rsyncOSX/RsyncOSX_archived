//
//  ViewControllerAllOutput.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerAllOutput: NSViewController, Delay {
    @IBOutlet var outputtable: NSTableView!
    weak var getoutputDelegate: ViewOutputDetails?
    var logging: Logging?

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcalloutput, nsviewcontroller: self)
        self.outputtable.delegate = self
        self.outputtable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.getoutputDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        globalMainQueue.async { () -> Void in
            self.outputtable.reloadData()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcalloutput, nsviewcontroller: nil)
    }

    @IBAction func pastetabeltomacospasteboard(_: NSButton) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        for i in 0 ..< (self.getoutputDelegate?.getalloutput().count ?? 0) {
            pasteboard.writeObjects([(self.getoutputDelegate?.getalloutput()[i])! as NSPasteboardWriting])
        }
    }

    @IBAction func readloggfile(_: NSButton) {
        self.logging = Logging()
        self.getoutputDelegate = self.logging
        globalMainQueue.async { () -> Void in
            self.outputtable.reloadData()
        }
    }

    @IBAction func reloadoutput(_: NSButton) {
        self.getoutputDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        globalMainQueue.async { () -> Void in
            self.outputtable.reloadData()
        }
    }

    @IBAction func newcleanlogfile(_: NSButton) {
        _ = Logging(nil, false)
        self.logging = Logging()
        self.getoutputDelegate = self.logging
        globalMainQueue.async { () -> Void in
            self.outputtable.reloadData()
        }
    }
}

extension ViewControllerAllOutput: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.getoutputDelegate?.getalloutput().count ?? 0
    }
}

extension ViewControllerAllOutput: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            guard row < self.getoutputDelegate?.getalloutput().count ?? 0 else { return nil }
            cell.textField?.stringValue = self.getoutputDelegate?.getalloutput()[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}

extension ViewControllerAllOutput: Reloadandrefresh {
    func reloadtabledata() {
        globalMainQueue.async { () -> Void in
            self.outputtable.reloadData()
        }
    }
}
