//
//  Checksynchronizedfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class Checksynchronizedfiles: SetConfigurations {
    var index: Int?
    weak var setprocessDelegate: SendOutputProcessreference?
    weak var indicatorDelegate: StartStopProgressIndicatorSingleTask?
    var outputprocess: OutputProcess?
    var command: RsyncProcessCmdClosure?

    func checksynchronizedfiles() {
        guard ViewControllerReference.shared.process == nil else { return }
        if let index = self.index {
            if let arguments = self.configurations?.arguments4verify(index: index) {
                self.outputprocess = OutputProcess()
                self.outputprocess?.addlinefromoutput(str: "*** Verify ***")
                self.verifyandchanged(arguments: arguments)
            }
        }
    }

    private func verifyandchanged(arguments: [String]) {
        self.indicatorDelegate?.startIndicator()
        self.command = RsyncProcessCmdClosure(arguments: arguments,
                                              config: nil,
                                              processtermination: self.processtermination,
                                              filehandler: self.filehandler)
        self.command?.executeProcess(outputprocess: self.outputprocess)
        self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
    }

    init(index: Int?) {
        self.index = index
        self.setprocessDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.indicatorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }
}

extension Checksynchronizedfiles {
    func processtermination() {
        self.command = nil
        self.indicatorDelegate?.stopIndicator()
    }

    func filehandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
