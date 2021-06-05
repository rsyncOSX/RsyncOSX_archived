//
//  NewSingleTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

protocol SendOutputProcessreference: AnyObject {
    func sendoutputprocessreference(outputprocess: OutputfromProcess?)
}

// Protocols for instruction start/stop progressviewindicator
protocol StartStopProgressIndicatorSingleTask: AnyObject {
    func startIndicator()
    func startIndicatorExecuteTaskNow()
    func stopIndicator()
}

// Protocol functions implemented in main view
protocol SingleTaskProcess: AnyObject {
    func presentViewProgress()
    func presentViewInformation(outputprocess: OutputfromProcess?)
    func terminateProgressProcess()
}

final class SingleTask: SetSchedules, SetConfigurations {
    weak var indicatorDelegate: StartStopProgressIndicatorSingleTask?
    weak var singletaskDelegate: SingleTaskProcess?
    weak var setprocessDelegate: SendOutputProcessreference?

    var index: Int?
    var outputprocess: OutputfromProcess?
    var maxcount: Int = 0
    var workload: SingleTaskWorkQueu?
    var command: RsyncProcess?

    func executesingletask() {
        if workload == nil {
            workload = SingleTaskWorkQueu()
        }
        switch workload?.peek() {
        case .estimatesinglerun:
            if let index = self.index,
               let hiddenID = configurations?.gethiddenID(index: index)
            {
                indicatorDelegate?.startIndicator()
                outputprocess = OutputfromProcessRsync()
                if let arguments = configurations?.arguments4rsync(hiddenID: hiddenID,
                                                                   argtype: .argdryRun)
                {
                    command = RsyncProcess(arguments: arguments,
                                           config: configurations?.getConfigurations()?[index],
                                           processtermination: processtermination,
                                           filehandler: filehandler)
                    command?.executeProcess(outputprocess: outputprocess)
                    setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
                }
            }
        case .executesinglerun:
            if let index = self.index,
               let hiddenID = configurations?.gethiddenID(index: index)
            {
                singletaskDelegate?.presentViewProgress()
                outputprocess = OutputfromProcessRsync()
                if let arguments = configurations?.arguments4rsync(hiddenID: hiddenID,
                                                                   argtype: .arg)
                {
                    command = RsyncProcess(arguments: arguments,
                                           config: configurations?.getConfigurations()?[index],
                                           processtermination: processtermination,
                                           filehandler: filehandler)
                    command?.executeProcess(outputprocess: outputprocess)
                    setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
                }
            }
        case .abort:
            workload = nil
        case .empty:
            workload = nil
        default:
            workload = nil
        }
    }

    func error() {
        workload?.error()
    }

    init(index: Int) {
        self.index = index
        indicatorDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        singletaskDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        setprocessDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }
}

extension SingleTask {
    func processtermination() {
        if let workload = self.workload,
           let index = self.index
        {
            switch workload.pop() {
            case .estimatesinglerun:
                indicatorDelegate?.stopIndicator()
                maxcount = TrimTwo(outputprocess?.getOutput() ?? []).maxnumber
                singletaskDelegate?.presentViewInformation(outputprocess: outputprocess)
            case .error:
                indicatorDelegate?.stopIndicator()
                singletaskDelegate?.presentViewInformation(outputprocess: outputprocess)
                configurations?.setCurrentDateonConfiguration(index: index, outputprocess: outputprocess)
                self.workload = nil
            case .executesinglerun:
                singletaskDelegate?.terminateProgressProcess()
                singletaskDelegate?.presentViewInformation(outputprocess: outputprocess)
                configurations?.setCurrentDateonConfiguration(index: index, outputprocess: outputprocess)
            case .empty:
                self.workload = nil
            default:
                self.workload = nil
            }
        }
        // Reset process referance
        command = nil
    }

    func filehandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = SharedReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess
        localprocessupdateDelegate?.fileHandler()
        outputeverythingDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}

extension SingleTask: Count {
    func maxCount() -> Int {
        return maxcount
    }

    func inprogressCount() -> Int {
        return outputprocess?.getOutput()?.count ?? 0
    }
}
