//
//  ViewControllerBatch.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 25/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

//swiftlint:disable syntactic_sugar file_length cyclomatic_complexity line_length

import Foundation
import Cocoa

// Return the created batchobject
protocol getNewBatchTask: class {
    func getTaskObject() -> NewBatchTask
}

class ViewControllerBatch: NSViewController {

    // If close button or abort is pressed
    // After execute button is pressed, close is abort
    var close: Bool?
    // Automatic closing of view
    var waitToClose: Timer?
    var closeIn: Timer?
    var seconds: Int?
    // Working on row
    var row: Int?
    // Batchobject
    var batchTask: NewBatchTask?

    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var closeinseconds: NSTextField!
    @IBOutlet weak var rownumber: NSTextField!

    // Delegeta to Dismisser
    weak var dismissDelegate: DismissViewController?
    // Delegate to Abort operations
    weak var abortDelegate: AbortOperations?

    // ACTIONS AND BUTTONS

    @IBAction func close(_ sender: NSButton) {

        if (self.close!) {
            self.batchTask = NewBatchTask()
            self.batchTask!.closeOperation()
        } else {
            self.abortDelegate?.abortOperations()
        }
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Execute batch
    @IBAction func execute(_ sender: NSButton) {
        self.batchTask = NewBatchTask()
        self.batchTask!.executeBatch()
        self.closeButton.title = "Abort"
        self.close = false
    }

    @objc fileprivate func setSecondsView() {
        self.seconds = self.seconds! - 1
        self.closeinseconds.stringValue = "Close automatically in : " + String(self.seconds!) + " seconds"
    }

    @objc fileprivate func closeView() {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        if (SharingManagerConfiguration.sharedInstance.batchDataQueuecount() > 0 ) {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
         // Dismisser is root controller
        if let pvc = self.presenting as? ViewControllertabMain {
            self.dismissDelegate = pvc
            self.abortDelegate = pvc
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.closeinseconds.isHidden = true
        self.working.stopAnimation(nil)
        self.close = true
        self.label.stringValue = "Progress "
        self.rownumber.stringValue = ""
        self.closeButton.title = "Close"
        self.close = true
        self.batchTask = nil
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.batchTask = nil
    }

}

extension ViewControllerBatch : NSTableViewDataSource {
        // Delegate for size of table
        func numberOfRows(in tableView: NSTableView) -> Int {
            return SharingManagerConfiguration.sharedInstance.batchDataQueuecount()
        }
}

extension ViewControllerBatch : NSTableViewDelegate {

    // TableView delegates
    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard SharingManagerConfiguration.sharedInstance.getbatchDataQueue() != nil else {
            return nil
        }
        let object: NSMutableDictionary = SharingManagerConfiguration.sharedInstance.getbatchDataQueue()![row]
        if (tableColumn!.identifier.rawValue == "estimatedCellID" || tableColumn!.identifier.rawValue == "completedCellID" ) {
            return object[tableColumn!.identifier] as? Int!
        } else {
            if (row == SharingManagerConfiguration.sharedInstance.getBatchdataObject()!.getRow() && tableColumn!.identifier.rawValue == "taskCellID") {
                return (object[tableColumn!.identifier] as? String)! + " *"
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
    }
}

extension ViewControllerBatch: StartStopProgressIndicator {

    func stop() {
        let row = SharingManagerConfiguration.sharedInstance.getBatchdataObject()!.getRow() + 1
        globalMainQueue.async(execute: { () -> Void in
            self.label.stringValue = "Executing task "
            self.rownumber.stringValue = String(row)
        })

    }

    func start() {
        self.close = false
        let row = SharingManagerConfiguration.sharedInstance.getBatchdataObject()!.getRow() + 1
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

extension ViewControllerBatch: RefreshtableView {

    // Updates tableview according to progress of batch
    func refresh() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

}

extension ViewControllerBatch: getNewBatchTask {

    func getTaskObject() -> NewBatchTask {
        return self.batchTask!
    }

}
