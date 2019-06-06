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
        if ViewControllerReference.shared.rsyncversion3 {
            if ViewControllerReference.shared.localrsyncpath == nil {
                self.rsyncpath = ViewControllerReference.shared.usrlocalbinrsync
            } else {
                self.rsyncpath = ViewControllerReference.shared.localrsyncpath! + ViewControllerReference.shared.rsync
            }
        } else {
            self.rsyncpath = ViewControllerReference.shared.usrbinrsync
        }
    }
}
