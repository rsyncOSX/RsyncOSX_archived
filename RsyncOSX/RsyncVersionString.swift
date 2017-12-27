//
//  RsyncVersionString.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class RsyncVersionString: ProcessCmd {

    init () {
        super.init(command: nil, arguments: ["--version"])
        var outputprocess = OutputProcess()
        if ViewControllerReference.shared.norsync == false {
            self.updateDelegate = nil
            self.executeProcess(outputprocess: outputprocess)
            self.delayWithSeconds(0.25) {
                ViewControllerReference.shared.rsyncversionstring = outputprocess.getOutput()!.joined(separator: "\n")
            }
        }
    }
}
