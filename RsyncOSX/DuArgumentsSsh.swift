//
//  DuArgumentsSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/11/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// ssh test@web.org " cd catalog; du -h ."

import Foundation

final class DuArgumentsSsh: SetConfigurations {

    private var config: Configuration?
    private var args: [String]?
    private var command: String?

    private func argumentsDuremote() {
        var remotearg: String?
        guard self.config != nil else { return }
        guard self.config!.offsiteUsername.isEmpty == false else { return }
        self.args = [String]()
        if self.config!.sshport != nil {
            self.sshport()
        }
        remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
        self.args!.append(remotearg!)
        let sizestring = "cd " + config!.offsiteCatalog + ";" + " df  ."
        self.args!.append(sizestring)
        self.command = "/usr/bin/ssh"
    }

    private func sshport() {
        self.args!.append("-p")
        self.args!.append(String(self.config!.sshport!))
    }

    func getCommand() -> String? {
        guard self.command != nil else { return nil }
        return self.command
    }

    func getArguments() -> [String]? {
        return self.args
    }

    init(config: Configuration) {
        self.config = config
        self.argumentsDuremote()
    }
}
