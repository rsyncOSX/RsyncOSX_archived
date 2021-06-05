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
        if SharedReference.shared.rsyncversion3 {
            if SharedReference.shared.localrsyncpath == nil {
                rsyncpath = SharedReference.shared.usrlocalbinrsync
            } else {
                rsyncpath = SharedReference.shared.localrsyncpath! + SharedReference.shared.rsync
            }
        } else {
            rsyncpath = SharedReference.shared.usrbinrsync
        }
    }
}
