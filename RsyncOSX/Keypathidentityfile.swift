//
//  Keypathidentityfile.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28/05/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct Keypathidentityfile {
    var rootpath: String?
    // If global keypath and identityfile is set must split keypath and identifile
    // create a new key require full path
    var identityfile: String?

    init(sshkeypathandidentityfile: String) {
        if sshkeypathandidentityfile.first == "~" {
            // must drop identityfile and then set rootpath
            // also drop the "~" character
            var sshkeypathandidentityfilesplit = sshkeypathandidentityfile.split(separator: "/")
            guard sshkeypathandidentityfilesplit.count > 2 else {
                // If anything goes wrong set to default global values
                self.rootpath = NSHomeDirectory() + "/.ssh"
                ViewControllerReference.shared.sshkeypathandidentityfile = nil
                self.identityfile = "id_rsa"
                return
            }
            self.identityfile =
                String(sshkeypathandidentityfilesplit[sshkeypathandidentityfilesplit.count - 1])
            sshkeypathandidentityfilesplit.remove(at: sshkeypathandidentityfilesplit.count - 1)
            self.rootpath = NSHomeDirectory() +
                sshkeypathandidentityfilesplit.joined(separator: "/").dropFirst()
        } else {
            // If anything goes wrong set to default global values
            self.rootpath = NSHomeDirectory() + "/.ssh"
            ViewControllerReference.shared.sshkeypathandidentityfile = nil
            self.identityfile = "id_rsa"
        }
    }
}
