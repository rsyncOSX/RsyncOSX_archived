//
//  ViewControllerQuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerQuickBackup: NSViewController, SetDismisser, AbortTask {

    var waitToClose: Timer?
    var closeIn: Timer?
    var seconds: Int?
    var row: Int?
    var quickbackluplist: QuickBackup?

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var closeinseconds: NSTextField!
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet weak var abortbutton: NSButton!

    // Either abort or close
    @IBAction func abort(_ sender: NSButton) {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Execute batch
    @IBAction func execute(_ sender: NSButton) {
        self.executeButton.isEnabled = false
    }

    @objc private func setSecondsView() {
        self.seconds = self.seconds! - 1
        self.closeinseconds.stringValue = "Close automatically in: " + String(self.seconds!) + " seconds"
    }

    @objc private func closeView() {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    private func loadtasks() {
        self.quickbackluplist = QuickBackup()
        self.closeinseconds.isHidden = true
        self.executeButton.isEnabled = true
        self.working.stopAnimation(nil)
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcquickbatch, nsviewcontroller: self)
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.loadtasks()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.executeButton.isEnabled = true
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let column = myTableViewFromNotification.selectedColumn
        if column == 3 {
            self.quickbackluplist?.sortbystrings(sort: .localCatalog)
        } else if column == 4 {
            self.quickbackluplist?.sortbystrings(sort: .offsiteCatalog)
        } else if column == 5 {
            self.quickbackluplist?.sortbystrings(sort: .offsiteServer)
        } else if column == 6 {
            self.quickbackluplist?.sortbydays()
        }
        self.reloadtabledata()
    }

}

extension ViewControllerQuickBackup: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.quickbackluplist?.sortedlist?.count ?? 0
    }
}

extension ViewControllerQuickBackup: NSTableViewDelegate, Attributtedestring {
    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard  self.quickbackluplist?.sortedlist != nil else { return nil }
        let object: NSDictionary = (self.quickbackluplist?.sortedlist![row])!
        if tableColumn!.identifier.rawValue == "daysID" {
            if object.value(forKey: "markdays") as? Bool == true {
                let celltext = object[tableColumn!.identifier] as? String
                return self.attributtedstring(str: celltext!, color: NSColor.red, align: .right)
            }
        }
        if tableColumn!.identifier.rawValue == "selectCellID" {
            return object[tableColumn!.identifier] as? Int
        }
        return object[tableColumn!.identifier] as? String
    }

    // Toggling selection
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard  self.quickbackluplist?.sortedlist != nil else { return }
        if tableColumn!.identifier.rawValue == "selectCellID" {
            var select: Int = (self.quickbackluplist?.sortedlist![row].value(forKey: "selectCellID") as? Int)!
            if select == 0 { select = 1 } else if select == 1 { select = 0 }
            self.quickbackluplist?.sortedlist![row].setValue(select, forKey: "selectCellID")
        }
    }
}

extension ViewControllerQuickBackup: Reloadandrefresh {

    // Updates tableview according to progress of batch
    func reloadtabledata() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerQuickBackup: CloseViewError {
    func closeerror() {
        self.abort()
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }
}
