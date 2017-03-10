//
//  RsyncCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class commandCopyFiles: processCmd {
    
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
        // Defaults to not a Scheduled task
        self.aScheduledOperation = false
        
        // Process is inated from CopyFiles
        if let pvc = SharingManagerConfiguration.sharedInstance.CopyObjectMain as? ViewControllerCopyFiles {
            self.delegate_update = pvc
        }
    }
    
}

