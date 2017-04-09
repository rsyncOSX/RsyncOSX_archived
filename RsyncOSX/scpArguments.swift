//
//  scpArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class scpArguments {
    
    private var config:configuration?
    private var args:Array<String>?
    private var command:String?
    private var file:String?
    private var stringArray:Array<String>?
    
    // Set parameters for SCP for .create
    private func arguments(postfix:String) {
        
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
    
    init(config: configuration, postfix:String) {
        
        self.config = config
        // Initialize the argument array
        self.args = nil
        self.args = Array<String>()
        self.arguments(postfix: postfix)
        
    }
}
