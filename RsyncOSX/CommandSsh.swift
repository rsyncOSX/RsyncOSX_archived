//
//  sshprocessCmd.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class CommandSsh: ProcessCmd {

    init (command: String?, arguments: Array<String>?) {
        super.init(command: command, arguments: arguments, aScheduledOperation: false)
        // Process is initated from Ssh
        // ProcessTermination()
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllerSsh as? ViewControllerSsh {
            self.updateDelegate = pvc
        }
    }

}
