//
//  newBatchTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

protocol BatchTask: class {
    func presentViewBatch()
    func progressIndicatorViewBatch(operation: batchViewProgressIndicator)
}

enum batchViewProgressIndicator {
    case start
    case stop
    case complete
    case refresh
}

final class newBatchTask {
    
    // Protocol function used in Process().
    weak var processupdate_delegate:UpdateProgress?
    // Delegate function for doing a refresh of NSTableView in ViewControllerBatch
    weak var refresh_delegate:RefreshtableView?
    // Delegate for presenting batchView
    weak var batchView_delegate:BatchTask?
    
    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicator_delegate:StartStopProgressIndicatorSingleTask?
    // Delegate function for show process step and present View
    weak var task_delegate:SingleTask?
    
    // REFERENCE VARIABLES
    
    // Reference to Process task
    private var process:Process?
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
    private var workload:singleTaskWorkQueu?
    
    // Schedules in progress
    private var scheduledJobInProgress:Bool = false
    
    // Some max numbers
    private var transferredNumber:String?
    private var transferredNumberSizebytes:String?
    
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
            let batchObject = batchTask(batchtasks: configs)
            // Set the reference to batchData object in SharingManagerConfiguration
            SharingManagerConfiguration.sharedInstance.setbatchDataQueue(batchdata: batchObject)
            // Present batchView
            self.batchView_delegate?.presentViewBatch()
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
    
    // Functions are called from batchView.
    func runBatch() {
        // No scheduled opertaion in progress
        if (self.scheduledOperationInProgress() == false ) {
            if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
                // Just copy the work object.
                // The work object will be removed in Process termination
                let work = batchobject.nextBatchCopy()
                // Get the index if given hiddenID (in work.0)
                let index:Int = SharingManagerConfiguration.sharedInstance.getIndex(work.0)
                
                switch (work.1) {
                case 0:
                    // Create the output object for rsync
                    self.output = nil
                    self.output = outputProcess()
                    
                    self.batchView_delegate?.progressIndicatorViewBatch(operation: .start)
                    let arguments:Array<String> = SharingManagerConfiguration.sharedInstance.getRsyncArgumentOneConfig(index: index, argtype: .argdryRun)
                    let process = Rsync(arguments: arguments)
                    // Setting reference to process for Abort if requiered
                    process.executeProcess(output: self.output!)
                    self.process = process.getProcess()
                case 1:
                    
                    // Getting and setting max file to transfer
                    self.task_delegate?.setmaxNumbersOfFilesToTransfer(output: self.output)
                    // Create the output object for rsync
                    self.output = nil
                    self.output = outputProcess()
                    
                    let arguments:Array<String> = SharingManagerConfiguration.sharedInstance.getRsyncArgumentOneConfig(index: index, argtype: .arg)
                    let process = Rsync(arguments: arguments)
                    // Setting reference to process for Abort if requiered
                    process.executeProcess(output: self.output!)
                    self.process = process.getProcess()
                case -1:
                    self.batchView_delegate?.progressIndicatorViewBatch(operation: .complete)
                default : break
                }
            }
        } else {
            Alerts.showInfo("Scheduled operation in progress")
        }
    }
    
    func closeOperation() {
        self.process = nil
        self.workload = nil
        self.task_delegate?.setInfo(info: "", color: .black)
    }
    
    func inBatchwork() {
        // Take care of batchRun activities
        if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
            
            if (self.outputbatch == nil) {
                self.outputbatch = outputBatch()
            }
            
            // Remove the first worker object
            let work = batchobject.nextBatchRemove()
            // get numbers from dry-run
            
            // 0 is estimationrun, 1 is real run
            switch (work.1) {
            case 0:
                // dry-run
                // Setting maxcount of files in object
                batchobject.setEstimated(numberOfFiles: self.maxcount)
                // Do a refresh of NSTableView in ViewControllerBatch
                // Stack of ViewControllers
                
                self.batchView_delegate?.progressIndicatorViewBatch(operation: .stop)
                self.task_delegate?.showProcessInfo(info: .Estimating)
                self.runBatch()
            case 1:
                // Real run
                self.maxcount = self.output!.getMaxcount()
                let number = Numbers(output: self.output!.getOutput())
                number.setNumbers()
                
                // Update files in work
                batchobject.updateInProcess(numberOfFiles: self.maxcount)
                batchobject.setCompleted()
                self.batchView_delegate?.progressIndicatorViewBatch(operation: .refresh)
                // Set date on Configuration
                let index = SharingManagerConfiguration.sharedInstance.getIndex(work.0)
                let config = SharingManagerConfiguration.sharedInstance.getConfigurations()[index]
                // Get transferred numbers from view
                self.transferredNumber = self.task_delegate?.gettransferredNumber()
                self.transferredNumberSizebytes = self.task_delegate?.gettransferredNumberSizebytes()
                
                if config.offsiteServer.isEmpty {
                    let result = config.localCatalog + " , " + "localhost" + " , " + number.statistics(numberOfFiles: self.transferredNumber, sizeOfFiles: self.transferredNumberSizebytes)[0]
                    self.outputbatch!.addLine(str: result)
                } else {
                    let result = config.localCatalog + " , " + config.offsiteServer + " , " + number.statistics(numberOfFiles: self.transferredNumber,sizeOfFiles: self.transferredNumberSizebytes)[0]
                    self.outputbatch!.addLine(str: result)
                }
                
                let hiddenID = SharingManagerConfiguration.sharedInstance.gethiddenID(index: index)
                SharingManagerConfiguration.sharedInstance.setCurrentDateonConfiguration(index)
                SharingManagerSchedule.sharedInstance.addScheduleResultManuel(hiddenID, result: number.statistics(numberOfFiles: self.transferredNumber,sizeOfFiles: self.transferredNumberSizebytes)[0])
                self.task_delegate?.showProcessInfo(info: .Executing)
                
                self.runBatch()
            default :
                break
            }
        }
    }
    
    
    init() {
        
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain as? ViewControllertabMain {
            self.indicator_delegate = pvc
            self.task_delegate = pvc
            self.batchView_delegate = pvc
        }
    }
    
}
