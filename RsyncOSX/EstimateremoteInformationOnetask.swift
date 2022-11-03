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
    var processtermination: ([String]?) -> Void

    @MainActor
    func startestimation() async {
        if let arguments = arguments {
            let process = RsyncAsync(arguments: arguments,
                                     processtermination: processtermination)
            await process.executeProcess()
        }
    }

    init(index: Int,
         local: Bool,
         processtermination: @escaping ([String]?) -> Void)
    {
        self.processtermination = processtermination
        if let hiddenID = configurations?.gethiddenID(index: index) {
            if local {
                arguments = configurations?.arguments4rsync(hiddenID: hiddenID, argtype: .argdryRunlocalcataloginfo)
            } else {
                arguments = configurations?.arguments4rsync(hiddenID: hiddenID, argtype: .argdryRun)
            }
        }
    }
}
