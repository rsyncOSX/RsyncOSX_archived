//
//  SnapshotCurrentArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// 1. ssh -p port user@host "mkdir ~/catalog"
// 2. ssh -p port user@host "cd ~/catalog; rm current; ln -s NN current"
//
// swiftlint:disable syntactic_sugar
/*
 let tst = SnapshotCurrentArguments(config: self.configurations!.getConfigurations()[self.index!])
 let tst2 = SnapshotCurrent(command: tst.getCommand(), arguments: tst.getArguments())
 self.outputprocess = OutputProcess()
 tst2.executeProcess(outputprocess: self.outputprocess)
 print(self.outputprocess?.getOutput())
 */

import Foundation

final class SnapshotCurrentArguments: ProcessArguments {

    private var config: Configuration?
    private var args: Array<String>?
    private var command: String?

    private func remotearguments() {
        var remotearg: String?
        guard self.config != nil else { return }
        guard self.config!.offsiteServer.isEmpty == false else { return }
        if self.config!.sshport != nil {
            self.args!.append("-p")
            self.args!.append(String(self.config!.sshport!))
        }
        remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
        self.args!.append(remotearg!)
        let remotecatalog = config?.offsiteCatalog
        let snapshotnum = String(describing: config?.snapshotnum ?? 1 - 1)
        let remotecommand = "cd " + remotecatalog!+"; " + "rm current;  " + "ln -s current " + snapshotnum
        self.args!.append(remotecommand)
        self.command = "/usr/bin/ssh"
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
    }

}
