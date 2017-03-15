//
//  ViewControllerBatch.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 25/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

protocol StartBatch : class  {
    // Starts batch run
    func runBatch()
    // Aborts executing batch
    func abortOperations()
    // Either just close or close after batch done
    func closeOperation()
}


class ViewControllerBatch : NSViewController {
    
    // If close button or abort is pressed
    // After execute button is pressed, close is abort
    var close:Bool?
    // Autmatic closing of view
    var waitToClose:Timer?
    var closeIn:Timer?
    var seconds:Int?

    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var CloseButton: NSButton!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var closeinseconds: NSTextField!
    
    // Iniate start of batchrun
    weak var startBatch_delegate:StartBatch?
    // Dismisser
    weak var dismiss_delegate:DismissViewController?

    // ACTIONS AND BUTTONS
    
    @IBAction func Close(_ sender: NSButton) {
        if (self.close!) {
            self.startBatch_delegate?.closeOperation()
        } else {
            self.startBatch_delegate?.abortOperations()
        }
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    // Execute batch
    @IBAction func Execute(_ sender: NSButton) {
        self.startBatch_delegate!.runBatch()
        self.CloseButton.title = "Abort"
        self.close = false
    }
    
    @objc fileprivate func setSecondsView() {
        self.seconds = self.seconds! - 1
        self.closeinseconds.stringValue = "Close automatically in : " + String(self.seconds!) + " seconds"
    }
    
    @objc fileprivate func closeView() {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }

    
    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        if (SharingManagerConfiguration.sharedInstance.batchDataQueuecount() > 0 ) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
         // Dismisser is root controller
        if let pvc = self.presenting as? ViewControllertabMain {
            self.startBatch_delegate = pvc
            self.dismiss_delegate = pvc
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.closeinseconds.isHidden = true
        self.label.isHidden = true
        self.working.stopAnimation(nil)
        self.close = true
        
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
            let object : NSMutableDictionary = SharingManagerConfiguration.sharedInstance.getbatchDataQueue()![row]
            if ((tableColumn!.identifier) == "estimatedCellID" || (tableColumn!.identifier) == "completedCellID" ) {
                return object[tableColumn!.identifier] as? Int!
            } else {
                return object[tableColumn!.identifier] as? String
            }
    }
    
    // Toggling batch
    @objc(tableView:setObjectValue:forTableColumn:row:) func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if (SharingManagerConfiguration.sharedInstance.getConfigurations()[row].task == "backup") {
            SharingManagerConfiguration.sharedInstance.getConfigurationsDataSource()![row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
            SharingManagerConfiguration.sharedInstance.setBatchYesNo(row)
        }
    }
    
}

extension ViewControllerBatch: StartStopProgressIndicator {
    
    // Stops estimation progressbar when real task is executing
    func stop() {
        GlobalMainQueue.async(execute: { () -> Void in
            self.working.stopAnimation(nil)
            self.label.stringValue = "Executing"
        })
        
    }
    
    func start() {
        self.close = false
        // Starts estimation progressbar when estimation starts
        GlobalMainQueue.async(execute: { () -> Void in
            self.working.startAnimation(nil)
            self.label.isHidden = false
            self.label.stringValue = "Estimating"
        })
        
    }
    
    func complete() {
        // Batch task completed
        GlobalMainQueue.async(execute: { () -> Void in
            self.label.stringValue = "Completed"
            self.CloseButton.title = "Close"
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
        GlobalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
    
}
