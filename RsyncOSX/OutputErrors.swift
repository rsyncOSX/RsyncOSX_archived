//
//  OutputErrors.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/07/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class OutputErrors {

    var output: [String]?

    func getOutput () -> [String]? {
        return self.output
    }

    func addLine(str: String) {
        let currendate = Date()
        let dateformatter = Dateandtime().setDateformat()
        let date = dateformatter.string(from: currendate)
        self.output!.append(date + ": " + str)
    }

    init() {
         self.output = [String]()
    }
}
