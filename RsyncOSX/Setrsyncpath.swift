//
//  Setrsyncpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Setrsyncpath {
    weak var setinfoaboutrsyncDelegate: Setinfoaboutrsync?

    init() {
        setinfoaboutrsyncDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        var rsyncpath: String?
        // If not in /usr/bin or /usr/local/bin, rsyncPath is set if none of the above
        if let pathforrsync = SharedReference.shared.localrsyncpath {
            rsyncpath = pathforrsync + SharedReference.shared.rsync
        } else if SharedReference.shared.rsyncversion3 {
            if SharedReference.shared.macosarm {
                rsyncpath = SharedReference.shared.opthomebrewbinrsync
            } else {
                rsyncpath = SharedReference.shared.usrlocalbinrsync
            }
        } else {
            rsyncpath = SharedReference.shared.usrbinrsync
        }
        guard SharedReference.shared.rsyncversion3 == true else {
            SharedReference.shared.norsync = false
            setinfoaboutrsyncDelegate?.setinfoaboutrsync()
            return
        }
        if FileManager.default.isExecutableFile(atPath: rsyncpath ?? "") == false {
            SharedReference.shared.norsync = true
        } else {
            SharedReference.shared.norsync = false
        }
        setinfoaboutrsyncDelegate?.setinfoaboutrsync()
    }

    init(path: String) {
        var path = path
        if path.isEmpty == false {
            if path.hasSuffix("/") == false {
                path += "/"
                SharedReference.shared.localrsyncpath = path
            } else {
                SharedReference.shared.localrsyncpath = path
            }
        } else {
            SharedReference.shared.localrsyncpath = nil
        }
    }
}
