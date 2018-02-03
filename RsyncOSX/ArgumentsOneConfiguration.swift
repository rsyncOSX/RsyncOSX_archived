//
//  ArgumentsOneConfiguration.swift
//
//  Created by Thomas Evensen on 09/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Struct for to store info for ONE configuration.
// Struct is storing rsync arguments for real run, dryrun
// and a version to show in view of both

struct ArgumentsOneConfiguration {

    var config: Configuration?
    var arg: [String]?
    var argdryRun: [String]?
    var argDisplay: [String]?
    var argdryRunDisplay: [String]?

    init(config: Configuration) {
        // The configuration
        self.config = config
        // All arguments for rsync is computed, two sets. One for dry-run and one for real run.
        // the parameter forDisplay = true computes arguments to display in view.
        self.arg = RsyncParametersProcess().argumentsRsync(config, dryRun: false, forDisplay: false)
        self.argDisplay = RsyncParametersProcess().argumentsRsync(config, dryRun: false, forDisplay: true)
        self.argdryRun = RsyncParametersProcess().argumentsRsync(config, dryRun: true, forDisplay: false)
        self.argdryRunDisplay = RsyncParametersProcess().argumentsRsync(config, dryRun: true, forDisplay: true)
    }
}
