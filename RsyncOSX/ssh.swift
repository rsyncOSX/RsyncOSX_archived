//
//  ssh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ssh: files {
    
    // Delegate for reporting file error if any to main view
    // Comply to protocol
    weak var error_delegate: ReportErrorInMain?
    
    let rsa:String = "id_rsa.pub"
    let dsa:String = "id_dsa.pub"
    var dsaPubKey:Bool = false
    var rsaPubKey:Bool = false
    
    // Full paths to public keys
    var rsaURLpath:URL?
    var dsaURLpath:URL?
    var rsaStringPath:String?
    var dasStringPath:String?
    
    var fileURLS:Array<URL>?
    var fileStrings:Array<String>?
    
    var scpArguments:scpArgumentsSsh?
    var command:String?
    var arguments:Array<String>?
    
    // Check if rsa and/or dsa is existing in .ssh catalog
    
    func existPubKeys (str:String) -> Bool {
        guard self.fileStrings != nil else {
            return false
        }
        guard self.fileStrings!.filter({$0.contains(str)}).count == 1 else {
            return false
        }
        
        switch str {
        case self.rsa:
            self.rsaURLpath = URL(string: self.fileStrings!.filter({$0.contains(str)})[0])
            self.rsaStringPath = self.fileStrings!.filter({$0.contains(str)})[0]
        case self.dsa:
            self.dsaURLpath = URL(string: self.fileStrings!.filter({$0.contains(str)})[0])
            self.dasStringPath = self.fileStrings!.filter({$0.contains(str)})[0]
        default:
            break
        }
        return true
    }
    
    
    func ScpPubKey(str: String, hiddenID:Int) {
        switch str {
        case "rsa":
            guard self.rsaStringPath != nil else {
                return
            }
            self.scpArguments = scpArgumentsSsh(hiddenID: hiddenID, path: self.rsaStringPath!, key: str)
        case "dsa":
            guard self.dasStringPath != nil else {
                return
            }
            self.scpArguments = scpArgumentsSsh(hiddenID: hiddenID, path: self.dasStringPath!, key: str)
        default:
            break
        }
        self.command = self.scpArguments!.getCommand()
        self.arguments = self.scpArguments!.getArguments()
    }
    
    
    init() {
        super.init(path: nil, root: .userRoot)
        self.fileURLS = self.getFilesURLs()
        self.fileStrings = self.getFileStrings()
        self.rsaPubKey = self.existPubKeys(str: rsa)
        self.dsaPubKey = self.existPubKeys(str: dsa)
    }
    
}

extension ssh: ReportError {
    // Private func for propagating any file error to main view
    func reportError(errorstr:String) {
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain {
            self.error_delegate = pvc as? ViewControllertabMain
            self.error_delegate?.fileerror(errorstr: errorstr)
        }
    }
    
}
