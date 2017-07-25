//
//  ArgumentsOneConfiguration.swift
//
//  Created by Thomas Evensen on 09/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint OK - 17 July 2017
//  swiftlint:disable syntactic_sugar disable

import Foundation

// Struct for to store info for ONE configuration.
// Struct is storing rsync arguments for real run, dryrun
// and a version to show in view of both

struct ArgumentsOneConfiguration {

    var config: Configuration?
    var arg: Array<String>?
    var argdryRun: Array<String>?
    var argDisplay: Array<String>?
    var argdryRunDisplay: Array<String>?

    init(config: Configuration) {
        // The configuration
        self.config = config
        // All arguments for rsync is computed, two sets. One for dry-run and one for real run.
        // the parameter forDisplay = true computes arguments to display in view.
        self.arg = RsyncProcessArguments().argumentsRsync(config, dryRun: false, forDisplay: false)
        self.argDisplay = RsyncProcessArguments().argumentsRsync(config, dryRun: false, forDisplay: true)
        self.argdryRun = RsyncProcessArguments().argumentsRsync(config, dryRun: true, forDisplay: false)
        self.argdryRunDisplay = RsyncProcessArguments().argumentsRsync(config, dryRun: true, forDisplay: true)
    }
}
