//
//  rsyncNSTaskArguments.swift
//  Rsync
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class rsyncProcessArguments {
    
        
    func argumentsRsync (_ config : configuration, dryRun : Bool, forDisplay : Bool) -> [String] {
        
        var arguments = [String]()
        
        let task: String = config.task
        let localCatalog: String = config.localCatalog
        let offsiteCatalog: String = config.offsiteCatalog
        let offsiteUsername: String = config.offsiteUsername
        let dryrun: String = config.dryrun
        
        let parameter1: String = config.parameter1
        let parameter2: String = config.parameter2
        let parameter3: String = config.parameter3
        let parameter4: String = config.parameter4
        let parameter5: String = config.parameter5
        let parameter6: String = config.parameter6
        let offsiteServer: String = config.offsiteServer
        var offsiteArguments: String?
        if (offsiteServer.isEmpty) {
            // nothing
        } else {
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
        
        switch task {
        case "backup":
            arguments.append(parameter1)
            if (forDisplay) {arguments.append(" ")}
            arguments.append(parameter2)
            if (forDisplay) {arguments.append(" ")}
            if (offsiteServer.isEmpty) {
                // nothing
            } else {
                arguments.append(parameter3)
                if (forDisplay) {arguments.append(" ")}
            }
            arguments.append(parameter4)
            if (forDisplay) {arguments.append(" ")}
            if (offsiteServer.isEmpty) {
                // nothing
            } else {
                // -e
                arguments.append(parameter5)
                if (forDisplay) {arguments.append(" ")}
                if let sshport = config.sshport {
                    // "ssh -p xxx"
                    if (forDisplay) {arguments.append(" \"")}
                    arguments.append("ssh -p " + String(sshport))
                    if (forDisplay) {arguments.append("\" ")}
                } else {
                    // ssh
                    arguments.append(parameter6)
                }
                if (forDisplay) {arguments.append(" ")}
            }
            
            // insert any other userselected parameters at this point
            // parameter8 ... parameter14
            // Brute force, check every parameter
            
            if (config.parameter8 != nil) {
                if ((config.parameter8?.characters.count)! > 1) {
                    arguments.append(config.parameter8!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter9 != nil) {
                if ((config.parameter9?.characters.count)! > 1) {
                    arguments.append(config.parameter9!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter10 != nil) {
                if ((config.parameter10?.characters.count)! > 1) {
                    arguments.append(config.parameter10!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter11 != nil) {
                if ((config.parameter11?.characters.count)! > 1) {
                    arguments.append(config.parameter11!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter12 != nil) {
                if ((config.parameter12?.characters.count)! > 1) {
                    arguments.append(config.parameter12!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter13 != nil) {
                if ((config.parameter13?.characters.count)! > 1) {
                    arguments.append(config.parameter13!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter14 != nil) {
                if ((config.parameter14?.characters.count)! > 1) {
                    arguments.append(config.parameter14!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (dryRun) {
                arguments.append(dryrun)
                if (forDisplay) {arguments.append(" ")}
            }
            arguments.append(localCatalog)
            if (offsiteServer.isEmpty) {
                if (forDisplay) {arguments.append(" ")}
                arguments.append(offsiteCatalog)
                if (forDisplay) {arguments.append(" ")}
            } else {
                if (forDisplay) {arguments.append(" ")}
                arguments.append(offsiteArguments!)
                if (forDisplay) {arguments.append(" ")}
            }
        case "restore":
            arguments.append(parameter1)
            if (forDisplay) {arguments.append(" ")}
            arguments.append(parameter2)
            if (forDisplay) {arguments.append(" ")}
            if (offsiteServer.isEmpty) {
                // nothing
            } else {
                arguments.append(parameter3)
                if (forDisplay) {arguments.append(" ")}
            }
            arguments.append(parameter4)
            if (forDisplay) {arguments.append(" ")}
            if (offsiteServer.isEmpty) {
                // nothing
            } else {
                // -e
                arguments.append(parameter5)
                if (forDisplay) {arguments.append(" ")}
                if let sshport = config.sshport {
                    // "ssh -p xxx"
                    if (forDisplay) {arguments.append(" \"")}
                    arguments.append("ssh -p " + String(sshport))
                    if (forDisplay) {arguments.append("\" ")}
                } else {
                    // ssh
                    arguments.append(parameter6)
                }
                if (forDisplay) {arguments.append(" ")}
            }
            
            // insert any other userselected parameters at this point
            // parameter8 ... parameter14
            // Brute force...
            
            if (config.parameter8 != nil) {
                if ((config.parameter8?.characters.count)! > 1) {
                    arguments.append(config.parameter8!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter9 != nil) {
                if ((config.parameter9?.characters.count)! > 1) {
                    arguments.append(config.parameter9!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter10 != nil) {
                if ((config.parameter10?.characters.count)! > 1) {
                    arguments.append(config.parameter10!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter11 != nil) {
                if ((config.parameter11?.characters.count)! > 1) {
                    arguments.append(config.parameter11!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter12 != nil) {
                if ((config.parameter12?.characters.count)! > 1) {
                    arguments.append(config.parameter12!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter13 != nil) {
                if ((config.parameter13?.characters.count)! > 1) {
                    arguments.append(config.parameter13!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }
            if (config.parameter14 != nil) {
                if ((config.parameter14?.characters.count)! > 1) {
                    arguments.append(config.parameter14!)
                    if (forDisplay) {arguments.append(" ")}
                }
            }

            if (dryRun) {
                arguments.append(dryrun)
                if (forDisplay) {arguments.append(" ")}
            }
            if (offsiteServer.isEmpty) {
                arguments.append(offsiteCatalog)
                if (forDisplay) {arguments.append(" ")}
            } else {
                if (forDisplay) {arguments.append(" ")}
                arguments.append(offsiteArguments!)
                if (forDisplay) {arguments.append(" ")}
            }
            arguments.append(localCatalog)
        default:
            break
        }
        return arguments
    }
}
