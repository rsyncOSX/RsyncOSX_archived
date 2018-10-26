//
//  NewSingleTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

// Protocols for instruction start/stop progressviewindicator
protocol StartStopProgressIndicatorSingleTask: class {
    func startIndicator()
    func stopIndicator()
}

// Protocol functions implemented in main view
protocol SingleTaskProgress: class {
    func presentViewProgress()
    func presentViewInformation(outputprocess: OutputProcess)
    func terminateProgressProcess()
    func setinfonextaction(info: String, color: ColorInfo)
    func setNumbers(outputprocess: OutputProcess?)
    func gettransferredNumber() -> String
    func gettransferredNumberSizebytes() -> String
    func getProcessReference(process: Process)
}

enum ColorInfo {
    case red
    case green
    case black
}

final class SingleTask: SetSchedules, SetConfigurations {

    weak var indicatorDelegate: StartStopProgressIndicatorSingleTask?
    weak var taskDelegate: SingleTaskProgress?
    var process: Process?
    private var index: Int?
    var outputprocess: OutputProcess?
    private var maxcount: Int = 0
    private var hiddenID: Int?
    private var workload: SingleTaskWorkQueu?
    private var scheduledJobInProgress: Bool = false
    private var ready: Bool = true

    func executeSingleTask() {
        if self.workload == nil {
            self.workload = SingleTaskWorkQueu()
        }
        let arguments: [String]?
        switch self.workload!.peek() {
        case .estimatesinglerun:
            if let index = self.index {
                self.indicatorDelegate?.startIndicator()
                arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRun)
                let process = Rsync(arguments: arguments)
                self.outputprocess = OutputProcess()
                process.executeProcess(outputprocess: self.outputprocess)
                self.process = process.getProcess()
                self.taskDelegate?.getProcessReference(process: self.process!)
            }
        case .executesinglerun:
            if let index = self.index {
                self.taskDelegate?.presentViewProgress()
                arguments = self.configurations!.arguments4rsync(index: index, argtype: .arg)
                self.outputprocess = OutputProcess()
                let process = Rsync(arguments: arguments)
                process.executeProcess(outputprocess: self.outputprocess)
                self.process = process.getProcess()
                self.taskDelegate?.getProcessReference(process: self.process!)
                self.taskDelegate?.setinfonextaction(info: "", color: .black)
            }
        case .abort:
            self.workload = nil
            self.taskDelegate?.setinfonextaction(info: "Abort", color: .red)
        case .empty:
            self.workload = nil
            self.taskDelegate?.setinfonextaction(info: "Estimate", color: .green)
        default:
            self.workload = nil
            self.taskDelegate?.setinfonextaction(info: "Estimate", color: .green)
        }
    }

    func processTermination() {

        self.ready = true
        if let workload = self.workload {
            switch workload.pop() {
            case .estimatesinglerun:
                self.taskDelegate?.setinfonextaction(info: "Execute", color: .green)
                self.indicatorDelegate?.stopIndicator()
                self.taskDelegate?.setNumbers(outputprocess: self.outputprocess)
                self.maxcount = self.outputprocess!.getMaxcount()
                self.taskDelegate?.presentViewInformation(outputprocess: self.outputprocess!)
            case .error:
                self.indicatorDelegate?.stopIndicator()
                self.taskDelegate?.presentViewInformation(outputprocess: self.outputprocess!)
                self.workload = nil
            case .executesinglerun:
                self.taskDelegate?.terminateProgressProcess()
                self.taskDelegate?.presentViewInformation(outputprocess: self.outputprocess!)
                self.configurations!.setCurrentDateonConfiguration(index: self.index!, outputprocess: self.outputprocess)
            case .empty:
                self.workload = nil
            default:
                self.workload = nil
            }
        }
    }

    func error() {
        guard self.workload != nil else { return }
        self.workload!.error()
    }

    init(index: Int) {
        self.index = index
        self.indicatorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.taskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}

extension SingleTask: Count {

    func maxCount() -> Int {
        return self.maxcount
    }

    func inprogressCount() -> Int {
        guard self.outputprocess != nil else { return 0 }
        return self.outputprocess!.count()
    }

}
