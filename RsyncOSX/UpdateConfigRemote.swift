//
//  UpdateConfigRemote.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03.08.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar

import Foundation

final class UpdateConfigRemote: ProcessCmd {
    init (command: String?, arguments: Array<String>?) {
        super.init(command: command, arguments: arguments, aScheduledOperation: false)
    }
}
