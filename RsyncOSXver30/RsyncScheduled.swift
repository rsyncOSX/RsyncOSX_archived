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
        // Set command to execute
        self.command = nil
        // Set arguments array
        self.arguments = arguments
        // Defaults to not a Scheduled task
        self.aScheduledOperation = true
        // A scheduled Process
        self.delegate_update = nil
    }
    
}
