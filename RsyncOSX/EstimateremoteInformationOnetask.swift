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
    var outputprocess: OutputProcess?

    func startestimation() {
        if let arguments = self.arguments {
            let process = RsyncProcessCmdClosure(arguments: arguments,
                                                 config: nil,
                                                 processtermination: processtermination,
                                                 filehandler: filehandler)
            process.executeProcess(outputprocess: outputprocess)
            setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
        }
    }

    init(index: Int,
         outputprocess: OutputProcess?,
         local: Bool,
         processtermination: @escaping () -> Void,
         filehandler: @escaping () -> Void)
    {
        self.setprocessDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.outputprocess = outputprocess
        self.processtermination = processtermination
        self.filehandler = filehandler
        if local {
            self.arguments = self.configurations?.arguments4rsync(index: index, argtype: .argdryRunlocalcataloginfo)
        } else {
            self.arguments = self.configurations?.arguments4rsync(index: index, argtype: .argdryRun)
        }
    }
}
