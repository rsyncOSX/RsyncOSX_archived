//
//  InterruptProcess.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/06/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct InterruptProcess {
    init(process: Process?) {
        guard process != nil else { return }
        let output = OutputProcess()
        let string = "Interrupted: " + Date().long_localized_string_from_date()
        output.addlinefromoutput(str: string)
        _ = Logging(output, true)
        process?.interrupt()
    }

    init(process: Process?, output: OutputProcess?) {
        guard process != nil, output != nil else { return }
        _ = Logging(output, true)
        process?.interrupt()
    }
}
