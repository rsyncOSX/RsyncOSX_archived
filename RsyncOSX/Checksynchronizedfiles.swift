//
//  Checksynchronizedfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class Checksynchronizedfiles: SetConfigurations {
    var index: Int?
    weak var setprocessDelegate: SendOutputProcessreference?
    weak var indicatorDelegate: StartStopProgressIndicatorSingleTask?
    var outputprocess: OutputfromProcess?
    var command: RsyncProcess?

    func checksynchronizedfiles() {
        guard SharedReference.shared.process == nil else { return }
        if let index = self.index,
           let hiddenID = configurations?.gethiddenID(index: index)
        {
            if let arguments = configurations?.arguments4verify(hiddenID: hiddenID) {
                outputprocess = OutputfromProcess()
                outputprocess?.addlinefromoutput(str: "*** Checking synchronized data ***")
                outputprocess?.addlinefromoutput(str: "*** using --checksum parameter ***")
                outputprocess?.addlinefromoutput(str: "")
                verifyandchanged(arguments: arguments)
            }
        }
    }

    private func verifyandchanged(arguments: [String]) {
        indicatorDelegate?.startIndicator()
        command = RsyncProcess(arguments: arguments,
                               config: nil,
                               processtermination: processtermination,
                               filehandler: filehandler)
        command?.executeProcess(outputprocess: outputprocess)
        setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
    }

    init(index: Int?) {
        self.index = index
        setprocessDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        indicatorDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }
}

extension Checksynchronizedfiles {
    func processtermination() {
        command = nil
        indicatorDelegate?.stopIndicator()
    }

    func filehandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
