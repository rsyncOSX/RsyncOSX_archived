//
//  RsyncVersion.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class RsyncVersion: ProcessCmd {

    var outputprocess: OutputProcess?
    var versionstring: String?

    init () {
        super.init(command: nil, arguments: ["--version"])
        self.updateDelegate = self
        self.outputprocess = OutputProcess()
        self.executeProcess(outputprocess: self.outputprocess)
    }
}

extension RsyncVersion: UpdateProgress {
    func processTermination() {
        print(self.outputprocess!.getOutput()!.joined(separator: "\n"))
    }

    func fileHandler() {
        //
    }

}
