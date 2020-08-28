//
//  NamesandPaths.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint: disable line length

import Foundation

enum WhatToReadWrite {
    case schedule
    case configuration
    case userconfig
    case none
}

enum Profileorsshrootpath {
    case profileroot
    case sshroot
}

class NamesandPaths {
    var profileorsshroot: Profileorsshrootpath?
    var rootpath: String?
    // If global keypath and identityfile is set must split keypath and identifile
    // create a new key require full path
    var identityfile: String?
    // config path either
    // ViewControllerReference.shared.configpath or RcloneReference.shared.configpath
    var configpath: String?
    // Name set for schedule, configuration or config
    var plistname: String?
    // key in objectForKey, e.g key for reading what
    var key: String?
    // Which profile to read
    var profile: String?
    // task to do
    var task: WhatToReadWrite?
    // Path for configuration files
    var filepath: String?
    // Set which file to read
    var filename: String?
    // Documentscatalog
    var documentscatalog: String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        return (paths.firstObject as? String)
    }

    // Path to ssh keypath
    var sshrootkeypath: String? {
        if let sshkeypathandidentityfile = ViewControllerReference.shared.sshkeypathandidentityfile {
            return Keypathidentityfile(sshkeypathandidentityfile: sshkeypathandidentityfile).rootpath
        } else {
            return NSHomeDirectory() + "/.ssh"
        }
    }

    // path to ssh identityfile
    var sshidentityfile: String? {
        if let sshkeypathandidentityfile = ViewControllerReference.shared.sshkeypathandidentityfile {
            return Keypathidentityfile(sshkeypathandidentityfile: sshkeypathandidentityfile).identityfile
        } else {
            return "id_rsa"
        }
    }

    // Mac serialnumber
    var macserialnumber: String? {
        if ViewControllerReference.shared.macserialnumber == nil {
            ViewControllerReference.shared.macserialnumber = Macserialnumber().getMacSerialNumber() ?? ""
        }
        return ViewControllerReference.shared.macserialnumber
    }

    var userHomeDirectoryPath: String? {
        let pw = getpwuid(getuid())
        if let home = pw?.pointee.pw_dir {
            let homePath = FileManager.default.string(withFileSystemRepresentation: home, length: Int(strlen(home)))
            return homePath
        } else {
            return nil
        }
    }

    func setrootpath() {
        switch self.profileorsshroot {
        case .profileroot:
            // self.rootpath = (self.documentscatalog ?? "") + (self.configpath ?? "") + (self.macserialnumber ?? "")
            self.rootpath = (self.userHomeDirectoryPath ?? "") + (self.configpath ?? "") + (self.macserialnumber ?? "")
        case .sshroot:
            self.rootpath = self.sshrootkeypath
            self.identityfile = self.sshidentityfile
        default:
            return
        }
    }

    // Set path and name for reading plist.files
    func setnameandpath() {
        let config = (self.configpath ?? "") + (self.macserialnumber ?? "")
        let plist = (self.plistname ?? "")
        if let profile = self.profile {
            // Use profile
            let profilePath = CatalogProfile()
            profilePath.createprofilecatalog()
            if ViewControllerReference.shared.usenewconfigpath == true {
                self.filename = (self.userHomeDirectoryPath ?? "") + config + "/" + profile + plist
            } else {
                self.filename = (self.documentscatalog ?? "") + config + "/" + profile + plist
            }
            self.filepath = config + "/" + profile + "/"
        } else {
            // no profile
            let profilePath = CatalogProfile()
            profilePath.createprofilecatalog()
            if ViewControllerReference.shared.usenewconfigpath == true {
                self.filename = (self.userHomeDirectoryPath ?? "") + config + plist
            } else {
                self.filename = (self.documentscatalog ?? "") + config + plist
            }
            self.filepath = config + "/"
        }
    }

    // Set preferences for which data to read or write
    func setpreferencesforreadingplist(whattoreadwrite: WhatToReadWrite) {
        self.task = whattoreadwrite
        switch self.task ?? .none {
        case .schedule:
            self.plistname = "/scheduleRsync.plist"
            self.key = "Schedule"
        case .configuration:
            self.plistname = "/configRsync.plist"
            self.key = "Catalogs"
        case .userconfig:
            self.plistname = "/config.plist"
            self.key = "config"
        case .none:
            self.plistname = nil
        }
    }

    init(profileorsshrootpath: Profileorsshrootpath, configpath: String?) {
        self.configpath = configpath
        self.profileorsshroot = profileorsshrootpath
        self.setrootpath()
    }

    init(whattoreadwrite: WhatToReadWrite, profile: String?, configpath: String?) {
        self.configpath = configpath
        self.profile = profile
        self.setpreferencesforreadingplist(whattoreadwrite: whattoreadwrite)
        self.setnameandpath()
    }
}
