//
//  newTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

// Protocols for instruction start/stop progressviewindicator
protocol StartStopProgressIndicatorSingleTask: class {
    func startIndicator()
    func stopIndicator()
}

// Protocol functions implemented in main view
protocol SingleTask: class {
    func showProcessInfo(info:displayProcessInfo)
    func presentViewProgress()
    func presentViewInformation(output: outputProcess)
    func terminateProgressProcess()
    func setInfo(info:String, color:colorInfo)
    func singleTaskAbort(process:Process?)
    func setNumbers(output:outputProcess?)
    func setmaxNumbersOfFilesToTransfer(output : outputProcess?)
    func gettransferredNumber() -> String
    func gettransferredNumberSizebytes() -> String
}

enum colorInfo {
    case red
    case blue
    case black
}

final class newSingleTask {
    
    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicator_delegate:StartStopProgressIndicatorSingleTask?
    // Delegate functions for kicking of various functions during 
    // process task
    weak var task_delegate:SingleTask?
    
    // Reference to Process task
    private var process:Process?
    // Index to selected row, index is set when row is selected
    private var index:Int?
    // Getting output from rsync
    private var output:outputProcess?
    // Holding max count
    private var maxcount:Int = 0
    // HiddenID task, set when row is selected
    private var hiddenID:Int?
    // Reference to Schedules object
    private var schedules : ScheduleSortedAndExpand?
    // Single task work queu
    private var workload:singleTaskWorkQueu?
    // Schedules in progress
    fileprivate var scheduledJobInProgress:Bool = false
    // Ready for execute again
    fileprivate var ready:Bool = true
    
    // Some max numbers
    private var transferredNumber:String?
    private var transferredNumberSizebytes:String?
    
  

    
    // Single task can be activated by double click from table
    func executeSingleTask() {
        
        if (self.scheduledOperationInProgress() == false && SharingManagerConfiguration.sharedInstance.noRysync == false){
            if (self.workload == nil) {
                self.workload = singleTaskWorkQueu()
            }
            
            let arguments: Array<String>?
            self.process = nil
            self.output = nil
            
            switch (self.workload!.peek()) {
            case .estimate_singlerun:
                if let index = self.index {
                    // Start animation and show process info
                    self.indicator_delegate?.startIndicator()
                    self.task_delegate?.showProcessInfo(info: .Estimating)
                    
                    arguments = SharingManagerConfiguration.sharedInstance.getRsyncArgumentOneConfig(index: index, argtype: .argdryRun)
                    let process = Rsync(arguments: arguments)
                    self.output = outputProcess()
                    process.executeProcess(output: self.output!)
                    self.process = process.getProcess()
                    self.task_delegate?.setInfo(info: "Execute", color: .blue)
                }
            case .execute_singlerun:
                self.task_delegate?.showProcessInfo(info: .Executing)
                if let index = self.index {
                    // Show progress view
                    self.task_delegate?.presentViewProgress()
                    arguments = SharingManagerConfiguration.sharedInstance.getRsyncArgumentOneConfig(index: index, argtype: .arg)
                    self.output = outputProcess()
                    let process = Rsync(arguments: arguments)
                    process.executeProcess(output: self.output!)
                    self.process = process.getProcess()
                    self.task_delegate?.setInfo(info: "", color: .black)
                }
            case .abort:
                self.workload = nil
                self.task_delegate?.setInfo(info: "Abort", color: .red)
            case .empty:
                self.workload = nil
                self.task_delegate?.setInfo(info: "Estimate", color: .blue)
            default:
                self.workload = nil
                self.task_delegate?.setInfo(info: "Estimate", color: .blue)
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
                // Getting and setting max file to transfer
                self.task_delegate?.setmaxNumbersOfFilesToTransfer(output: self.output)
                // If showInfoDryrun is on present result of dryrun automatically
                self.task_delegate?.presentViewInformation(output: self.output!)
            case .error:
                // Stopping the working (estimation) progress indicator
                self.indicator_delegate?.stopIndicator()
                //NB: self.working.stopAnimation(nil)
                // If showInfoDryrun is on present result of dryrun automatically
                self.task_delegate?.presentViewInformation(output: self.output!)
            case .execute_singlerun:
                //NB: self.showProcessInfo(info: .Logging_run)
                self.task_delegate?.showProcessInfo(info: .Logging_run)
                // Process termination and close progress view
                self.task_delegate?.terminateProgressProcess()
                // If showInfoDryrun is on present result of dryrun automatically
                self.task_delegate?.presentViewInformation(output: self.output!)
                // Logg run
                let number = Numbers(output: self.output!.getOutput())
                number.setNumbers()
                // Get transferred numbers from view
                self.transferredNumber = self.task_delegate?.gettransferredNumber()
                self.transferredNumberSizebytes = self.task_delegate?.gettransferredNumberSizebytes()
                SharingManagerConfiguration.sharedInstance.setCurrentDateonConfiguration(self.index!)
                let hiddenID = SharingManagerConfiguration.sharedInstance.gethiddenID(index: self.index!)
                SharingManagerSchedule.sharedInstance.addScheduleResultManuel(hiddenID, result: number.statistics(numberOfFiles: self.transferredNumber, sizeOfFiles: self.transferredNumberSizebytes)[0])
            case .abort:
                self.task_delegate?.singleTaskAbort(process: self.process)
                self.workload = nil
            case .empty:
                self.workload = nil
            default:
                self.workload = nil
                break
            }
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
    
    init(index: Int) {
        
        self.index = index
        
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain as? ViewControllertabMain {
            self.indicator_delegate = pvc
            self.task_delegate = pvc
        }
        
            
        
        
    }
    
}
