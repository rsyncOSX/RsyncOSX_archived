//
//  newBatchTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Cocoa
import Foundation

final class ExecuteBatch: SetSchedules, SetConfigurations {
    weak var closeviewerrorDelegate: ReportonandhaltonError?
    var process: Process?
    var outputprocess: OutputProcess?
    var hiddenID: Int?

    var estimatedlist: [NSDictionary]?
    var batchqueue: BatchTaskWorkQueu?

    func executebatch() {
        if self.estimatedlist == nil {
            self.estimatedlist = self.configurations?.estimatedlist
        }
        if let batchobject = self.batchqueue {
            let work = batchobject.copyofnexttaskinqueue()
            switch work.1 {
            case 1:
                let index: Int = self.configurations!.getIndex(work.0)
                let config = self.configurations!.getConfigurations()[index]
                self.hiddenID = config.hiddenID
                self.outputprocess = OutputProcess()
                let arguments: [String] = self.configurations!.arguments4rsync(index: index, argtype: .arg)
                let process = Rsync(arguments: arguments)
                process.setdelegate(object: self)
                process.executeProcess(outputprocess: self.outputprocess)
                self.process = process.getProcess()
            case -1:
                weak var localupdateprogressDelegate: StartStopProgressIndicator?
                localupdateprogressDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
                localupdateprogressDelegate?.complete()
                self.configurationsDelegate?.reloadconfigurationsobject()
            default:
                break
            }
        }
    }

    func closeOperation() {
        self.process?.terminate()
        self.process = nil
        self.estimatedlist = nil
        self.configurations!.remoteinfoestimation = nil
    }

    func error() {
        self.closeviewerrorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
        self.closeviewerrorDelegate?.reportandhaltonerror()
    }

    func incount() -> Int {
        return self.outputprocess?.getOutput()?.count ?? 0
    }

    func maxcountintask(hiddenID: Int) -> Int {
        let max = self.estimatedlist?.filter { $0.value(forKey: "hiddenID") as? Int == hiddenID }
        guard max?.count ?? 0 > 0 else { return 0 }
        let maxnumber = max![0].value(forKey: "transferredNumber") as? String ?? "0"
        return Int(maxnumber) ?? 0
    }

    init() {
        self.batchqueue = self.configurations?.getbatchQueue()
    }
}

extension ExecuteBatch: UpdateProgress {
    func processTermination() {
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
        localprocessupdateDelegate?.processTermination()
        if let batchobject = self.batchqueue {
            let work = batchobject.removenexttaskinqueue()
            let index = self.configurations!.getIndex(work.0)
            let config = self.configurations!.getConfigurations()[index]
            self.hiddenID = config.hiddenID
            self.configurations!.setCurrentDateonConfiguration(index: index, outputprocess: self.outputprocess)
            self.executebatch()
        }
    }

    func fileHandler() {
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
        localprocessupdateDelegate?.fileHandler()
    }
}
