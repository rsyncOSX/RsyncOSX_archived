//
//  scpArgumentsSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum sshOperations {
    case scpKey
    case checkKey
    case createKey
    case createRemoteSshCatalog
    
}

final class scpArgumentsSsh {
    
    private var config:configuration?
    private var args:Array<String>?
    private var command:String?
    private var file:String?
    private var stringArray:Array<String>?
    
    private var rsaPubkeyString:String = ".ssh_test/authorized_keys"
    private var dsaPubkeyString:String = ".ssh_test/authorized_keys2"
    
    // Set parameters for SCP for copy public ssh key to server
    // scp ~/.ssh/id_rsa.pub user@server.com:.ssh/authorized_keys
    private func argumentsScpPubKey(path:String, key:String) {
        
        var offsiteArguments:String?
        
        guard self.config != nil else {
            return
        }
        
        guard (self.config!.offsiteServer.isEmpty == false) else {
            return
        }
        
        self.args = nil
        self.args = Array<String>()
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
          offsiteArguments = self.config!.offsiteUsername + "@" + self.config!.offsiteServer + ":" + rsaPubkeyString
        } else {
          offsiteArguments = self.config!.offsiteUsername + "@" + self.config!.offsiteServer + ":" + dsaPubkeyString
        }
        self.args!.append(offsiteArguments!)
        self.command = "/usr/bin/scp"
    }
    
    
    //  Check if pub key exists on remote server
    //  ssh thomas@10.0.0.58 "ls -al ~/.ssh/authorized_keys"
    private func argumentsScheckRemotePubKey(key:String) {
        
        var offsiteArguments:String?
        
        guard self.config != nil else {
            return
        }
        
        guard (self.config!.offsiteServer.isEmpty == false) else {
            return
        }
        
        self.args = nil
        self.args = Array<String>()
        if (self.config!.sshport != nil) {
            self.args!.append("-P")
            self.args!.append(String(self.config!.sshport!))
        }
        offsiteArguments = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
        self.args!.append(offsiteArguments!)
        
        if key == "rsa" {
            self.args!.append("ls -al ~/" + rsaPubkeyString)
        } else {
            self.args!.append("ls -al ~/" + dsaPubkeyString)
        }
        self.command = "/usr/bin/ssh"
    }
    
    // Create key with ssh-keygen
    private func argumentsCreateKeys(key:String) {
        self.args = nil
        self.args = Array<String>()
        self.args!.append("-t")
        self.args!.append(key)
        self.command = "/usr/bin/ssh-keygen"
        
    }
    
    //  Create remote catalog
    private func argumentsCreateRemoteSshCatalog() {
        
        var offsiteArguments:String?
        
        guard self.config != nil else {
            return
        }
        
        guard (self.config!.offsiteServer.isEmpty == false) else {
            return
        }
        
        self.args = nil
        self.args = Array<String>()
        if (self.config!.sshport != nil) {
            self.args!.append("-P")
            self.args!.append(String(self.config!.sshport!))
        }
        offsiteArguments = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
        self.args!.append(offsiteArguments!)
        self.args!.append("mkdir ~/.ssh_test")
        self.command = "/usr/bin/ssh"
    }
    
    // Set the correct arguments
    func getArguments(operation:sshOperations, key:String, path:String?) -> Array<String>? {
        switch operation {
        case .checkKey:
            self.argumentsScheckRemotePubKey(key: key)
        case .createKey:
            self.argumentsCreateKeys(key: key)
        case .scpKey:
            self.argumentsScpPubKey(path: path!, key: key)
        case .createRemoteSshCatalog:
            self.argumentsCreateRemoteSshCatalog()
        }
        return self.args
    }
    
    func getCommand() -> String? {
        guard self.command != nil else {
            return nil
        }
        return self.command
    }
    
    init(hiddenID: Int) {
        self.config = SharingManagerConfiguration.sharedInstance.getConfigurations()[SharingManagerConfiguration.sharedInstance.getIndex(hiddenID)]
    }
}
