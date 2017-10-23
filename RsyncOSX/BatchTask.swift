//
//  newBatchTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar line_length

import Foundation
import Cocoa

protocol BatchTaskProgress: class {
    func progressIndicatorViewBatch(operation: BatchViewProgressIndicator)
    func setOutputBatch(outputbatch: OutputBatch?)
}

enum BatchViewProgressIndicator {
    case start
    case stop
    case complete
    case refresh
}

final class BatchTask: SetSchedules, SetConfigurations, Delay {

    weak var closeviewerrorDelegate: closeViewError?
    // Protocol function used in Process().
    weak var processupdateDelegate: UpdateProgress?
    // Delegate for presenting batchView
    weak var batchViewDelegate: BatchTaskProgress?
    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicatorDelegate: StartStopProgressIndicatorSingleTask?
    // Delegate function for show process step and present View
    weak var taskDelegate: SingleTaskProgress?
    // Reference to Process task
    var process: Process?
    // Getting output from rsync
    var output: OutputProcess?
    // Getting output from batchrun
    private var outputbatch: OutputBatch?
    // HiddenID task, set when row is selected
    private var hiddenID: Int?
    // Schedules in progress
    private var scheduledJobInProgress: Bool = false
    // Some max numbers
    private var transfernum: String?
    private var transferbytes: String?

    // Functions are called from batchView.
    func executeBatch() {
        if let batchobject = self.configurations!.getbatchQueue() {
            // Just copy the work object.
            // The work object will be removed in Process termination
            let work = batchobject.nextBatchCopy()
            // Get the index if given hiddenID (in work.0)
            let index: Int = self.configurations!.getIndex(work.0)
            // Create the output object for rsync
            self.output = nil
            self.output = OutputProcess()
            switch work.1 {
            case 0:
                self.batchViewDelegate?.progressIndicatorViewBatch(operation: .start)
                let args: Array<String> = self.configurations!.arguments4rsync(index: index, argtype: .argdryRun)
                let process = Rsync(arguments: args)
                // Setting reference to process for Abort if requiered
                process.executeProcess(output: self.output)
                self.process = process.getProcess()
            case 1:
                let arguments: Array<String> = self.configurations!.arguments4rsync(index: index, argtype: .arg)
                let process = Rsync(arguments: arguments)
                // Setting reference to process for Abort if requiered
                process.executeProcess(output: self.output)
                self.process = process.getProcess()
            case -1:
                self.batchViewDelegate?.setOutputBatch(outputbatch: self.outputbatch)
                self.batchViewDelegate?.progressIndicatorViewBatch(operation: .complete)
                self.configurationsDelegate?.reloadconfigurations()
            default : break
            }
        }
    }

    func closeOperation() {
        self.process = nil
        self.taskDelegate?.setInfo(info: "", color: .black)
    }

    // Error and stop execution
    func error() {
        // Just pop off remaining work
        if let batchobject = self.configurations!.getbatchQueue() {
            batchobject.abortOperations()
            self.closeviewerrorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
            self.closeviewerrorDelegate?.closeerror()
        }
    }

    // Called when ProcessTermination is called in main View.
    // Either dryn-run or realrun completed.
    func processTermination() {
        if let batchobject = self.configurations!.getbatchQueue() {
            if self.outputbatch == nil {
                self.outputbatch = OutputBatch()
            }
            // Remove the first worker object
            let work = batchobject.nextBatchRemove()
            // (work.0) is estimationrun, (work.1) is real run
            switch work.1 {
            case 0:
                // dry-run
                self.taskDelegate?.setNumbers(output: self.output)
                batchobject.setEstimated(numberOfFiles: self.output?.getMaxcount() ?? 0)
                self.batchViewDelegate?.progressIndicatorViewBatch(operation: .stop)
                self.delayWithSeconds(1) {
                    self.executeBatch()
                }
            case 1:
                // Real run
                let number = Numbers(output: self.output)
                batchobject.updateInProcess(numberOfFiles: self.output!.count())
                batchobject.setCompleted()
                self.batchViewDelegate?.progressIndicatorViewBatch(operation: .refresh)
                // Set date on Configuration
                let index = self.configurations!.getIndex(work.0)
                let config = self.configurations!.getConfigurations()[index]
                // Get transferred numbers from view
                self.transfernum = String(number.getTransferredNumbers(numbers: .transferredNumber))
                self.transferbytes = String(number.getTransferredNumbers(numbers: .transferredNumberSizebytes))
                if config.offsiteServer.isEmpty {
                    let hiddenID = self.configurations!.gethiddenID(index: index)
                    let numbers = number.stats(numberOfFiles: self.transfernum, sizeOfFiles: self.transferbytes)[0]
                    let result = config.localCatalog + " , " + "localhost" + " , " + numbers
                    self.outputbatch!.addLine(str: result)
                    self.schedules!.addlogtaskmanuel(hiddenID, result: numbers)
                } else {
                    let hiddenID = self.configurations!.gethiddenID(index: index)
                    let numbers = number.stats(numberOfFiles: self.transfernum, sizeOfFiles: self.transferbytes)[0]
                    let result = config.localCatalog + " , " + config.offsiteServer + " , " + numbers
                    self.outputbatch!.addLine(str: result)
                    self.schedules!.addlogtaskmanuel(hiddenID, result: numbers)
                }
                self.configurations!.setCurrentDateonConfiguration(index)
                self.delayWithSeconds(1) {
                    self.executeBatch()
                }
            default :
                break
            }
        }
    }

    init() {
        self.indicatorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.taskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.batchViewDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.outputbatch = nil
    }

}
