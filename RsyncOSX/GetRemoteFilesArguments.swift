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

final class GetRemoteFilesArguments: ProcessArguments {

    private var config: Configuration?
    private var args: Array<String>?
    private var command: String?
    private var file: String?

    private func arguments2() {
        if let config = self.config {
            // ssh user@server.com "cd offsiteCatalog; du ."
            if config.sshport != nil {
                self.args!.append("-p")
                self.args!.append(String(config.sshport!))
            }
            if config.offsiteServer.isEmpty == false {
                self.args!.append(config.offsiteUsername + "@" + config.offsiteServer)
                self.command = "/usr/bin/ssh"
            } else {
                self.args!.append("-c")
                self.command = "/bin/bash"
            }
            let str: String = "cd " + config.offsiteCatalog + ";du -a -h"
            // let str:String = "cd " + config.offsiteCatalog + ";find . -print"
            self.args!.append(str)
        }
    }

    private func arguments() {
        let tools = Tools()
        self.command = tools.rsyncpath()
        if let config = self.config {
            if config.sshport != nil {
                self.args!.append("-p")
                self.args!.append(String(config.sshport!))
            }
            self.args!.append("-r")
            self.args!.append("--list-only")
            if config.offsiteServer.isEmpty == false {
                self.args!.append(config.offsiteUsername + "@" + config.offsiteServer + ":" + config.offsiteCatalog)
            } else {
                self.args!.append(":" + config.offsiteCatalog)
            }
        }
    }

    func getArguments() -> Array<String>? {
        guard self.args != nil else {
            return nil
        }
        return self.args
    }

    func getCommand() -> String? {
        guard self.command != nil else {
            return nil
        }
        return self.command
    }

    init(config: Configuration) {
        self.config = config
        self.args = nil
        self.args = Array<String>()
        self.arguments()
    }
}
