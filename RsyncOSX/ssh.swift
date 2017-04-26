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
    
    let rsa:String = "id_rsa.pub"
    let dsa:String = "id_dsa.pub"
    var dsaBool:Bool = false
    var rsaBool:Bool = false
    
    var fileURLS:Array<URL>?
    var fileStrings:Array<String>?
    
    
    // Check if rsa and/or dsa is existing in .ssh catalog
    
    func check(str:String) -> Bool {
        guard self.fileStrings != nil else {
            return false
        }
        guard self.fileStrings!.filter({$0.contains(str)}).count > 0 else {
            return false
        }
        
        return true
    }
    
    init() {
        super.init(path: nil, root: .userRoot)
        self.fileURLS = self.getFilesURLs()
        self.fileStrings = self.getFileStrings()
        self.rsaBool = self.check(str: rsa)
        self.dsaBool = self.check(str: dsa)
    }
    
    
}
