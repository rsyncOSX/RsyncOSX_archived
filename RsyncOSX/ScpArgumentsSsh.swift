//
//  scpArgumentsSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

enum SshOperations {
    case scpKey
    case checkKey
    case createKey
    case createRemoteSshCatalog
    case chmod

}

final class ScpArgumentsSsh: SetConfigurations {

    var commandCopyPasteTerminal: String?
    private var config: Configuration?
    private var args: Array<String>?
    private var command: String?
    private var file: String?
    private var stringArray: Array<String>?

    private var remoteRsaPubkeyString: String = ".ssh/authorized_keys"
    private var remoteDsaPubkeyString: String = ".ssh/authorized_keys2"

    // Set parameters for SCP for copy public ssh key to server
    // scp ~/.ssh/id_rsa.pub user@server.com:.ssh/authorized_keys
    // scp -P port ~/.ssh/id_rsa.pub user@server.com:.ssh/authorized_keys
    private func argumentsScpPubKey(path: String, key: String) {
        var remotearg: String?
        guard self.config != nil else { return }
        guard self.config!.offsiteServer.isEmpty == false else { return }
        self.args = nil
        self.args = Array<String>()
        if self.config!.sshport != nil {
            self.scpport()
        }
        self.args!.append(path)
        if key == "rsa" {
          remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer + ":" + self.remoteRsaPubkeyString
        } else {
          remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer + ":" + self.remoteDsaPubkeyString
        }
        self.args!.append(remotearg!)
        self.command = "/usr/bin/scp"
        self.commandCopyPasteTerminal = nil
        self.commandCopyPasteTerminal = self.command! + " " + self.args![0]
        for i in 1 ..< self.args!.count {
            self.commandCopyPasteTerminal = self.commandCopyPasteTerminal! + " " + self.args![i]
        }
    }

    //  Check if pub key exists on remote server
    //  ssh thomas@10.0.0.58 "ls -al ~/.ssh/authorized_keys"
    //  ssh "-p port" thomas@10.0.0.58 "ls -al ~/.ssh/authorized_keys"
    private func argumentsCheckRemotePubKey(key: String) {
        var remotearg: String?
        guard self.config != nil else { return }
        guard self.config!.offsiteServer.isEmpty == false else { return }
        self.args = nil
        self.args = Array<String>()
        if self.config!.sshport != nil {
            self.sshport()
        }
        remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
        self.args!.append(remotearg!)
        if key == "rsa" {
            self.args!.append("ls -al ~/" + self.remoteRsaPubkeyString)
        }
        if key == "dsa" {
            self.args!.append("ls -al ~/" + self.remoteDsaPubkeyString)
        }
        self.command = "/usr/bin/ssh"
    }

    // Create local key with ssh-keygen
    private func argumentsCreateKeys(path: String, key: String) {
        self.args = nil
        self.args = Array<String>()
        self.args!.append("-f")
        if key == "rsa" {
             self.args!.append(path + "id_rsa")
         } else {
             self.args!.append(path + "id_dsa")
        }
        self.args!.append("-t")
        self.args!.append(key)
        self.args!.append("-N")
        self.args!.append("")
        self.command = "/usr/bin/ssh-keygen"

    }

    // Chmod .ssh catalog
    // either ssh or ssh "-p port"
    private func argumentsChmod(key: String) {
        var remotearg: String?
        guard self.config != nil else { return }
        guard self.config!.offsiteServer.isEmpty == false else { return }
        self.args = nil
        self.args = Array<String>()
        if self.config!.sshport != nil {
            self.sshport()
        }
        remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
        self.args!.append(remotearg!)
        if key == "rsa" {
            self.args!.append("chmod 700 ~/.ssh; chmod 600 ~/" + self.remoteRsaPubkeyString)
        } else {
            self.args!.append("chmod 700 ~/.ssh; chmod 600 ~/" + self.remoteDsaPubkeyString)
        }
        self.command = "/usr/bin/ssh"
    }

    //  Create remote catalog
    // either ssh or ssh "-p port"
    private func argumentsCreateRemoteSshCatalog() {
        var remotearg: String?
        guard self.config != nil else { return }
        guard self.config!.offsiteServer.isEmpty == false else { return }
        self.args = nil
        self.args = Array<String>()
        if self.config!.sshport != nil {
            let sshport: String = "\"" + "-p " + String(self.config!.sshport!) + "\""
            self.args!.append(sshport)
        }
        remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
        self.args!.append(remotearg!)
         self.args!.append("\"")
        self.args!.append("mkdir ~/.ssh")
        self.command = "/usr/bin/ssh"
        self.commandCopyPasteTerminal = nil
        self.commandCopyPasteTerminal = self.command! + " " + self.args![0]
        for i in 1 ..< self.args!.count {
            self.commandCopyPasteTerminal = self.commandCopyPasteTerminal! + " " + self.args![i]
        }
        self.commandCopyPasteTerminal = self.commandCopyPasteTerminal! + "\""
    }

    private func scpport() {
        self.args!.append("-P")
        self.args!.append(String(self.config!.sshport!))
    }

    private func sshport() {
        self.args!.append("-p")
        self.args!.append(String(self.config!.sshport!))
    }

    // Set the correct arguments
    func getArguments(operation: SshOperations, key: String?, path: String?) -> Array<String>? {
        switch operation {
        case .checkKey:
            self.argumentsCheckRemotePubKey(key: key!)
        case .createKey:
            self.argumentsCreateKeys(path: path!, key: key!)
        case .scpKey:
            self.argumentsScpPubKey(path: path!, key: key!)
        case .createRemoteSshCatalog:
            self.argumentsCreateRemoteSshCatalog()
        case .chmod:
            self.argumentsChmod(key: key!)

        }
        return self.args
    }

    func getCommand() -> String? {
        guard self.command != nil else { return nil }
        return self.command
    }

    init(hiddenID: Int?) {
        if hiddenID != nil {
            self.config = self.configurations!.getConfigurations()[self.configurations!.getIndex(hiddenID!)]
        } else {
            self.config = nil
        }
    }
}
