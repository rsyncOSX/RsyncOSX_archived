//
//  Getrsyncpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Getrsyncpath {
    var rsyncpath: String?

    init() {
        if ViewControllerReference.shared.rsyncVer3 {
            if ViewControllerReference.shared.rsyncPath == nil {
                self.rsyncpath = ViewControllerReference.shared.usrlocalbinrsync
            } else {
                self.rsyncpath = ViewControllerReference.shared.rsyncPath! + ViewControllerReference.shared.rsync
            }
        } else {
            self.rsyncpath = ViewControllerReference.shared.usrbinrsync
        }
    }
}
