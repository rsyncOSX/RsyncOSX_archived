//
//  OutputErrors.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/07/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class OutputErrors: OutputBatch {

    override func addLine(str: String) {
        let currendate = Date()
        let dateformatter = Dateandtime().setDateformat()
        let date = dateformatter.string(from: currendate)
        // Create array if == nil
        if self.output == nil {
            self.output = [String]()
        }
        self.output!.append(date + ": " + str)
    }
    override init() {
        super.init()
    }
}
