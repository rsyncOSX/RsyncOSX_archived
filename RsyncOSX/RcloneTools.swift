//
//  RcloneTools.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class RcloneTools {

    func verifyrsyncpath() {
        let fileManager = FileManager.default
        let path: String?
        if let rsyncPath = RcloneReference.shared.rsyncPath {
            path = rsyncPath + RcloneReference.shared.rsync
        } else if RcloneReference.shared.rsyncVer3 {
            path = "/usr/local/bin/" + RcloneReference.shared.rsync
        } else {
            path = "/usr/bin/" + RcloneReference.shared.rsync
        }
        guard RcloneReference.shared.rsyncVer3 == true else {
            RcloneReference.shared.norsync = false
            return
        }
        if fileManager.fileExists(atPath: path!) == false {
            RcloneReference.shared.norsync = true
        } else {
            RcloneReference.shared.norsync = false
        }
    }

    func rsyncpath() -> String {
        if RcloneReference.shared.rsyncVer3 {
            if RcloneReference.shared.rsyncPath == nil {
                return RcloneReference.shared.usrlocalbinrsync
            } else {
                return RcloneReference.shared.rsyncPath! + RcloneReference.shared.rsync
            }
        } else {
            return RcloneReference.shared.usrbinrsync
        }
    }

    func noRsync() {
        if let rsync = RcloneReference.shared.rsyncPath {
            Alerts.showInfo("ERROR: no rclone in " + rsync)
        } else {
            Alerts.showInfo("ERROR: no rclone in /usr/local/bin")
        }
    }

}
