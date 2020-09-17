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
    init(index: Int,
         outputprocess: OutputProcess?,
         local: Bool,
         processtermination: @escaping () -> Void,
         filehandler: @escaping () -> Void)
    {
        weak var setprocessDelegate: SendOutputProcessreference?
        setprocessDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if local {
            self.arguments = self.configurations?.arguments4rsync(index: index, argtype: .argdryRunlocalcataloginfo)
        } else {
            self.arguments = self.configurations?.arguments4rsync(index: index, argtype: .argdryRun)
        }
        let process = RsyncProcessCmdClosure(arguments: self.arguments,
                                             config: nil,
                                             processtermination: processtermination,
                                             filehandler: filehandler)
        process.executeProcess(outputprocess: outputprocess)
        setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
    }
}
