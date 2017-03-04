//
//  scpNSTaskArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27/06/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation


enum enumscpTasks {
    case create
    case scpFind
    case copy
}

final class scpProcessArguments {
    
    // File to read
    private var file:String?
    // Array for storing arguments
    private var args:Array<String>?
    // String for display
    private var argDisplay:String?
    // command string
    private var command:String?
    // config, is set in init
    private var config:configuration?
    // Output of NSTask
    private var output:Array<String>?
    
    // Getting arguments
    func getArgs() -> Array<String>? {
        return self.args
    }
    // Getting command
    func getCommand() -> String? {
        return self.command
    }
    
    // Getting the command to display in view
    func getcommandDisplay() -> String? {
        return self.argDisplay
    }
    
    // Reading content of txt file into an Array of String
    func getSearchfile () -> [String]? {
        var stringArray:[String]?
        if let file = self.file {
            let fileContent = try? String(contentsOfFile: file, encoding: String.Encoding.utf8)
            if fileContent != nil {
                stringArray = fileContent!.components(separatedBy: CharacterSet.newlines)
            }
        }
        return stringArray
    }
    
    // Set parameters for SCP for .create og .plist files
    private func setSCParguments(_ postfix:String) {
        
        if let config = self.config {
            var postfix2:String?
            // For SCP copy history.plist from server to local store
            if (config.sshport != nil) {
                self.args!.append("-P")
                self.args!.append(String(config.sshport!))
            }
            self.args!.append("-B")
            self.args!.append("-p")
            self.args!.append("-q")
            self.args!.append("-o")
            self.args!.append("ConnectTimeout=5")
            if (config.offsiteServer.isEmpty) {
                self.args!.append(config.offsiteCatalog + "." + postfix)
                postfix2 = "localhost" + "_" + postfix
            } else {
                let offsiteArguments = config.offsiteUsername + "@" + config.offsiteServer + ":" + config.offsiteCatalog + "." + postfix
                self.args!.append(offsiteArguments)
                postfix2 = config.offsiteServer + "_" + postfix
            }
            // We just create the .files in root Documents directory
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let docuDir = paths.firstObject as! String
            self.args!.append(docuDir + "/" + "." + postfix2!)
            self.command = "/usr/bin/scp"
            self.file = docuDir + "/" + "." + postfix2!
        }
    }
    
    // Set parameters for rsync
    private func setRsyncarguments(remoteFile : String?, localCatalog : String?, drynrun:Bool?) {
        
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
    
    // Set arguments for remote create of files.txt
    private func setCreate() {
        if let config = self.config {
            // ssh user@server.com "cd offsiteCatalog; find . -print | cat > .files.txt"
            if (config.sshport != nil) {
                self.args!.append("-p")
                self.args!.append(String(config.sshport!))
            }
            if (config.offsiteServer.isEmpty == false) {
                self.args!.append(config.offsiteUsername + "@" + config.offsiteServer)
                self.command = "/usr/bin/ssh"
            } else {
                self.args!.append("-c")
                self.command = "/bin/bash"
            }
            let str:String = "cd " + config.offsiteCatalog + "; find . -print | cat > .files.txt "
            self.args!.append(str)
        }
    }
    
    init (task : enumscpTasks, config : configuration, remoteFile : String?, localCatalog : String?, drynrun:Bool?) {
        
        // Initialize the argument array
        self.args = nil
        self.args = Array<String>()
        // Initialize the output
        self.output = nil
        self.output = Array<String>()
        // Set config
        self.config = config
        
        switch (task) {
        case .create:
            self.setCreate()
        case .scpFind:
            // For SCP copy result of find . -name from server to local store
            self.setSCParguments("files.txt")
        case .copy:
            self.setRsyncarguments(remoteFile: remoteFile, localCatalog: localCatalog, drynrun: drynrun)
        }
    }
}
