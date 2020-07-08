//
//  NewSingleTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length cyclomatic_complexity

import Foundation

// Protocols for instruction start/stop progressviewindicator
protocol StartStopProgressIndicatorSingleTask: AnyObject {
    func startIndicator()
    func startIndicatorExecuteTaskNow()
    func stopIndicator()
}

// Protocol functions implemented in main view
protocol SingleTaskProcess: AnyObject {
    func presentViewProgress()
    func presentViewInformation(outputprocess: OutputProcess?)
    func terminateProgressProcess()
    func seterrorinfo(info: String)
    func setNumbers(outputprocess: OutputProcess?)
    func gettransferredNumber() -> String
    func gettransferredNumberSizebytes() -> String
}

final class SingleTask: SetSchedules, SetConfigurations {
    weak var indicatorDelegate: StartStopProgressIndicatorSingleTask?
    weak var singletaskDelegate: SingleTaskProcess?
    weak var setprocessDelegate: SendOutputProcessreference?

    private var index: Int?
    private var outputprocess: OutputProcess?
    private var maxcount: Int = 0
    private var workload: SingleTaskWorkQueu?

    func executeSingleTask() {
        if self.workload == nil {
            self.workload = SingleTaskWorkQueu()
        }
        switch self.workload?.peek() {
        case .estimatesinglerun:
            if let index = self.index {
                self.indicatorDelegate?.startIndicator()
                self.outputprocess = OutputProcessRsync()
                if let arguments = self.configurations?.arguments4rsync(index: index, argtype: .argdryRun) {
                    if #available(OSX 10.14, *) {
                        let process = RsyncVerify(arguments: arguments, config: (self.configurations?.getConfigurations()[index])!)
                        process.setdelegate(object: self)
                        process.executeProcess(outputprocess: self.outputprocess)
                        self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
                    } else {
                        let process = Rsync(arguments: arguments)
                        process.setdelegate(object: self)
                        process.executeProcess(outputprocess: self.outputprocess)
                        self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
                    }
                }
            }
        case .executesinglerun:
            if let index = self.index {
                self.singletaskDelegate?.presentViewProgress()
                self.outputprocess = OutputProcessRsync()
                if let arguments = self.configurations?.arguments4rsync(index: index, argtype: .arg) {
                    if #available(OSX 10.14, *) {
                        let process = RsyncVerify(arguments: arguments, config: (self.configurations?.getConfigurations()[index])!)
                        process.setdelegate(object: self)
                        process.executeProcess(outputprocess: self.outputprocess)
                        self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
                    } else {
                        let process = Rsync(arguments: arguments)
                        process.setdelegate(object: self)
                        process.executeProcess(outputprocess: self.outputprocess)
                        self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
                    }
                }
            }
        case .abort:
            self.workload = nil
            self.singletaskDelegate?.seterrorinfo(info: "Abort")
        case .empty:
            self.workload = nil
        default:
            self.workload = nil
        }
    }

    func error() {
        self.workload?.error()
    }

    init(index: Int) {
        self.index = index
        self.indicatorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.singletaskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.setprocessDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }
}

extension SingleTask: Count {
    func maxCount() -> Int {
        return self.maxcount
    }

    func inprogressCount() -> Int {
        return self.outputprocess?.count() ?? 0
    }
}

extension SingleTask: UpdateProgress {
    func processTermination() {
        if let workload = self.workload {
            switch workload.pop() {
            case .estimatesinglerun:
                self.indicatorDelegate?.stopIndicator()
                self.singletaskDelegate?.setNumbers(outputprocess: self.outputprocess)
                self.maxcount = self.outputprocess!.getMaxcount()
                self.singletaskDelegate?.presentViewInformation(outputprocess: self.outputprocess)
            case .error:
                self.indicatorDelegate?.stopIndicator()
                self.singletaskDelegate?.presentViewInformation(outputprocess: self.outputprocess)
                self.configurations?.setCurrentDateonConfiguration(index: self.index!, outputprocess: self.outputprocess)
                self.workload = nil
            case .executesinglerun:
                self.singletaskDelegate?.terminateProgressProcess()
                self.singletaskDelegate?.presentViewInformation(outputprocess: self.outputprocess)
                self.configurations?.setCurrentDateonConfiguration(index: self.index!, outputprocess: self.outputprocess)
            case .empty:
                self.workload = nil
            default:
                self.workload = nil
            }
        }
        // Reset process referance
        ViewControllerReference.shared.process = nil
    }

    func fileHandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess
        localprocessupdateDelegate?.fileHandler()
        outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
