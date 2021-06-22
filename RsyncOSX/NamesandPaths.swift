//
//  NamesandPaths.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

enum Rootpath {
    case configurations
    case ssh
}

class NamesandPaths: Errors {
    // rootpath without macserialnumber
    var fullpathnomacserial: String?
    // rootpath with macserialnumber
    var fullpathmacserial: String?
    // If global keypath and identityfile is set must split keypath and identifile
    var fullpathsshkeys: String?
    var identityfile: String?
    var profile: String?

    // Documentscatalog
    var documentscatalog: String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        return (paths.firstObject as? String)
    }

    // Path to ssh keypath
    var sshkeypath: String? {
        if let sshkeypathandidentityfile = SharedReference.shared.sshkeypathandidentityfile {
            return Keypathidentityfile(sshkeypathandidentityfile: sshkeypathandidentityfile).fullsshkeypath
        } else {
            return NSHomeDirectory() + "/.ssh"
        }
    }

    // Used when creating ssh keypath
    var onlysshkeypath: String? {
        if let sshkeypathandidentityfile = SharedReference.shared.sshkeypathandidentityfile {
            return Keypathidentityfile(sshkeypathandidentityfile: sshkeypathandidentityfile).onlysshkeypath
        } else {
            return NSHomeDirectory()
        }
    }

    // path to ssh identityfile
    var sshkeypathandidentityfile: String? {
        if let sshkeypathandidentityfile = SharedReference.shared.sshkeypathandidentityfile {
            return Keypathidentityfile(sshkeypathandidentityfile: sshkeypathandidentityfile).identityfile
        } else {
            return "id_rsa"
        }
    }

    // Mac serialnumber
    var macserialnumber: String? {
        if SharedReference.shared.macserialnumber == nil {
            SharedReference.shared.macserialnumber = Macserialnumber().getMacSerialNumber() ?? ""
        }
        return SharedReference.shared.macserialnumber
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

    func setrootpath(_ path: Rootpath) {
        switch path {
        case .configurations:
            fullpathmacserial = (userHomeDirectoryPath ?? "") + SharedReference.shared.configpath + (macserialnumber ?? "")
            fullpathnomacserial = (userHomeDirectoryPath ?? "") + SharedReference.shared.configpath
        case .ssh:
            fullpathsshkeys = sshkeypath
            identityfile = sshkeypathandidentityfile
        }
    }

    init(_ path: Rootpath) {
        setrootpath(path)
    }
}
