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

    var norclone: Bool = false
    // True if version 3.2.1 of rsync in /usr/local/bin
    var rcloneopt: Bool = true
    // Optional path to rsync
    var rclonePath: String?
    // rclone command
    var rclone: String = "rclone"
    var usrbinrclone: String = "/usr/bin/rclone"
    var usrlocalbinrclone: String = "/usr/local/bin/rclone"
    var configpath: String = "/Rclone/"
}
