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
    var logging: Logfile?
    @IBOutlet var rsyncorlog: NSSwitch!
    @IBOutlet var outputrsyncorlofile: NSTextField!

    @IBAction func rsyncorlogfile(_: NSButton) {
        if rsyncorlog.state == .on {
            outputrsyncorlofile.stringValue = "Rsync output..."
            getoutputDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        } else {
            outputrsyncorlofile.stringValue = "Logfile..."
            logging = Logfile()
            getoutputDelegate = logging
        }
        globalMainQueue.async { () -> Void in
            self.outputtable.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SharedReference.shared.setvcref(viewcontroller: .vcalloutput, nsviewcontroller: self)
        outputtable.delegate = self
        outputtable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        getoutputDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        globalMainQueue.async { () -> Void in
            self.outputtable.reloadData()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        SharedReference.shared.setvcref(viewcontroller: .vcalloutput, nsviewcontroller: nil)
    }

    @IBAction func pastetabeltomacospasteboard(_: NSButton) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        for i in 0 ..< (getoutputDelegate?.getalloutput().count ?? 0) {
            pasteboard.writeObjects([(getoutputDelegate?.getalloutput()[i])! as NSPasteboardWriting])
        }
    }

    @IBAction func newcleanlogfile(_: NSButton) {
        outputrsyncorlofile.stringValue = "Logfile..."
        rsyncorlog.state = .off
        logging = Logfile(nil, false)
        getoutputDelegate = logging
        globalMainQueue.async { () -> Void in
            self.outputtable.reloadData()
        }
    }

    @IBAction func closeview(_: NSButton) {
        view.window?.close()
    }
}

extension ViewControllerAllOutput: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return getoutputDelegate?.getalloutput().count ?? 0
    }
}

extension ViewControllerAllOutput: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            guard row < getoutputDelegate?.getalloutput().count ?? 0 else { return nil }
            cell.textField?.stringValue = getoutputDelegate?.getalloutput()[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}

extension ViewControllerAllOutput: Reloadandrefresh {
    func reloadtabledata() {
        if rsyncorlog.state == .on {
            getoutputDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
            globalMainQueue.async { () -> Void in
                self.outputtable.reloadData()
            }
        } else {
            logging = Logfile()
            getoutputDelegate = logging
            globalMainQueue.async { () -> Void in
                self.outputtable.reloadData()
            }
        }
    }
}
