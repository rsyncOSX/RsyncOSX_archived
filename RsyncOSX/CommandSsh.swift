//
//  sshprocessCmd.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

final class CommandSsh: ProcessCmd {

    init (command: String?, arguments: Array<String>?) {
        super.init(command: command, arguments: arguments, aScheduledOperation: false)
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
    }

}
