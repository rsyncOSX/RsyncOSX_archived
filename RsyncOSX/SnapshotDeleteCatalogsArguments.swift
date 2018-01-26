//
//  SnapshotDeleteCatalogsArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

// swiftlint:disable syntactic_sugar

import Foundation

final class SnapshotDeleteCatalogsArguments: ProcessArguments {

    private var config: Configuration?
    private var args: Array<String>?
    private var command: String?
    private var remotecatalog: String?

    private func remotearguments() {
        var remotearg: String?
        guard self.config != nil else { return }
        if self.config!.sshport != nil {
            self.args!.append("-p")
            self.args!.append(String(self.config!.sshport!))
        }
        if self.config!.offsiteServer.isEmpty == false {
            remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
            self.args!.append(remotearg!)
        }
        let remotecommand = "ls -al " + self.remotecatalog!
        self.args!.append(remotecommand)
    }

    func getArguments() -> Array<String>? {
        return self.args
    }

    func getCommand() -> String? {
        return self.command
    }

    init (config: Configuration, remotecatalog: String) {
        self.args = Array<String>()
        self.config = config
        self.remotecatalog = remotecatalog
        if config.offsiteServer.isEmpty == false {
            self.remotearguments()
            self.command = "/usr/bin/ssh"
        }
    }
}
