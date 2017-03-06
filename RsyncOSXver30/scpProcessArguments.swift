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
    case rsync
}

final class scpProcessArguments {
    
    // File to read
    private var file:String?
    // Array for storing arguments
    private var arguments:Array<String>?
    // String for display
    private var argDisplay:String?
    // command string
    private var command:String?
    // config, is set in init
    private var config:configuration?
    
    // Getting arguments
    func getArguments() -> Array<String>? {
        return self.arguments
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
    func getSearchfile() -> Array<String>? {
        var stringArray:Array<String>?
        if let file = self.file {
            let fileContent = try? String(contentsOfFile: file, encoding: String.Encoding.utf8)
            if fileContent != nil {
                stringArray = fileContent!.components(separatedBy: CharacterSet.newlines)
            }
        }
        return stringArray
    }

    init (task : enumscpTasks, config : configuration, remoteFile : String?, localCatalog : String?, drynrun:Bool?) {
        
        // Initialize the argument array
        self.arguments = nil
        self.arguments = Array<String>()
        // Set config
        self.config = config
        
        switch (task) {
        case .create:
            // Remote creating the file.txt
            let arguments = filetxtArguments(config: config)
            self.arguments = arguments.getArguments()
            self.command = arguments.getCommand()
            self.file = arguments.getFile()
        case .scpFind:
            // For SCP copy result of find . -name from server to local store
            let arguments = scpArguments(config: config, postfix: "files.txt")
            self.arguments = arguments.getArguments()
            self.command = arguments.getCommand()
            self.file = arguments.getFile()
        case .rsync:
            // Arguments for rsync
            let arguments = rsyncArguments(config: config, remoteFile: remoteFile, localCatalog: localCatalog, drynrun: drynrun)
            self.arguments = arguments.getArguments()
            self.command = arguments.getCommand()
            self.file = arguments.getFile()
        }
    }
}
