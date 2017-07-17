//
//  RsyncCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//swiftlint:disable syntactic_sugar

import Foundation

final class CommandCopyFiles: ProcessCmd {

     init (command: String?, arguments: Array<String>?) {
        super.init(command: command, arguments: arguments, aScheduledOperation: false)
        // Process is inated from CopyFiles
        // ProcessTermination()
        if let pvc = SharingManagerConfiguration.sharedInstance.viewControllerCopyFiles as? ViewControllerCopyFiles {
            self.updateDelegate = pvc
        }
        // Just for using another appending output function
        self.copyfiles = true
    }

}
