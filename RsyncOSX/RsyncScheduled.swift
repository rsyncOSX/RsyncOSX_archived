//
//  RsyncScheduled.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

import Foundation

final class RsyncScheduled: ProcessCmd {
    init (arguments: Array<String>?) {
        super.init(command: nil, arguments: arguments, aScheduledOperation: true)
        self.updateDelegate = nil
    }
}
