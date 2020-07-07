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
    init(index: Int, outputprocess: OutputProcess?, local: Bool, updateprogress: UpdateProgress) {
        weak var setprocessDelegate: SendProcessreference?
        setprocessDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if local {
            self.arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRunlocalcataloginfo)
        } else {
            self.arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRun)
        }
        let process = Rsync(arguments: self.arguments)
        process.setdelegate(object: updateprogress)
        process.executeProcess(outputprocess: outputprocess)
        setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
    }
}
