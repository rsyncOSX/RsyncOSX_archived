//
//  RcloneReference.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

class RcloneReference {

    // Creates a singelton of this class
    class var  shared: RcloneReference {
        struct Singleton {
            static let instance = RcloneReference()
        }
        return Singleton.instance
    }

    var norsync: Bool = false
    // True if version 3.2.1 of rsync in /usr/local/bin
    var rsyncVer3: Bool = true
    // Optional path to rsync
    var rsyncPath: String?
    // rclone command
    var rsync: String = "rclone"
    var usrbinrsync: String = "/usr/bin/rclone"
    var usrlocalbinrsync: String = "/usr/local/bin/rclone"
    var configpath: String = "/Rclone/"
}
