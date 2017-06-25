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
    func setOutputBatch(outputbatch:outputBatch?)
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
    var process:Process?
    // Getting output from rsync
    var output:outputProcess?
    // Getting output from batchrun
    private var outputbatch:outputBatch?
    // HiddenID task, set when row is selected
    private var hiddenID:Int?
    // Single task work queu
    private var workload:singleTaskWorkQueu?
    
    // Schedules in progress
    private var scheduledJobInProgress:Bool = false
    
    // Some max numbers
    private var transferredNumber:String?
    private var transferredNumberSizebytes:String?
    
    // Present BATCH TASKS only
    // Start of BATCH tasks.
    // After start the function ProcessTermination()
    // which is triggered when a Process termination is
    // discovered, takes care of next task according to
    // status and next work in batchOperations which
    // also includes a queu of work.
    func presentBatchView() {
        self.workload = nil
        self.outputbatch = nil
        // NB: self.setInfo(info: "Batchrun", color: .blue)
        // Get all Configs marked for batch
        let configs = SharingManagerConfiguration.sharedInstance.getConfigurationsBatch()
        let batchObject = batchTaskWorkQueu(batchtasks: configs)
        // Set the reference to batchData object in SharingManagerConfiguration
        SharingManagerConfiguration.sharedInstance.setbatchDataQueue(batchdata: batchObject)
        // Present batchView
        self.batchView_delegate?.presentViewBatch()
    }
    
    // Functions are called from batchView.
    func executeBatch() {
        
        if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
            // Just copy the work object.
            // The work object will be removed in Process termination
            let work = batchobject.nextBatchCopy()
            // Get the index if given hiddenID (in work.0)
            let index:Int = SharingManagerConfiguration.sharedInstance.getIndex(work.0)
                
            // Create the output object for rsync
            self.output = nil
            self.output = outputProcess()
                
            switch (work.1) {
            case 0:
                self.batchView_delegate?.progressIndicatorViewBatch(operation: .start)
                let arguments:Array<String> = SharingManagerConfiguration.sharedInstance.getRsyncArgumentOneConfig(index: index, argtype: .argdryRun)
                let process = Rsync(arguments: arguments)
                // Setting reference to process for Abort if requiered
                process.executeProcess(output: self.output!)
                self.process = process.getProcess()
            case 1:
                let arguments:Array<String> = SharingManagerConfiguration.sharedInstance.getRsyncArgumentOneConfig(index: index, argtype: .arg)
                let process = Rsync(arguments: arguments)
                // Setting reference to process for Abort if requiered
                process.executeProcess(output: self.output!)
                self.process = process.getProcess()
            case -1:
                self.batchView_delegate?.setOutputBatch(outputbatch: self.outputbatch)
                self.batchView_delegate?.progressIndicatorViewBatch(operation: .complete)
            default : break
            }
        }
    }
    
    func closeOperation() {
        self.process = nil
        self.workload = nil
        self.task_delegate?.setInfo(info: "", color: .black)
    }
    
    // Called when ProcessTermination is called in main View.
    // Either dryn-run or realrun completed.
    func ProcessTermination() {

        if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
            
            if (self.outputbatch == nil) {
                self.outputbatch = outputBatch()
            }
            
            // Remove the first worker object
            let work = batchobject.nextBatchRemove()
            // (work.0) is estimationrun, (work.1) is real run
            switch (work.1) {
            case 0:
                // dry-run
                // Setting maxcount of files in object
                batchobject.setEstimated(numberOfFiles: self.output!.getMaxcount())
                // Do a refresh of NSTableView in ViewControllerBatch
                // Stack of ViewControllers
                self.batchView_delegate?.progressIndicatorViewBatch(operation: .stop)
                self.executeBatch()
                
            case 1:
                // Real run
                let number = Numbers(output: self.output!.getOutput())
                number.setNumbers()
                
                // Update files in work
                batchobject.updateInProcess(numberOfFiles: self.output!.getMaxcount())
                batchobject.setCompleted()
                self.batchView_delegate?.progressIndicatorViewBatch(operation: .refresh)
                
                // Set date on Configuration
                let index = SharingManagerConfiguration.sharedInstance.getIndex(work.0)
                let config = SharingManagerConfiguration.sharedInstance.getConfigurations()[index]
                // Get transferred numbers from view
                self.transferredNumber = String(number.getTransferredNumbers(numbers: .transferredNumber))
                self.transferredNumberSizebytes = String(number.getTransferredNumbers(numbers: .transferredNumberSizebytes))
                
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
                
                self.executeBatch()
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
