//
//  NewSingleTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar line_length

import Foundation

// Protocols for instruction start/stop progressviewindicator
protocol StartStopProgressIndicatorSingleTask: class {
    func startIndicator()
    func stopIndicator()
}

// Protocol functions implemented in main view
protocol SingleTaskProgress: class {
    func showProcessInfo(info: DisplayProcessInfo)
    func presentViewProgress()
    func presentViewInformation(output: OutputProcess)
    func terminateProgressProcess()
    func setInfo(info: String, color: ColorInfo)
    func setNumbers(output: OutputProcess?)
    func gettransferredNumber() -> String
    func gettransferredNumberSizebytes() -> String
    func getProcessReference(process: Process)
}

enum ColorInfo {
    case red
    case blue
    case black
}

final class SingleTask: SetSchedules, SetConfigurations {

    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicatorDelegate: StartStopProgressIndicatorSingleTask?
    // Delegate functions for kicking of various updates (informal) during
    // process task in main View
    weak var taskDelegate: SingleTaskProgress?
    // Reference to Process task
    var process: Process?
    // Index to selected row, index is set when row is selected
    private var index: Int?
    // Getting output from rsync
    var output: OutputProcess?
    // Holding max count
    private var maxcount: Int = 0
    // HiddenID task, set when row is selected
    private var hiddenID: Int?
    // Single task work queu
    private var workload: SingleTaskWorkQueu?
    // Schedules in progress
    private var scheduledJobInProgress: Bool = false
    // Ready for execute again
    private var ready: Bool = true
    // Some max numbers
    private var transferredNumber: String?
    private var transferredNumberSizebytes: String?

    // Single task can be activated by double click from table
    func executeSingleTask() {

        if self.workload == nil {
            self.workload = SingleTaskWorkQueu()
        }

        let arguments: Array<String>?
        self.process = nil
        self.output = nil

        switch self.workload!.peek() {
        case .estimatesinglerun:
            if let index = self.index {
                // Start animation and show process info
                self.indicatorDelegate?.startIndicator()
                self.taskDelegate?.showProcessInfo(info: .estimating)
                arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRun)
                let process = Rsync(arguments: arguments)
                self.output = OutputProcess()
                process.executeProcess(output: self.output)
                self.process = process.getProcess()
                self.taskDelegate?.getProcessReference(process: self.process!)
                self.taskDelegate?.setInfo(info: "Execute", color: .blue)
            }
        case .executesinglerun:
            self.taskDelegate?.showProcessInfo(info: .executing)
            if let index = self.index {
                // Show progress view
                self.taskDelegate?.presentViewProgress()
                arguments = self.configurations!.arguments4rsync(index: index, argtype: .arg)
                self.output = OutputProcess()
                let process = Rsync(arguments: arguments)
                process.executeProcess(output: self.output)
                self.process = process.getProcess()
                self.taskDelegate?.getProcessReference(process: self.process!)
                self.taskDelegate?.setInfo(info: "", color: .black)
            }
        case .abort:
            self.workload = nil
            self.taskDelegate?.setInfo(info: "Abort", color: .red)
        case .empty:
            self.workload = nil
            self.taskDelegate?.setInfo(info: "Estimate", color: .blue)
        default:
            self.workload = nil
            self.taskDelegate?.setInfo(info: "Estimate", color: .blue)
        }
    }

    func processTermination() {

        self.ready = true
        // Making sure no nil pointer execption
        if let workload = self.workload {

            // Pop topmost element of work queue
            switch workload.pop() {
            case .estimatesinglerun:
                // Stopping the working (estimation) progress indicator
                self.indicatorDelegate?.stopIndicator()
                // Getting and setting max file to transfer
                self.taskDelegate?.setNumbers(output: self.output)
                self.maxcount = self.output!.getMaxcount()
                // If showInfoDryrun is on present result of dryrun automatically
                self.taskDelegate?.presentViewInformation(output: self.output!)
            case .error:
                // Stopping the working (estimation) progress indicator
                self.indicatorDelegate?.stopIndicator()
                // If showInfoDryrun is on present result of dryrun automatically
                self.taskDelegate?.presentViewInformation(output: self.output!)
                self.workload = nil
            case .executesinglerun:
                //NB: self.showProcessInfo(info: .Logging_run)
                self.taskDelegate?.showProcessInfo(info: .loggingrun)
                // Process termination and close progress view
                self.taskDelegate?.terminateProgressProcess()
                // If showInfoDryrun is on present result of dryrun automatically
                self.taskDelegate?.presentViewInformation(output: self.output!)
                // Logg run
                let number = Numbers(output: self.output)
                // Get transferred numbers from view
                self.transferredNumber = self.taskDelegate?.gettransferredNumber()
                self.transferredNumberSizebytes = self.taskDelegate?.gettransferredNumberSizebytes()
                self.configurations!.setCurrentDateonConfiguration(self.index!)
                let hiddenID = self.configurations!.gethiddenID(index: self.index!)
                let numberOffFiles = self.transferredNumber
                let sizeOfFiles = self.transferredNumberSizebytes
                self.schedules!.addlogtaskmanuel(hiddenID, result: number.stats(numberOfFiles: numberOffFiles, sizeOfFiles: sizeOfFiles)[0])
            case .empty:
                self.workload = nil
            default:
                self.workload = nil
            }
        }
    }

    // Put error token ontop of workload
    func error() {
        guard self.workload != nil else {
            return
        }
        self.workload!.error()
    }

    init(index: Int) {
        self.index = index
        self.indicatorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.taskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}

// Counting
extension SingleTask: Count {

    // Maxnumber of files counted
    func maxCount() -> Int {
        return self.maxcount
    }

    // Counting number of files
    // Function is called when Process discover FileHandler notification
    func inprogressCount() -> Int {
        guard self.output != nil else {
            return 0
        }
        return self.output!.count()
    }

}
