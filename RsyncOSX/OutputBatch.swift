//
//  Batchoutput.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar

import Foundation

final class OutputBatch {

    var output: Array<String>?

    func getOutputCount () -> Int {
        guard self.output != nil else {
            return 0
        }
        return self.output!.count
    }

    func getOutput () -> Array<String> {
        guard self.output != nil else {
            return [""]
        }
        return self.output!
    }

    // Add line to output
    func addLine (str: String) {
        // Create array if == nil
        if self.output == nil {
            self.output = Array<String>()
        }
        self.output!.append(str)
    }

    init() {
        self.output = nil
        self.output = Array<String>()
    }

}
