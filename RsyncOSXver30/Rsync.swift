//
//  Rsync.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class Rsync: processCmd {
    
    init (arguments:Array<String>?) {
        
        super.init()
        // Set command to execute, if nil picks up command from config
        self.command = nil
        // Set arguments array
        self.arguments = arguments
        // Defaults to not a Scheduled task
        self.aScheduledOperation = false
        
        // Process is inated from Main
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
            self.delegate_update = pvc
        }
    }
    
}

