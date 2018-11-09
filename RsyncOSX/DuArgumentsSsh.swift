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

    //  Create remote catalog
    // either ssh or ssh "-p port"
    private func argumentsDuremote() {
        var remotearg: String?
        guard self.config != nil else { return }
        guard self.config!.offsiteServer.isEmpty == false else { return }
        self.args = [String]()
        if self.config!.sshport != nil {
            let sshport: String = "\"" + "-p " + String(self.config!.sshport!) + "\""
            self.args!.append(sshport)
        }
        remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
        self.args!.append(remotearg!)
        self.args!.append("\"")
        let sizestring = "cd " + config!.offsiteCatalog + ";" + "df -h ."
        self.args!.append(sizestring)
        self.args!.append("\"")
    }

    func getCommand() -> String? {
        guard self.command != nil else { return nil }
        return self.command
    }

    func getArguments() -> [String]? {
        return self.args
    }

    init(hiddenID: Int) {
        self.command = "/usr/bin/ssh"
        self.config = self.configurations!.getConfigurations()[self.configurations!.getIndex(hiddenID)]
        self.argumentsDuremote()
    }
}
