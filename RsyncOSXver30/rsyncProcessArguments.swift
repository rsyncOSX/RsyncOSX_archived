//
//  rsyncProcessArguments.swift
//  Rsync
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class rsyncProcessArguments {
    
    // If true one of the userselecet params are --stats
    // If not add --stats in dryrun arguments.
    // Must check all parameter8 - paramater14
    // both backup and restore part
    private var stats:Bool?
    private var arguments:[String]?
    
    // Set initial parameter1 .. paramater6
    // Parameters is computed by RsyncOSX
    
    private func setInitialParameters(_ config : configuration, dryRun : Bool, forDisplay : Bool) {
        
        let parameter1: String = config.parameter1
        let parameter2: String = config.parameter2
        let parameter3: String = config.parameter3
        let parameter4: String = config.parameter4
        let parameter5: String = config.parameter5
        let parameter6: String = config.parameter6
        let offsiteServer: String = config.offsiteServer
        
        self.arguments!.append(parameter1)
        if (forDisplay) {self.arguments!.append(" ")}
        self.arguments!.append(parameter2)
        if (forDisplay) {self.arguments!.append(" ")}
        if (offsiteServer.isEmpty) {
            // nothing
        } else {
            self.arguments!.append(parameter3)
            if (forDisplay) {self.arguments!.append(" ")}
        }
        self.arguments!.append(parameter4)
        if (forDisplay) {self.arguments!.append(" ")}
        if (offsiteServer.isEmpty) {
            // nothing
        } else {
            // -e
            self.arguments!.append(parameter5)
            if (forDisplay) {self.arguments!.append(" ")}
            if let sshport = config.sshport {
                // "ssh -p xxx"
                if (forDisplay) {self.arguments!.append(" \"")}
                self.arguments!.append("ssh -p " + String(sshport))
                if (forDisplay) {self.arguments!.append("\" ")}
            } else {
                // ssh
                self.arguments!.append(parameter6)
            }
            if (forDisplay) {self.arguments!.append(" ")}
        }
    }
    
    
    // Compute user selected parameters parameter8 ... parameter14
    // Brute force, check every parameter
    // Not special elegant, but it works
    
    private func setUserSelectedParameters(_ config : configuration, dryRun : Bool, forDisplay : Bool) {
        
        let dryrun: String = config.dryrun
        self.stats = false
        
        if (config.parameter8 != nil) {
            if ((config.parameter8?.characters.count)! > 1) {
                if config.parameter8! == "--stats" {self.stats = true}
                self.arguments!.append(config.parameter8!)
                if (forDisplay) {self.arguments!.append(" ")}
            }
        }
        if (config.parameter9 != nil) {
            if ((config.parameter9?.characters.count)! > 1) {
                if config.parameter9! == "--stats" {self.stats = true}
                self.arguments!.append(config.parameter9!)
                if (forDisplay) {self.arguments!.append(" ")}
            }
        }
        if (config.parameter10 != nil) {
            if ((config.parameter10?.characters.count)! > 1) {
                if config.parameter10! == "--stats" {self.stats = true}
                self.arguments!.append(config.parameter10!)
                if (forDisplay) {self.arguments!.append(" ")}
            }
        }
        if (config.parameter11 != nil) {
            if ((config.parameter11?.characters.count)! > 1) {
                if config.parameter11! == "--stats" {self.stats = true}
                self.arguments!.append(config.parameter11!)
                if (forDisplay) {self.arguments!.append(" ")}
            }
        }
        if (config.parameter12 != nil) {
            if ((config.parameter12?.characters.count)! > 1) {
                if config.parameter12! == "--stats" {self.stats = true}
                self.arguments!.append(config.parameter12!)
                if (forDisplay) {self.arguments!.append(" ")}
            }
        }
        if (config.parameter13 != nil) {
            if ((config.parameter13?.characters.count)! > 1) {
                if config.parameter13! == "--stats" {self.stats = true}
                self.arguments!.append(config.parameter13!)
                if (forDisplay) {self.arguments!.append(" ")}
            }
        }
        if (config.parameter14 != nil) {
            if ((config.parameter14?.characters.count)! > 1) {
                if config.parameter14! == "--stats" {self.stats = true}
                self.arguments!.append(config.parameter14!)
                if (forDisplay) {self.arguments!.append(" ")}
            }
        }
        
        if (dryRun) {
            self.arguments!.append(dryrun)
            if (forDisplay) {self.arguments!.append(" ")}
            if (self.stats! == false) {
                self.arguments!.append("--stats")
                if (forDisplay) {self.arguments!.append(" ")}
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
    func argumentsRsync (_ config : configuration, dryRun : Bool, forDisplay : Bool) -> [String] {
        
        let localCatalog: String = config.localCatalog
        let offsiteCatalog: String = config.offsiteCatalog
        let offsiteUsername: String = config.offsiteUsername
        let offsiteServer: String = config.offsiteServer
        
        var offsiteArguments: String?
        if (offsiteServer.isEmpty == false) {
            if (config.rsyncdaemon != nil) {
                if (config.rsyncdaemon == 1) {
                    offsiteArguments = offsiteUsername + "@" + offsiteServer + "::" + offsiteCatalog
                } else {
                    offsiteArguments = offsiteUsername + "@" + offsiteServer + ":" + offsiteCatalog
                }
            } else {
                offsiteArguments = offsiteUsername + "@" + offsiteServer + ":" + offsiteCatalog
            }
        }
        
        switch config.task {
            
        case "backup":
            self.setInitialParameters(config, dryRun: dryRun, forDisplay: forDisplay)
            self.setUserSelectedParameters(config, dryRun: dryRun, forDisplay: forDisplay)
            // Backup
            self.arguments!.append(localCatalog)
            
            if (offsiteServer.isEmpty) {
                if (forDisplay) {self.arguments!.append(" ")}
                self.arguments!.append(offsiteCatalog)
                if (forDisplay) {self.arguments!.append(" ")}
            } else {
                if (forDisplay) {self.arguments!.append(" ")}
                self.arguments!.append(offsiteArguments!)
                if (forDisplay) {self.arguments!.append(" ")}
            }
            
        case "restore":
            
            self.setInitialParameters(config, dryRun: dryRun, forDisplay: forDisplay)
            self.setUserSelectedParameters(config, dryRun: dryRun, forDisplay: forDisplay)
            
            if (offsiteServer.isEmpty) {
                self.arguments!.append(offsiteCatalog)
                if (forDisplay) {self.arguments!.append(" ")}
            } else {
                if (forDisplay) {self.arguments!.append(" ")}
                self.arguments!.append(offsiteArguments!)
                if (forDisplay) {self.arguments!.append(" ")}
            }
            // Restore
            self.arguments!.append(localCatalog)
        default:
            break
        }
        return self.arguments!
    }
    
    init () {
        self.arguments = nil
        self.arguments = Array<String>()
    }
}
