//
//  SnapShotCreateInitialCatalog.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable syntactic_sugar

import Foundation

final class SnapshotCreateCatalogArguments: ProcessArguments {

    private var config: Configuration?
    private var args: Array<String>?
    private var command: String?

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
        let remotecatalog = config?.offsiteCatalog
        let remotecommand = "mkdir " + remotecatalog!
        self.args!.append(remotecommand)
    }

    func getArguments() -> Array<String>? {
        return self.args
    }

    func getCommand() -> String? {
        return self.command
    }

    init (config: Configuration) {
        self.args = Array<String>()
        self.config = config
        self.remotearguments()
        self.command = "/usr/bin/ssh"
    }
}
