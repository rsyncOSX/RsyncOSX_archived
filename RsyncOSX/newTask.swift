//
//  newTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class newTask {
    
    // Protocol function used in Process().
    weak var processupdate_delegate:UpdateProgress?
    // Delegate function for doing a refresh of NSTableView in ViewControllerBatch
    weak var refresh_delegate:RefreshtableView?
    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicator_delegate:StartStopProgressIndicator?
    
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
    private var output:outputProcess?
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
    private var transferredNumber:String?
    private var transferredNumberSizebytes:String?
    private var totalNumber:String?
    private var totalNumberSizebytes:String?
    private var totalDirs:String?
    private var newfiles:String?
    private var deletefiles:String?
    
    

    
    // Display correct rsync command in view
    func setRsyncCommandDisplay() -> String {
        guard (self.dryrun != nil || self.index != nil)  else {
            return ""
        }
        return Utils.sharedInstance.setRsyncCommandDisplay(index: self.index!, dryRun: self.dryrun!)
    }
    
    
    
    
    // Single task can be activated by double click from table
    func executeSingelTask() {
        
        if (self.scheduledOperationInProgress() == false && SharingManagerConfiguration.sharedInstance.noRysync == false){
            if (self.workload == nil) {
                self.workload = singleTask()
            }
            
            let arguments: Array<String>?
            self.process = nil
            self.output = nil
            
            switch (self.workload!.peek()) {
            case .estimate_singlerun:
                if let index = self.index {
                    // NB: self.working.startAnimation(nil)
                    // NB: self.showProcessInfo(info: .Estimating)
                    arguments = SharingManagerConfiguration.sharedInstance.getRsyncArgumentOneConfig(index: index, argtype: .argdryRun)
                    let process = Rsync(arguments: arguments)
                    self.output = outputProcess()
                    process.executeProcess(output: self.output!)
                    self.process = process.getProcess()
                    self.setInfo(info: "Execute", color: .blue)
                }
            case .execute_singlerun:
                // NB: self.showProcessInfo(info: .Executing)
                if let index = self.index {
                    GlobalMainQueue.async(execute: { () -> Void in
                        // NB: self.presentViewControllerAsSheet(self.ViewControllerProgress)
                    })
                    arguments = SharingManagerConfiguration.sharedInstance.getRsyncArgumentOneConfig(index: index, argtype: .arg)
                    self.output = outputProcess()
                    let process = Rsync(arguments: arguments)
                    process.executeProcess(output: self.output!)
                    self.process = process.getProcess()
                    self.setInfo(info: "", color: .black)
                }
            case .abort:
                self.workload = nil
                self.setInfo(info: "Abort", color: .red)
            case .empty:
                self.workload = nil
                self.setInfo(info: "Estimate", color: .blue)
            default:
                self.workload = nil
                self.setInfo(info: "Estimate", color: .blue)
                break
            }
        } else {
            Utils.sharedInstance.noRsync()
        }
    }
    
    func setInfo(info:String, color:NSColor) {
        // NB: self.dryRunOrRealRun.stringValue = info
        // NB: self.dryRunOrRealRun.textColor = color
        
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
            self.workload = singleTask(task: .batchrun)
            self.setInfo(info: "Batchrun", color: .blue)
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
    
    
    // Reread bot Configurations and Schedules from persistent store to memory
    func ReReadConfigurationsAndSchedules() {
        // Reading main Configurations to memory
        SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        SharingManagerConfiguration.sharedInstance.readAllConfigurationsAndArguments()
        // Read all Scheduled data again
        SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        SharingManagerSchedule.sharedInstance.readAllSchedules()
    }
    
    //  End delegate functions Process object
    
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
    
    
    init(config: configuration, dryrun: Bool, index: Int) {
        self.config = config
        self.dryrun = dryrun
        self.index = index
        
    }
    
}
