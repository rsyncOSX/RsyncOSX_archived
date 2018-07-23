//
//  ArgumentsOneConfiguration.swift
//
//  Created by Thomas Evensen on 09/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

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
    var argdryRunLocalcatalogInfo: [String]?
    // Restore
    var restore: [String]?
    var restoredryRun: [String]?
    var restoreDisplay: [String]?
    var restoredryRunDisplay: [String]?
    // Temporary restore
    var tmprestore: [String]?
    var tmprestoredryRun: [String]?
    // Verify backup
    var verify: [String]?
    var verifyDisplay: [String]?

    init(config: Configuration) {
        // The configuration
        self.config = config
        // All arguments for rsync is computed, two sets. One for dry-run and one for real run.
        // the parameter forDisplay = true computes arguments to display in view.
        self.arg = RsyncParametersProcess().argumentsRsync(config, dryRun: false, forDisplay: false)
        self.argDisplay = RsyncParametersProcess().argumentsRsync(config, dryRun: false, forDisplay: true)
        self.argdryRun = RsyncParametersProcess().argumentsRsync(config, dryRun: true, forDisplay: false)
        self.argdryRunDisplay = RsyncParametersProcess().argumentsRsync(config, dryRun: true, forDisplay: true)
        self.argdryRunLocalcatalogInfo = RsyncParametersProcess().argumentsRsyncLocalcatalogInfo(config, dryRun: true, forDisplay: false)
        // Restore path
        self.restore = RsyncParametersProcess().argumentsRestore(config, dryRun: false, forDisplay: false, tmprestore: false)
        self.restoredryRun = RsyncParametersProcess().argumentsRestore(config, dryRun: true, forDisplay: false, tmprestore: false)
        self.restoreDisplay = RsyncParametersProcess().argumentsRestore(config, dryRun: false, forDisplay: true, tmprestore: false)
        self.restoredryRunDisplay = RsyncParametersProcess().argumentsRestore(config, dryRun: true, forDisplay: true, tmprestore: false)
        // Temporary restore path
        self.tmprestore = RsyncParametersProcess().argumentsRestore(config, dryRun: false, forDisplay: false, tmprestore: true)
        self.tmprestoredryRun = RsyncParametersProcess().argumentsRestore(config, dryRun: true, forDisplay: false, tmprestore: true)
        // Verify
        self.verify = RsyncParametersProcess().argumentsVerify(config, forDisplay: false)
        self.verifyDisplay = RsyncParametersProcess().argumentsVerify(config, forDisplay: true)
    }
}
