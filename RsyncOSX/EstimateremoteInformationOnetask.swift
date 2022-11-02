//
//  EstimateRemoteInformationTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class EstimateremoteInformationOnetask: SetConfigurations {
    var arguments: [String]?
    // Process termination and filehandler closures
    var processtermination: ([String]?) -> Void
    // var filehandler: () -> Void
    weak var setprocessDelegate: SendOutputProcessreference?
    var outputprocess: OutputfromProcess?

    @MainActor
    func startestimation() async {
        if let arguments = arguments {
            let process = RsyncAsync(arguments: arguments,
                                     processtermination: processtermination)
            await process.executeProcess()
            // setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
        }
    }

    init(index: Int,
         // outputprocess: OutputfromProcess?,
         local: Bool,
         processtermination: @escaping ([String]?) -> Void)
    // filehandler: @escaping () -> Void)
    {
        setprocessDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        // self.outputprocess = outputprocess
        self.processtermination = processtermination
        // self.filehandler = filehandler
        if let hiddenID = configurations?.gethiddenID(index: index) {
            if local {
                arguments = configurations?.arguments4rsync(hiddenID: hiddenID, argtype: .argdryRunlocalcataloginfo)
            } else {
                arguments = configurations?.arguments4rsync(hiddenID: hiddenID, argtype: .argdryRun)
            }
        }
    }
}
