//
//  scpArgumentsSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class scpArgumentsSsh {
    
    private var config:configuration?
    private var args:Array<String>?
    private var command:String?
    private var file:String?
    private var stringArray:Array<String>?
    
    private var rsaPubkey:String = ".ssh/authorized_keys"
    private var dsaPubkey:String = ".ssh/authorized_keys2"
    
    // Set parameters for SCP for copy public ssh key to server
    // scp ~/.ssh/id_rsa.pub user@server.com:.ssh/authorized_keys
    
    private func arguments(path:String, key:String) {
        
        var offsiteArguments:String?
        
        guard self.config != nil else {
            return
        }
        
        guard self.config!.offsiteServer.isEmpty else {
            return
        }
        
        if (self.config!.sshport != nil) {
            self.args!.append("-P")
            self.args!.append(String(self.config!.sshport!))
        }
        self.args!.append("-B")
        self.args!.append("-p")
        self.args!.append("-q")
        self.args!.append("-o")
        self.args!.append("ConnectTimeout=5")
        self.args!.append(path)
        if key == "rsa" {
          offsiteArguments = self.config!.offsiteUsername + "@" + self.config!.offsiteServer + ":" + rsaPubkey
        } else {
          offsiteArguments = self.config!.offsiteUsername + "@" + self.config!.offsiteServer + ":" + dsaPubkey
        }
        self.args!.append(offsiteArguments!)
        self.command = "/usr/bin/scp"
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
    
    init(config: configuration, path:String, key:String) {
        self.config = config
        // Initialize the argument array
        self.args = nil
        self.args = Array<String>()
        self.arguments(path: path, key: key)
    }
}
