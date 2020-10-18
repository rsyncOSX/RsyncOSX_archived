//
//  Rsyncpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

struct Setrsyncpath {
    weak var setinfoaboutrsyncDelegate: Setinfoaboutrsync?

    init() {
        self.setinfoaboutrsyncDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        var rsyncpath: String?
        // If not in /usr/bin or /usr/local/bin, rsyncPath is set if none of the above
        if let pathforrsync = ViewControllerReference.shared.localrsyncpath {
            rsyncpath = pathforrsync + ViewControllerReference.shared.rsync
        } else if ViewControllerReference.shared.rsyncversion3 {
            rsyncpath = "/usr/local/bin/" + ViewControllerReference.shared.rsync
        } else {
            rsyncpath = "/usr/bin/" + ViewControllerReference.shared.rsync
        }
        guard ViewControllerReference.shared.rsyncversion3 == true else {
            ViewControllerReference.shared.norsync = false
            self.setinfoaboutrsyncDelegate?.setinfoaboutrsync()
            return
        }
        if FileManager.default.isExecutableFile(atPath: rsyncpath ?? "") == false {
            ViewControllerReference.shared.norsync = true
        } else {
            ViewControllerReference.shared.norsync = false
        }
        self.setinfoaboutrsyncDelegate?.setinfoaboutrsync()
    }

    init(path: String) {
        var path = path
        if path.isEmpty == false {
            if path.hasSuffix("/") == false {
                path += "/"
                ViewControllerReference.shared.localrsyncpath = path
            } else {
                ViewControllerReference.shared.localrsyncpath = path
            }
        } else {
            ViewControllerReference.shared.localrsyncpath = nil
        }
    }
}
