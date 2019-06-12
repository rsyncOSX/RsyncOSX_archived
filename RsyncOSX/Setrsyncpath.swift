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
        self.setinfoaboutrsyncDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        let fileManager = FileManager.default
        let path: String?
        // If not in /usr/bin or /usr/local/bin, rsyncPath is set if none of the above
        if let rsyncPath = ViewControllerReference.shared.localrsyncpath {
            path = rsyncPath + ViewControllerReference.shared.rsync
        } else if ViewControllerReference.shared.rsyncversion3 {
            path = "/usr/local/bin/" + ViewControllerReference.shared.rsync
        } else {
            path = "/usr/bin/" + ViewControllerReference.shared.rsync
        }
        guard ViewControllerReference.shared.rsyncversion3 == true else {
            ViewControllerReference.shared.norsync = false
            self.setinfoaboutrsyncDelegate?.setinfoaboutrsync()
            return
        }
        if fileManager.fileExists(atPath: path!) == false {
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
