//
//  RsyncCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

final class CommandCopyFiles: ProcessCmd {
     init (command: String?, arguments: Array<String>?) {
        super.init(command: command, arguments: arguments, aScheduledOperation: false)
        // Process is inated from CopyFiles
        // ProcessTermination()
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .viewcontrollercopyfiles)
            as? ViewControllerCopyFiles
        // Just for using another appending output function
        self.copyfiles = true
    }
}
