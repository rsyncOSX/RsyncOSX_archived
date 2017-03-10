//
//  RsyncScheduled.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

import Foundation

final class RsyncScheduled: processCmd {
    
    init (arguments:Array<String>?) {
        
        super.init()
        // Set command to execute, if nil picks up command from config
        self.command = nil
        // Set arguments array
        self.arguments = arguments
        // Defaults to not a Scheduled task
        self.aScheduledOperation = true
        // A scheduled Process, no need for upadates in view
        self.delegate_update = nil
    }
    
}
