//
//  Configpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28/08/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct Configpath {
    var configpath: String?
    init() {
        if ViewControllerReference.shared.usenewconfigpath == true {
            self.configpath = ViewControllerReference.shared.newconfigpath
        } else {
            self.configpath = ViewControllerReference.shared.configpath
        }
    }
}
