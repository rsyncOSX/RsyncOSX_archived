//
//  EstimateRemoteInformationTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class EstimateRemoteInformationTask: SetConfigurations {

    init(index: Int, outputprocess: OutputProcess?) {
        let arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRun)
        let process = Rsync(arguments: arguments)
        process.executeProcess(outputprocess: outputprocess)
    }
}
