//
//  SnapshotDeleteCatalogsArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class SnapshotDeleteCatalogsArguments {
    private var config: Configuration?
    private var args: [String]?
    private var command: String?
    private var remotecatalog: String?

    private func remotearguments() {
        var remotearg: String?
        guard self.config != nil else { return }
        if self.config?.sshport != nil {
            self.args?.append("-p")
            self.args?.append(String(self.config!.sshport!))
        }
        if self.config?.offsiteServer.isEmpty == false {
            remotearg = (self.config?.offsiteUsername ?? "") + "@" + (self.config?.offsiteServer ?? "")
            self.args?.append(remotearg ?? "")
        }
        let remotecommand = "rm -rf " + (self.remotecatalog ?? "")
        self.args?.append(remotecommand)
    }

    private func localarguments() {
        guard self.config != nil else { return }
        let remotecatalog = self.remotecatalog!
        self.args?.append("-rf")
        self.args?.append(remotecatalog)
    }

    func getArguments() -> [String]? {
        return self.args
    }

    func getCommand() -> String? {
        return self.command
    }

    init(config: Configuration, remotecatalog: String) {
        self.args = [String]()
        self.config = config
        self.remotecatalog = remotecatalog
        if config.offsiteServer.isEmpty == false {
            self.remotearguments()
            self.command = "/usr/bin/ssh"
        } else {
            self.localarguments()
            self.command = "/bin/rm"
        }
    }
}
