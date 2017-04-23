//
//  ssh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class ssh: profiles {
    
    let rsa:String = "id_rsa.pub"
    let dsa:String = "id_dsa.pub"
    var paths:NSArray?
    
    init() {
        super.init(path: nil, root: .userRoot)
        
    }
    
    
}
