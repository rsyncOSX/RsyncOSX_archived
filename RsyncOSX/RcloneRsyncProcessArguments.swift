//
//  RcloneRsyncProcessArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation
class RcloneRsyncProcessArguments {

    private var arguments: [String]?
    var localCatalog: String?
    var offsiteCatalog: String?
    var offsiteUsername: String?
    var offsiteServer: String?
    var remoteargs: String?

    // Brute force, check every parameter, not special elegant, but it works
    private func rclonecommand(_ config: ConfigurationRclone) {
        if config.parameter1 != nil {
            self.appendParameter(parameter: config.parameter1!)
        }
    }

    private func setParameters2To14(_ config: ConfigurationRclone) {
        if config.parameter2 != nil {
            self.appendParameter(parameter: config.parameter2!)
        }
        if config.parameter3 != nil {
            self.appendParameter(parameter: config.parameter3!)
        }
        if config.parameter4 != nil {
            self.appendParameter(parameter: config.parameter4!)
        }
        if config.parameter5 != nil {
            self.appendParameter(parameter: config.parameter5!)
        }
        if config.parameter6 != nil {
            self.appendParameter(parameter: config.parameter6!)
        }
        if config.parameter8 != nil {
            self.appendParameter(parameter: config.parameter8!)
        }
        if config.parameter9 != nil {
            self.appendParameter(parameter: config.parameter9!)
        }
        if config.parameter10 != nil {
            self.appendParameter(parameter: config.parameter10!)
        }
        if config.parameter11 != nil {
            self.appendParameter(parameter: config.parameter11!)
        }
        if config.parameter12 != nil {
            self.appendParameter(parameter: config.parameter12!)
        }
        if config.parameter13 != nil {
            self.appendParameter(parameter: config.parameter13!)
        }
        if config.parameter14 != nil {
            self.appendParameter(parameter: config.parameter14!)
        }
    }

    private func dryrunparameter(_ config: ConfigurationRclone, forDisplay: Bool) {
        let dryrun: String = config.dryrun
        self.arguments!.append(dryrun)
        if forDisplay {self.arguments!.append(" ")}
    }

    private func appendParameter (parameter: String) {
        if parameter.count > 1 {
            self.arguments!.append(parameter)
        }
    }

    /// Function for initialize arguments array. RsyncOSX computes four argumentstrings
    /// two arguments for dryrun, one for rsync and one for display
    /// two arguments for realrun, one for rsync and one for display
    /// which argument to compute is set in parameter to function
    /// - parameter config: structure (configuration) holding configuration for one task
    /// - parameter dryRun: true if compute dryrun arguments, false if compute arguments for real run
    /// - paramater forDisplay: true if for display, false if not
    /// - returns: Array of Strings
    func argumentsRsync(_ config: ConfigurationRclone) -> [String] {
        self.localCatalog = config.localCatalog
        self.offsiteCatalog = config.offsiteCatalog
        self.offsiteServer = config.offsiteServer
        if self.offsiteServer!.isEmpty == false {
            self.remoteargs = self.offsiteServer! + ":" + self.offsiteCatalog!
        }
        self.rclonecommand(config)
        self.arguments!.append(self.localCatalog!)
        if self.offsiteServer!.isEmpty {
            self.arguments!.append(self.offsiteCatalog!)
        } else {
            self.arguments!.append(remoteargs!)
        }
        self.setParameters2To14(config)
        return self.arguments!
    }

    init () {
        self.arguments = nil
        self.arguments = [String]()
    }
}
