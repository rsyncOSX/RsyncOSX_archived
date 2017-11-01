//
//  rsyncProcessArguments.swift
//  Rsync
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

class RsyncProcessArguments {

    private var stats: Bool?
    private var arguments: Array<String>?
    var localCatalog: String?
    var offsiteCatalog: String?
    var offsiteUsername: String?
    var offsiteServer: String?
    var remoteargs: String?

    // Set initial parameter1 .. paramater6, parameters are computed by RsyncOSX

    private func setParameters1To6(_ config: Configuration, dryRun: Bool, forDisplay: Bool) {
        let parameter1: String = config.parameter1
        let parameter2: String = config.parameter2
        let parameter3: String = config.parameter3
        let parameter4: String = config.parameter4
        let offsiteServer: String = config.offsiteServer
        self.arguments!.append(parameter1)
        if forDisplay {self.arguments!.append(" ")}
        self.arguments!.append(parameter2)
        if forDisplay {self.arguments!.append(" ")}
        if offsiteServer.isEmpty {
            // nothing
        } else {
            self.arguments!.append(parameter3)
            if forDisplay {self.arguments!.append(" ")}
        }
        self.arguments!.append(parameter4)
        if forDisplay {self.arguments!.append(" ")}
        if offsiteServer.isEmpty {
            // nothing
        } else {
            self.sshportparameter(config, forDisplay: forDisplay)
        }
    }

    private func sshportparameter(_ config: Configuration, forDisplay: Bool) {
        let parameter5: String = config.parameter5
        let parameter6: String = config.parameter6
        // -e
        self.arguments!.append(parameter5)
        if forDisplay {self.arguments!.append(" ")}
        if let sshport = config.sshport {
            // "ssh -p xxx"
            if forDisplay {self.arguments!.append(" \"")}
            self.arguments!.append("ssh -p " + String(sshport))
            if forDisplay {self.arguments!.append("\" ")}
        } else {
            // ssh
            self.arguments!.append(parameter6)
        }
        if forDisplay {self.arguments!.append(" ")}
    }

    // Compute user selected parameters parameter8 ... parameter14
    // Brute force, check every parameter, not special elegant, but it works

    private func setParameters8To14(_ config: Configuration, dryRun: Bool, forDisplay: Bool) {
        self.stats = false
        if config.parameter8 != nil {
            self.appendParameter(parameter: config.parameter8!, forDisplay: forDisplay)
        }
        if config.parameter9 != nil {
            self.appendParameter(parameter: config.parameter9!, forDisplay: forDisplay)
        }
        if config.parameter10 != nil {
            self.appendParameter(parameter: config.parameter10!, forDisplay: forDisplay)
        }
        if config.parameter11 != nil {
            self.appendParameter(parameter: config.parameter11!, forDisplay: forDisplay)
        }
        if config.parameter12 != nil {
            self.appendParameter(parameter: config.parameter12!, forDisplay: forDisplay)
        }
        if config.parameter13 != nil {
            self.appendParameter(parameter: config.parameter13!, forDisplay: forDisplay)
        }
        if config.parameter14 != nil {
            self.appendParameter(parameter: config.parameter14!, forDisplay: forDisplay)
        }
        // Append --stats parameter to collect info about run
        if dryRun {
            self.dryrunparameter(config, forDisplay: forDisplay)
        } else {
            if self.stats == false {
                self.appendParameter(parameter: "--stats", forDisplay: forDisplay)
            }
        }
    }

    private func dryrunparameter(_ config: Configuration, forDisplay: Bool) {
        let dryrun: String = config.dryrun
        self.arguments!.append(dryrun)
        if forDisplay {self.arguments!.append(" ")}
        if self.stats! == false {
            self.arguments!.append("--stats")
            if forDisplay {self.arguments!.append(" ")}
        }
    }

    // Check userselected parameter and append it
    // to arguments array passed to rsync or displayed
    // on screen.

    private func appendParameter (parameter: String, forDisplay: Bool) {
        if parameter.count > 1 {
            if parameter == "--stats" {
                self.stats = true
            }
            self.arguments!.append(parameter)
            if forDisplay {
                self.arguments!.append(" ")
            }
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
    func argumentsRsync (_ config: Configuration, dryRun: Bool, forDisplay: Bool) -> Array<String> {
        self.localCatalog = config.localCatalog
        self.offsiteCatalog = config.offsiteCatalog
        self.offsiteUsername = config.offsiteUsername
        self.offsiteServer = config.offsiteServer
        if self.offsiteServer!.isEmpty == false {
            if config.rsyncdaemon != nil {
                if config.rsyncdaemon == 1 {
                    self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + "::" + self.offsiteCatalog!
                } else {
                    self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + ":" + self.offsiteCatalog!
                }
            } else {
                self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + ":" + self.offsiteCatalog!
            }
        }
        self.setParameters1To6(config, dryRun: dryRun, forDisplay: forDisplay)
        self.setParameters8To14(config, dryRun: dryRun, forDisplay: forDisplay)
        switch config.task {
        case "backup":
            self.argumentsforbackup(dryRun: dryRun, forDisplay: forDisplay)
        case "restore":
            self.argumentsforrestore(dryRun: dryRun, forDisplay: forDisplay)
        default:
            break
        }
        return self.arguments!
    }

    private func argumentsforbackup(dryRun: Bool, forDisplay: Bool) {
        // Backup
        self.arguments!.append(self.localCatalog!)
        if self.offsiteServer!.isEmpty {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(self.offsiteCatalog!)
            if forDisplay {self.arguments!.append(" ")}
        } else {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(remoteargs!)
            if forDisplay {self.arguments!.append(" ")}
        }
    }

    private func argumentsforrestore(dryRun: Bool, forDisplay: Bool) {
        if self.offsiteServer!.isEmpty {
            self.arguments!.append(self.offsiteCatalog!)
            if forDisplay {self.arguments!.append(" ")}
        } else {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(remoteargs!)
            if forDisplay {self.arguments!.append(" ")}
        }
        self.arguments!.append(self.localCatalog!)
    }

    init () {
        self.arguments = nil
        self.arguments = Array<String>()
    }
}
