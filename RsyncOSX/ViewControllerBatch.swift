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
protocol GetNewBatchTask: class {
    func getbatchtaskObject() -> BatchTask?
}

// Dismiss view when rsync error
protocol CloseViewError: class {
    func closeerror()
}

protocol Attributedestring: class {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString
}

extension Attributedestring {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: str)
        let range = (str as NSString).range(of: str)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        attributedString.setAlignment(align, range: range)
        return attributedString
    }
}

class ViewControllerBatch: NSViewController, SetDismisser, AbortTask {

    var waitToClose: Timer?
    var closeIn: Timer?
    var seconds: Int?
    var row: Int?
    var batchTask: BatchTask?
    var batchisrunning: Bool?

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var closeinseconds: NSTextField!
    @IBOutlet weak var rownumber: NSTextField!
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet weak var abortbutton: NSButton!

    // Either abort or close
    @IBAction func abort(_ sender: NSButton) {
        if self.batchisrunning! == true {
            self.abort()
            self.batchTask!.closeOperation()
        }
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.batchTask = nil
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Execute batch
    @IBAction func execute(_ sender: NSButton) {
        self.batchisrunning = true
        self.batchTask!.executeBatch()
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
        // Create new batctask
        self.batchTask = BatchTask()
        self.batchisrunning = false
        self.batchTask?.configurations?.createbatchQueue()
        self.closeinseconds.isHidden = true
        self.executeButton.isEnabled = true
        self.working.stopAnimation(nil)
        self.label.stringValue = "Progress "
        self.rownumber.stringValue = ""
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcbatch, nsviewcontroller: self)
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

}

extension ViewControllerBatch: NSTableViewDataSource {
        // Delegate for size of table
        func numberOfRows(in tableView: NSTableView) -> Int {
            return self.batchTask?.configurations?.batchQueuecount() ?? 0
    }
}

extension ViewControllerBatch: NSTableViewDelegate, Attributedestring {
    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard  self.batchTask?.configurations?.getupdatedbatchQueue() != nil else {
             return nil
        }
        let object: NSMutableDictionary = (self.batchTask?.configurations!.getupdatedbatchQueue()![row])!
        if tableColumn!.identifier.rawValue == "estimatedCellID" || tableColumn!.identifier.rawValue == "completedCellID" {
            return object[tableColumn!.identifier] as? Int!
        } else {
            if row == self.batchTask?.configurations!.getbatchQueue()!.getRow() && tableColumn!.identifier.rawValue == "taskCellID" {
                let text = (object[tableColumn!.identifier] as? String)!
                return self.attributedstring(str: text, color: NSColor.red, align: .center)
            } else if tableColumn!.identifier.rawValue == "completeCellID" {
                if row < self.batchTask!.configurations!.getbatchQueue()!.getRow() {
                    return #imageLiteral(resourceName: "complete")
                } else {
                    return nil
                }
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
    }
}

extension ViewControllerBatch: StartStopProgressIndicator {

    func stop() {
        let row = (self.batchTask?.configurations!.getbatchQueue()!.getRow())! + 1
        globalMainQueue.async(execute: { () -> Void in
            self.label.stringValue = "Executing task "
            self.rownumber.stringValue = String(row)
        })
    }

    func start() {
        let row = (self.batchTask?.configurations!.getbatchQueue()!.getRow())! + 1
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
        })
        self.batchisrunning = false
        self.closeinseconds.isHidden = false
        self.seconds = 5
        self.waitToClose = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(closeView), userInfo: nil, repeats: false)
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

extension ViewControllerBatch: GetNewBatchTask {

    func getbatchtaskObject() -> BatchTask? {
        return self.batchTask
    }
}

extension ViewControllerBatch: CloseViewError {
    func closeerror() {
        self.batchTask = nil
        self.abort()
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }
}
