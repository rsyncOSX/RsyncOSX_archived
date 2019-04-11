//
//  OperationFactory.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

protocol SendProcessreference: class {
    func sendprocessreference(process: Process?)
    func sendoutputprocessreference(outputprocess: OutputProcess?)
}

class OperationFactory {
    init() {
        _ = QuickbackupDispatch()
    }
}
