//
//  newBatchTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

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

    weak var closeviewerrorDelegate: CloseViewError?
    weak var processupdateDelegate: UpdateProgress?
    weak var batchViewDelegate: BatchTaskProgress?
    var process: Process?
    var outputprocess: OutputProcess?
    private var outputbatch: OutputBatch?
    var hiddenID: Int?
    var maxcount: Int?
    var estimatedlist: [NSMutableDictionary]?

    func executeBatch() {
        if let batchobject = self.configurations!.getbatchQueue() {
            self.estimatedlist = self.configurations?.estimatedlist
            let work = batchobject.nextBatchCopy()
            let index: Int = self.configurations!.getIndex(work.0)
            self.outputprocess = nil
            self.outputprocess = OutputProcess()
            switch work.1 {
            case 0:
                return
            case 1:
                let arguments: [String] = self.configurations!.arguments4rsync(index: index, argtype: .arg)
                let process = Rsync(arguments: arguments)
                process.executeProcess(outputprocess: self.outputprocess)
                self.process = process.getProcess()
            case -1:
                self.batchViewDelegate?.setOutputBatch(outputbatch: self.outputbatch)
                self.batchViewDelegate?.progressIndicatorViewBatch(operation: .complete)
                self.configurationsDelegate?.reloadconfigurationsobject()
            default : break
            }
        }
    }

    func closeOperation() {
        self.process = nil
        self.configurations?.estimatedlist = nil
        self.configurations!.remoteinfotaskworkqueue = nil
    }

    func error() {
        if let batchobject = self.configurations!.getbatchQueue() {
            batchobject.abortOperations()
            self.closeviewerrorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
            self.closeviewerrorDelegate?.closeerror()
        }
    }

    func processTermination() {
        if let batchobject = self.configurations!.getbatchQueue() {
            if self.outputbatch == nil {
                self.outputbatch = OutputBatch()
            }
            let work = batchobject.nextBatchRemove()
            // (work.0) is estimationrun, (work.1) is real run
            switch work.1 {
            case 0:
                return
            case 1:
                batchobject.updateInProcess(numberOfFiles: self.outputprocess!.count())
                batchobject.setCompleted()
                self.batchViewDelegate?.progressIndicatorViewBatch(operation: .refresh)
                // Set date on Configuration
                let index = self.configurations!.getIndex(work.0)
                let config = self.configurations!.getConfigurations()[index]
                self.configurations!.setCurrentDateonConfigurationSingletask(index: index, outputprocess: self.outputprocess)
                let numbers = "test"
                var result: String?
                if config.offsiteServer.isEmpty {
                    result = config.localCatalog + " , " + "localhost" + " , " + numbers
                } else {
                    result = config.localCatalog + " , " + config.offsiteServer + " , " + numbers
                }
                self.outputbatch!.addLine(str: result!)
                self.delayWithSeconds(1) {
                    self.executeBatch()
                }
            default :
                break
            }
        }
    }

    func incount() -> Int {
        return self.outputprocess?.getOutput()?.count ?? 0
    }

    init() {
        self.batchViewDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.outputbatch = nil
    }

}
