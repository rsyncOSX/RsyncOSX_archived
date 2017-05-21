//
//  getRemoteFilelist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.05.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class getRemoteFilelist {
    
    private var config:configuration?
    private var args:Array<String>?
    private var command:String?
    private var file:String?
    
    // Set arguments for remote create of files.txt
    private func arguments() {
        if let config = self.config {
            // ssh user@server.com "cd offsiteCatalog; du ."
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
            let str:String = "cd " + config.offsiteCatalog + "; du -a"
            self.args!.append(str)
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
    
    func getFile() -> String? {
        guard self.file != nil else {
            return nil
        }
        return self.file
    }
    
    
    init(config: configuration) {
        
        self.config = config
        // Initialize the argument array
        self.args = nil
        self.args = Array<String>()
        self.arguments()
        
    }
}

