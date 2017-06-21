//
//  newTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

// Protocols for instruction start/stop progressviewindicator
protocol StartStopProgressIndicatorSingleTask: class {
    func startIndicator()
    func stopIndicator()
}

protocol Task: class {
    func showProcessInfo(info:displayProcessInfo)
    func presentViewProgress()
    func presentViewInformation(output: outputProcess)
    func terminateProgressProcess()
}

class newSingleTask {
    
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

    
    // Single task can be activated by double click from table
    func executeSingleTask() {
        
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
                    self.indicator_delegate?.startIndicator()
                    self.task_delegate?.showProcessInfo(info: .Estimating)
                    // NB: self.working.startAnimation(nil)
                    // NB: self.showProcessInfo(info: .Estimating)
                    arguments = SharingManagerConfiguration.sharedInstance.getRsyncArgumentOneConfig(index: index, argtype: .argdryRun)
                    let process = Rsync(arguments: arguments)
                    self.output = outputProcess()
                    process.executeProcess(output: self.output!)
                    self.process = process.getProcess()
                    self.setInfo(info: "Execute", color: .blue)
                    
                    // Next run is real run
                    self.dryrun = false
                }
            case .execute_singlerun:
                // NB: self.showProcessInfo(info: .Executing)
                self.task_delegate?.showProcessInfo(info: .Executing)
                if let index = self.index {
                    self.task_delegate?.presentViewProgress()
                    /*
                    GlobalMainQueue.async(execute: { () -> Void in
                        // NB: self.presentViewControllerAsSheet(self.ViewControllerProgress)
                    })
                    */
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
    
    
    
    func ProcessTermination() {
        
        self.ready = true
        // Making sure no nil pointer execption
        if let workload = self.workload {
            
            // Pop topmost element of work queue
            switch (workload.pop()) {
                
            case .estimate_singlerun:
                // Stopping the working (estimation) progress indicator
                self.indicator_delegate?.stopIndicator()
                //NB: self.working.stopAnimation(nil)
                // Getting and setting max file to transfer
                self.setmaxNumbersOfFilesToTransfer()
                // If showInfoDryrun is on present result of dryrun automatically
                self.task_delegate?.presentViewInformation(output: self.output!)
                /* NB:
                if (self.showInfoDryrun.state == 1) {
                    GlobalMainQueue.async(execute: { () -> Void in
                        self.presentViewControllerAsSheet(self.ViewControllerInformation)
                    })
                }
                */
            case .error:
                // Stopping the working (estimation) progress indicator
                self.indicator_delegate?.stopIndicator()
                //NB: self.working.stopAnimation(nil)
                // If showInfoDryrun is on present result of dryrun automatically
                self.task_delegate?.presentViewInformation(output: self.output!)
                /* NB:
                GlobalMainQueue.async(execute: { () -> Void in
                    self.presentViewControllerAsSheet(self.ViewControllerInformation)
                })
                */
            case .execute_singlerun:
                //NB: self.showProcessInfo(info: .Logging_run)
                self.task_delegate?.showProcessInfo(info: .Logging_run)
                
                /* NB:
                if let pvc2 = self.presentedViewControllers as? [ViewControllerProgressProcess] {
                    if (pvc2.count > 0) {
                        self.processupdate_delegate = pvc2[0]
                        self.processupdate_delegate?.ProcessTermination()
                    }
                }
                */
                self.task_delegate?.terminateProgressProcess()
                
                // If showInfoDryrun is on present result of dryrun automatically
                self.task_delegate?.presentViewInformation(output: self.output!)
                /* NB:
                if (self.showInfoDryrun.state == 1) {
                    GlobalMainQueue.async(execute: { () -> Void in
                        self.presentViewControllerAsSheet(self.ViewControllerInformation)
                    })
                }
                */
                // Logg run
                let number = Numbers(output: self.output!.getOutput())
                number.setNumbers()
                SharingManagerConfiguration.sharedInstance.setCurrentDateonConfiguration(self.index!)
                SharingManagerSchedule.sharedInstance.addScheduleResultManuel(self.hiddenID!, result: number.statistics(numberOfFiles: self.transferredNumber, sizeOfFiles: self.transferredNumberSizebytes)[0])
            case .abort:
                //NB: self.abortOperations()
                self.workload = nil
            case .empty:
                self.workload = nil
            default:
                self.workload = nil
                break
            }
        }
    }

    
    func setInfo(info:String, color:NSColor) {
        // NB: self.dryRunOrRealRun.stringValue = info
        // NB: self.dryRunOrRealRun.textColor = color
        
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
    
    init(index: Int) {
        
        self.dryrun = true
        self.index = index
        
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain as? ViewControllertabMain {
            self.indicator_delegate = pvc
            self.task_delegate = pvc
        }
        
            
        
        
    }
    
}
