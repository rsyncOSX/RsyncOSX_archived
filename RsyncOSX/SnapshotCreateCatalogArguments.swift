//
//  SnapShotCreateInitialCatalog.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class SnapshotCreateCatalogArguments {
    private var config: Configuration?
    private var args: [String]?
    private var command: String?

    private func remotearguments() {
        var remotearg: String?
        if self.config?.sshport != nil {
            self.args?.append("-p")
            self.args?.append(String(self.config!.sshport!))
        }
        if (self.config?.offsiteServer.isEmpty ?? true) == false {
            remotearg = (self.config?.offsiteUsername ?? "") + "@" + (self.config?.offsiteServer ?? "")
            self.args?.append(remotearg!)
        }
        let remotecatalog = config?.offsiteCatalog
        let remotecommand = "mkdir -p " + (remotecatalog ?? "")
        self.args?.append(remotecommand)
    }

    func getArguments() -> [String]? {
        return self.args
    }

    func getCommand() -> String? {
        return self.command
    }

    init(config: Configuration?) {
        guard config != nil else { return }
        self.args = [String]()
        self.config = config
        self.remotearguments()
        self.command = "/usr/bin/ssh"
    }
}
