//
//  argumentsConfigurations.swift
//
//  Created by Thomas Evensen on 09/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Struct for to store info for ONE configuration.
// Struct is storing rsync arguments for real run, dryrun 
// and a version to show in view of both
struct ArgumentsOneConfig {
   
    var config:configuration?
    var arg:Array<String>?
    var argdryRun:Array<String>?
    var argDisplay:Array<String>?
    var argdryRunDisplay:Array<String>?
    
    init(config:configuration) {
        self.config = config
    }
}

// Struct is calculating parameters for all jobs based upon the 
// stored configuration.

struct ArgumentsAllConfigurations {
    // Record to store all arguments for rsync
    // Arguments are prepared during startup
    var rsyncArguments: ArgumentsOneConfig?
    // Object for preparing rsync arguments
    init(rsyncArguments: ArgumentsOneConfig) {
        self.rsyncArguments = rsyncArguments
        self.rsyncArguments!.arg = rsyncProcessArguments().argumentsRsync(rsyncArguments.config!, dryRun: false, forDisplay: false)
        self.rsyncArguments!.argDisplay = rsyncProcessArguments().argumentsRsync(rsyncArguments.config!, dryRun: false, forDisplay: true)
        self.rsyncArguments!.argdryRun = rsyncProcessArguments().argumentsRsync(rsyncArguments.config!, dryRun: true, forDisplay: false)
        self.rsyncArguments!.argdryRunDisplay = rsyncProcessArguments().argumentsRsync(rsyncArguments.config!, dryRun: true, forDisplay: true)
    }
}

