//
//  Getrsyncpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Getrsyncpath {
    var rsyncpath: String?

    init() {
        if SharedReference.shared.rsyncversion3 {
            if SharedReference.shared.localrsyncpath == nil {
                if SharedReference.shared.macosarm {
                    rsyncpath = SharedReference.shared.opthomebrewbinrsync
                } else {
                    rsyncpath = SharedReference.shared.usrlocalbinrsync
                }
            } else {
                rsyncpath = SharedReference.shared.localrsyncpath ?? "" + SharedReference.shared.rsync
            }
        } else {
            rsyncpath = SharedReference.shared.usrbinrsync
        }
    }
}

extension ProcessInfo {
    /// Returns a `String` representing the machine hardware name or nil if there was an error invoking `uname(_:)`
    ///  or decoding the response. Return value is the equivalent to running `$ uname -m` in shell.
    var machineHardwareName: String? {
        var sysinfo = utsname()
        let result = uname(&sysinfo)
        guard result == EXIT_SUCCESS else { return nil }
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        guard let identifier = String(bytes: data, encoding: .ascii) else { return nil }
        return identifier.trimmingCharacters(in: .controlCharacters)
    }
}
