//
//  sshprocessCmd.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class commandSsh: processCmd {
    
    init (command:String?, arguments:Array<String>?) {
        super.init()
        // Set command to execute, either ssh or scp
        if let cmd = command {
            self.command = cmd
        } else {
            // Set command to execute, if nil picks up command from config
            self.command = nil
        }
        
        self.arguments = arguments
        // Not a scheduled operation
        self.aScheduledOperation = false
        // Process is initated from Ssh
        // ProcessTermination()
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllerSsh as? ViewControllerSsh {
            self.delegate_update = pvc
        }
    }
    
}
