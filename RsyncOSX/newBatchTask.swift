//
//  newBatchTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class newBatchTask {
    
    // Protocol function used in Process().
    weak var processupdate_delegate:UpdateProgress?
    // Delegate function for doing a refresh of NSTableView in ViewControllerBatch
    weak var refresh_delegate:RefreshtableView?
    
    
    
    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicator_delegate:StartStopProgressIndicatorSingleTask?
    // Delegate function for show process step and present View
    weak var task_delegate:Task?
    
    // REFERENCE VARIABLES
    
    // Reference to config
    private var config:configuration?
    // dryrun or not
    private var dryrun:Bool?
    // Reference to Process task
    private var process:Process?
    // Index to selected row, index is set when row is selected
    private var index:Int?
    // Getting output from rsync
    var output:outputProcess?
    // Getting output from batchrun
    private var outputbatch:outputBatch?
    // Holding max count
    private var maxcount:Int = 0
    // HiddenID task, set when row is selected
    private var hiddenID:Int?
    // Reference to Schedules object
    private var schedules : ScheduleSortedAndExpand?
    // Single task work queu
    private var workload:singleTask?
    
    // Schedules in progress
    fileprivate var scheduledJobInProgress:Bool = false
    // Ready for execute again
    fileprivate var ready:Bool = true
    // Can load profiles
    // Load profiles only when testing for connections are done.
    // Application crash if not
    fileprivate var loadProfileMenu:Bool = false
    
    // Numbers
    
    var transferredNumber:String?
    var transferredNumberSizebytes:String?
    var totalNumber:String?
    var totalNumberSizebytes:String?
    var totalDirs:String?
    var newfiles:String?
    var deletefiles:String?
    
    func ProcessTermination() {
        
    }
    
    
    // Execute BATCH TASKS only
    // Start of BATCH tasks.
    // After start the function ProcessTermination()
    // which is triggered when a Process termination is
    // discovered, takes care of next task according to
    // status and next work in batchOperations which
    // also includes a queu of work.
    func executeBatch() {
        
        if (self.scheduledOperationInProgress() == false && SharingManagerConfiguration.sharedInstance.noRysync == false){
            self.workload = nil
            self.outputbatch = nil
            // NB: self.setInfo(info: "Batchrun", color: .blue)
            // Get all Configs marked for batch
            let configs = SharingManagerConfiguration.sharedInstance.getConfigurationsBatch()
            let batchObject = batchOperations(batchtasks: configs)
            // Set the reference to batchData object in SharingManagerConfiguration
            SharingManagerConfiguration.sharedInstance.setbatchDataQueue(batchdata: batchObject)
            GlobalMainQueue.async(execute: { () -> Void in
                // NB: self.presentViewControllerAsSheet(self.ViewControllerBatch)
            })
        } else {
            Utils.sharedInstance.noRsync()
        }
    }
    
    // True if scheduled task in progress
    func scheduledOperationInProgress() -> Bool {
        var scheduleInProgress:Bool?
        if (self.schedules != nil) {
            scheduleInProgress = self.schedules!.getScheduledOperationInProgress()
        } else {
            scheduleInProgress = false
        }
        if (scheduleInProgress == false && self.scheduledJobInProgress == false){
            return false
        } else {
            return true
        }
    }
    
    // Function for setting max files to be transferred
    // Function is called in self.ProcessTermination()
    func setmaxNumbersOfFilesToTransfer() {
        
        let number = Numbers(output: self.output!.getOutput())
        number.setNumbers()
        
        // Getting max count
        // self.showProcessInfo(info: .Set_max_Number)
        if (number.getTransferredNumbers(numbers: .totalNumber) > 0) {
            self.setNumbers(setvalues: true)
            if (number.getTransferredNumbers(numbers: .transferredNumber) > 0) {
                self.maxcount = number.getTransferredNumbers(numbers: .transferredNumber)
            } else {
                self.maxcount = self.output!.getMaxcount()
            }
        } else {
            self.maxcount = self.output!.getMaxcount()
        }
    }
    
    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    func setNumbers(setvalues: Bool) {
        if (setvalues) {
            
            let number = Numbers(output: self.output!.getOutput())
            number.setNumbers()
            
            self.transferredNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumber)), number: NumberFormatter.Style.decimal)
            self.transferredNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumberSizebytes)), number: NumberFormatter.Style.decimal)
            self.totalNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumber)), number: NumberFormatter.Style.decimal)
            self.totalNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumberSizebytes)), number: NumberFormatter.Style.decimal)
            self.totalDirs = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalDirs)), number: NumberFormatter.Style.decimal)
            self.newfiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .new)), number: NumberFormatter.Style.decimal)
            self.deletefiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .delete)), number: NumberFormatter.Style.decimal)
        } else {
            self.transferredNumber = ""
            self.transferredNumberSizebytes = ""
            self.totalNumber = ""
            self.totalNumberSizebytes = ""
            self.totalDirs = ""
            self.newfiles = ""
            self.deletefiles = ""
        }
    }
    
    
    // Reset workqueue
    fileprivate func reset() {
        self.workload = nil
        self.process = nil
        self.output = nil
        // NB: self.setRsyncCommandDisplay()
    }
    
    
    init() {
        
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain as? ViewControllertabMain {
            self.indicator_delegate = pvc
            self.task_delegate = pvc
        }
        
        
        
        
    }
    
}
