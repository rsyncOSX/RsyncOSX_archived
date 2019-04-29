//
//  RcloneTools.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class RcloneTools {

    func verifyrclonepath() {
        let fileManager = FileManager.default
        let path: String?
        if let rclonepath = RcloneReference.shared.rclonePath {
            path = rclonepath + RcloneReference.shared.rclone
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

    func rclonepath() -> String {
        // Read user configuration
        var storage: RclonePersistentStorageAPI?
        storage = RclonePersistentStorageAPI(profile: nil)
        if let userConfiguration =  storage?.getUserconfiguration() {
            _ = RcloneUserconfiguration(userconfigRsyncOSX: userConfiguration)
        }
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

    func norclone() {
        if let rclone = RcloneReference.shared.rclonePath {
            let error3: String = NSLocalizedString("ERROR: no rclone i ", comment: "Error rclone") + rclone
            Alerts.showInfo(info: error3)
        } else {
            let error4: String = NSLocalizedString("ERROR: no rclone in /usr/local/bin", comment: "Error rclone")
            Alerts.showInfo(info: error4)
        }
    }

}
