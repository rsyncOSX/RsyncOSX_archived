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
    var processtermination: () -> Void
    var filehandler: () -> Void
    weak var setprocessDelegate: SendOutputProcessreference?
    var outputprocess: OutputfromProcess?

    func startestimation() {
        if let arguments = arguments {
            let process = RsyncProcess(arguments: arguments,
                                       config: nil,
                                       processtermination: processtermination,
                                       filehandler: filehandler)
            process.executeProcess(outputprocess: outputprocess)
            setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
        }
    }

    init(index: Int,
         outputprocess: OutputfromProcess?,
         local: Bool,
         processtermination: @escaping () -> Void,
         filehandler: @escaping () -> Void)
    {
        setprocessDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.outputprocess = outputprocess
        self.processtermination = processtermination
        self.filehandler = filehandler
        if let hiddenID = configurations?.gethiddenID(index: index) {
            if local {
                arguments = configurations?.arguments4rsync(hiddenID: hiddenID, argtype: .argdryRunlocalcataloginfo)
            } else {
                arguments = configurations?.arguments4rsync(hiddenID: hiddenID, argtype: .argdryRun)
            }
        }
    }
}
