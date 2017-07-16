//
//  RsyncCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class CommandCopyFiles: processCmd {

     init (command: String?, arguments: Array<String>?) {
        super.init(command: command, arguments: arguments, aScheduledOperation: false)
        // Process is inated from CopyFiles
        // ProcessTermination()
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllerCopyFiles as? ViewControllerCopyFiles {
            self.delegate_update = pvc
        }
        // Just for using another appending output function
        self.copyfiles = true
    }

}
