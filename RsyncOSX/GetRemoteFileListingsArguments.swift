//
//  getRemoteFilelist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.05.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

protocol ProcessArguments {
    func getArguments() -> Array<String>?
    func getCommand() -> String?
}

final class GetRemoteFileListingsArguments: ProcessArguments {

    private var config: Configuration?
    private var args: Array<String>?
    private var command: String?
    private var file: String?

    private func arguments(recursive: Bool) {
        let tools = Tools()
        self.command = tools.rsyncpath()
        if let config = self.config {
            if config.sshport != nil {
                let eparam: String = "-e"
                let sshp: String = "ssh -p"
                self.args!.append(eparam)
                self.args!.append(sshp + String(config.sshport!))
            } else {
                let eparam: String = "-e"
                let ssh: String = "ssh"
                self.args!.append(eparam)
                self.args!.append(ssh)
            }
            if recursive {
                self.args!.append("-r")
            }
            self.args!.append("--list-only")
            if config.offsiteServer.isEmpty == false {
                self.args!.append(config.offsiteUsername + "@" + config.offsiteServer + ":" + config.offsiteCatalog)
            } else {
                self.args!.append(":" + config.offsiteCatalog)
            }
        }
    }

    func getArguments() -> Array<String>? {
        guard self.args != nil else { return nil }
        return self.args
    }

    func getCommand() -> String? {
        guard self.command != nil else {
            return nil
        }
        return self.command
    }

    init(config: Configuration, recursive: Bool) {
        self.config = config
        self.args = nil
        self.args = Array<String>()
        self.arguments(recursive: recursive)
    }
}
