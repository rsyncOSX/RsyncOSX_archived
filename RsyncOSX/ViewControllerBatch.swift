//
//  ViewControllerBatch.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 25/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

// Return the created batchobject
protocol getNewBatchTask: class {
    func getbatchtaskObject() -> BatchTask?
}

// Dismiss view when rsync error
protocol closeViewError: class {
    func closeerror()
}

class ViewControllerBatch: NSViewController, SetDismisser, AbortTask {

    weak var configurations: Configurations?
    var close: Bool?
    var waitToClose: Timer?
    var closeIn: Timer?
    var seconds: Int?
    var row: Int?
    var batchTask: BatchTask?

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var closeinseconds: NSTextField!
    @IBOutlet weak var rownumber: NSTextField!
    @IBOutlet weak var executeButton: NSButton!

    @IBAction func close(_ sender: NSButton) {
        if self.close! {
            self.batchTask!.closeOperation()
        } else {
            self.abort()
        }
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.batchTask = nil
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Execute batch
    @IBAction func execute(_ sender: NSButton) {
        self.batchTask!.executeBatch()
        self.closeButton.title = "Abort"
        self.executeButton.isEnabled = false
        self.close = false
    }

    @objc private func setSecondsView() {
        self.seconds = self.seconds! - 1
        self.closeinseconds.stringValue = "Close automatically in : " + String(self.seconds!) + " seconds"
    }

    @objc private func closeView() {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    private func loadtasks() {
        ViewControllerReference.shared.setvcref(viewcontroller: .vcbatch, nsviewcontroller: self)
        // Create new batctask
        self.batchTask = BatchTask()
        self.configurations = self.batchTask?.configurations
        self.configurations?.createbatchQueue()
        self.closeinseconds.isHidden = true
        self.executeButton.isEnabled = true
        self.working.stopAnimation(nil)
        self.close = true
        self.label.stringValue = "Progress "
        self.rownumber.stringValue = ""
        self.closeButton.title = "Close"
        self.close = true
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.loadtasks()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.configurations = self.batchTask?.configurations
        if self.batchTask == nil {
            self.loadtasks()
        } else {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
    }

}

extension ViewControllerBatch: NSTableViewDataSource {
        // Delegate for size of table
        func numberOfRows(in tableView: NSTableView) -> Int {
            self.configurations = self.batchTask?.configurations
            return self.configurations?.batchQueuecount() ?? 0
    }
}

extension ViewControllerBatch: NSTableViewDelegate {

    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard  self.configurations?.getupdatedbatchQueue() != nil else {
            return nil
        }
        let object: NSMutableDictionary = self.configurations!.getupdatedbatchQueue()![row]
        if tableColumn!.identifier.rawValue == "estimatedCellID" || tableColumn!.identifier.rawValue == "completedCellID" {
            return object[tableColumn!.identifier] as? Int!
        } else {
            if row == self.configurations!.getbatchQueue()!.getRow() && tableColumn!.identifier.rawValue == "taskCellID" {
                let text = (object[tableColumn!.identifier] as? String)! + "  <--"
                let attributedString = NSMutableAttributedString(string: (text))
                let range = (text as NSString).range(of: text)
                attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: NSColor.systemBlue, range: range)
                return attributedString
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
    }
}

extension ViewControllerBatch: StartStopProgressIndicator {

    func stop() {
        let row = self.configurations!.getbatchQueue()!.getRow() + 1
        globalMainQueue.async(execute: { () -> Void in
            self.label.stringValue = "Executing task "
            self.rownumber.stringValue = String(row)
        })
    }

    func start() {
        self.close = false
        let row = self.configurations!.getbatchQueue()!.getRow() + 1
        // Starts estimation progressbar when estimation starts
        globalMainQueue.async(execute: { () -> Void in
            self.working.startAnimation(nil)
            self.label.stringValue = "Estimating task "
            self.rownumber.stringValue = String(row)
        })
    }

    func complete() {
        // Batch task completed
        globalMainQueue.async(execute: { () -> Void in
            self.working.stopAnimation(nil)
            self.label.stringValue = "Completed all task(s)"
            self.closeButton.title = "Close"
            self.close = true
        })
        self.closeinseconds.isHidden = false
        self.seconds = 10
        self.waitToClose = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(closeView), userInfo: nil, repeats: false)
        self.closeIn = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setSecondsView), userInfo: nil, repeats: true)
    }
}

extension ViewControllerBatch: Reloadandrefresh {

    // Updates tableview according to progress of batch
    func reloadtabledata() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerBatch: getNewBatchTask {

    func getbatchtaskObject() -> BatchTask? {
        return self.batchTask
    }

}

extension ViewControllerBatch: closeViewError {
    func closeerror() {
        self.batchTask = nil
        self.abort()
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }
}
