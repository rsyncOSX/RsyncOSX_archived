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
        if let rsyncPath = RcloneReference.shared.rclonePath {
            path = rsyncPath + RcloneReference.shared.rclone
        } else if RcloneReference.shared.rcloneopt {
            path = "/usr/local/bin/" + RcloneReference.shared.rclone
        } else {
            path = "/usr/bin/" + RcloneReference.shared.rclone
        }
        guard RcloneReference.shared.rcloneopt == true else {
            RcloneReference.shared.norclone = false
            return
        }
        if fileManager.fileExists(atPath: path!) == false {
            RcloneReference.shared.norclone = true
        } else {
            RcloneReference.shared.norclone = false
        }
    }

    func rsyncpath() -> String {
        if RcloneReference.shared.rcloneopt {
            if RcloneReference.shared.rclonePath == nil {
                return RcloneReference.shared.usrlocalbinrclone
            } else {
                return RcloneReference.shared.rclonePath! + RcloneReference.shared.rclone
            }
        } else {
            return RcloneReference.shared.usrbinrclone
        }
    }

    func noRsync() {
        if let rsync = RcloneReference.shared.rclonePath {
            Alerts.showInfo("ERROR: no rclone in " + rsync)
        } else {
            Alerts.showInfo("ERROR: no rclone in /usr/local/bin")
        }
    }

}
