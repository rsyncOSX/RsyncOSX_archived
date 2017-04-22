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
    private var arguments:Array<String>?
    
    // Set initial parameter1 .. paramater6
    // Parameters is computed by RsyncOSX
    
    private func setParameters1ToParameters6(_ config : configuration, dryRun : Bool, forDisplay : Bool) {
        
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
    
    private func setParameters8ToParameters14(_ config : configuration, dryRun : Bool, forDisplay : Bool) {
        
        let dryrun: String = config.dryrun
        self.stats = false
        
        if (config.parameter8 != nil) {
            self.appendParameter(parameter: config.parameter8!, forDisplay: forDisplay)
        }
        if (config.parameter9 != nil) {
            self.appendParameter(parameter: config.parameter9!, forDisplay: forDisplay)
        }
        if (config.parameter10 != nil) {
            self.appendParameter(parameter: config.parameter10!, forDisplay: forDisplay)
        }
        if (config.parameter11 != nil) {
            self.appendParameter(parameter: config.parameter11!, forDisplay: forDisplay)
        }
        if (config.parameter12 != nil) {
            self.appendParameter(parameter: config.parameter12!, forDisplay: forDisplay)
        }
        if (config.parameter13 != nil) {
            self.appendParameter(parameter: config.parameter13!, forDisplay: forDisplay)
        }
        if (config.parameter14 != nil) {
            self.appendParameter(parameter: config.parameter14!, forDisplay: forDisplay)
        }
        // If drynrun append --stats parameter to collect info about run
        if (dryRun) {
            self.arguments!.append(dryrun)
            if (forDisplay) {self.arguments!.append(" ")}
            if (self.stats! == false) {
                self.arguments!.append("--stats")
                if (forDisplay) {self.arguments!.append(" ")}
            }
        }
    }
    
    // Check userselected parameter and append it
    // to arguments array passed to rsync or displayed
    // on screen.
    
    private func appendParameter (parameter:String, forDisplay : Bool) {
        if ((parameter.characters.count) > 1) {
            if parameter == "--stats" {self.stats = true}
            self.arguments!.append(parameter)
            if (forDisplay) {
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
            self.setParameters1ToParameters6(config, dryRun: dryRun, forDisplay: forDisplay)
            self.setParameters8ToParameters14(config, dryRun: dryRun, forDisplay: forDisplay)
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
            self.setParameters1ToParameters6(config, dryRun: dryRun, forDisplay: forDisplay)
            self.setParameters8ToParameters14(config, dryRun: dryRun, forDisplay: forDisplay)
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
