//
//  Batchoutput.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

final class OutputBatch {

    var output: Array<String>?

    func getOutputCount () -> Int {
        return self.output?.count ?? 0
    }

    func getOutput () -> Array<String> {
        return self.output ?? [""]
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
