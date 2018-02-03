//
//  Batchoutput.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class OutputBatch {

    var output: [String]?

    func getOutputCount () -> Int {
        return self.output?.count ?? 0
    }

    func getOutput () -> [String] {
        return self.output ?? [""]
    }

    // Add line to output
    func addLine (str: String) {
        // Create array if == nil
        if self.output == nil {
            self.output = [String]()
        }
        self.output!.append(str)
    }

    init() {
        self.output = nil
        self.output = [String]()
    }

}
