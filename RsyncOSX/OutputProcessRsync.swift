//
//  OutputProcessRsync.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10/05/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class OutputProcessRsync: OutputProcess {
    override func addlinefromoutput(str: String) {
        if self.startindex == nil {
            self.startindex = 0
        } else {
            self.startindex = self.output?.count ?? 0 + 1
        }
        str.enumerateLines { line, _ in
            guard line.hasSuffix("/") == false else { return }
            self.output?.append(line)
        }
    }

    override init() {
        super.init()
    }
}
