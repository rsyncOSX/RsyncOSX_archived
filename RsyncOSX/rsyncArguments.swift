//
//  rsyncArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class rsyncArguments: ProcessArguments {
    
    private var config:configuration?
    private var args:Array<String>?
    private var command:String?
    private var file:String?
    private var argDisplay:String?
    
    // Set parameters for rsync
    private func arguments(remoteFile : String?, localCatalog : String?, drynrun:Bool?) {
        
        if let config = self.config {
            // Drop the two first characeters ("./") as result from the find . -name
            let remote_with_whitespace:String = String(remoteFile!.characters.dropFirst(2))
            // Replace remote for white spaces
            let whitespace:String = "\\ "
            let remote = remote_with_whitespace.replacingOccurrences(of: " ", with: whitespace)
            let local:String = localCatalog!
            if (config.sshport != nil) {
                self.args!.append("-e")
                self.args!.append("ssh -p " + String(config.sshport!))
            } else {
                self.args!.append("-e")
                self.args!.append("ssh")
            }
            self.args!.append("--archive")
            self.args!.append("--verbose")
            // If copy over network compress files
            if (config.offsiteServer.isEmpty) {
                self.args!.append("--compress")
            }
            // Set dryrun or not
            if (drynrun != nil) {
                if (drynrun == true) {
                    self.args!.append("--dry-run")
                }
            }
            if (config.offsiteServer.isEmpty) {
                self.args!.append(config.offsiteCatalog + remote)
            } else {
                let offsiteArguments = config.offsiteUsername + "@" + config.offsiteServer + ":" + config.offsiteCatalog + remote
                self.args!.append(offsiteArguments)
            }
            self.args!.append(local)
            // Set command to Process /usr/bin/rysnc or /usr/local/bin/rsync
            // or other set by userconfiguration
            self.command = SharingManagerConfiguration.sharedInstance.setRsyncCommand()
            // Prepare the display version of arguments
            self.argDisplay = self.command! + " "
            for i in 0 ..< self.args!.count {
                self.argDisplay = self.argDisplay!  + self.args![i] + " "
            }
        }
    }
    
    func getArguments() -> Array<String>? {
        guard self.args != nil else {
            return nil
        }
        return self.args
    }
    
    func getCommand() -> String? {
        guard self.command != nil else {
            return nil
        }
        return self.command
    }
    
    init(config: configuration, remoteFile : String?, localCatalog : String?, drynrun:Bool?) {
        
        self.config = config
        // Initialize the argument array
        self.args = nil
        self.args = Array<String>()
        self.arguments(remoteFile: remoteFile, localCatalog: localCatalog, drynrun: drynrun)
        
    }
}
