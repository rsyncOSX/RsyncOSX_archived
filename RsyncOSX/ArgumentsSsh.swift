//
//  scpArgumentsSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum SshOperations {
    case sshcopyid
    case verifyremotekey
    case createKey
}

final class ArgumentsSsh: SetConfigurations {
    var commandCopyPasteTerminal: String?
    private var config: Configuration?
    private var args: [String]?
    private var command: String?
    private var globalsshkeypathandidentityfile: String?
    private var globalsshport: String?

    // Set parameters for ssh-copy-id for copy public ssh key to server
    // ssh-address = "backup@server.com"
    // ssh-copy-id -i $ssh-keypath -p port $ssh-address
    private func argumentssshcopyid() {
        guard self.config != nil else { return }
        guard (self.config?.offsiteServer.isEmpty ?? true) == false else { return }
        self.args = [String]()
        self.command = "/usr/bin/ssh-copy-id"
        self.args?.append(self.command ?? "")
        self.args?.append("-i")
        self.args?.append(self.globalsshkeypathandidentityfile ?? "")
        if ViewControllerReference.shared.sshport != nil { self.sshport() }
        let usernameandservername = (self.config?.offsiteUsername ?? "") + "@" + (self.config?.offsiteServer ?? "")
        self.args?.append(usernameandservername)
        self.commandCopyPasteTerminal = self.args?.joined(separator: " ")
    }

    // Create local key with ssh-keygen
    // Generate a passwordless RSA keyfile -N sets password, "" makes it blank
    // ssh-keygen -t rsa -N "" -f $ssh-keypath
    private func argumentscreatekey() {
        self.args = [String]()
        self.args?.append("-t")
        self.args?.append("rsa")
        self.args?.append("-N")
        self.args?.append("")
        self.args?.append("-f")
        self.args?.append(self.globalsshkeypathandidentityfile ?? "")
        self.command = "/usr/bin/ssh-keygen"
    }

    // Check if pub key exists on remote server
    // ssh -p port -i $ssh-keypath $ssh-address
    private func argumentscheckremotepubkey() {
        guard self.config != nil else { return }
        guard (self.config?.offsiteServer.isEmpty ?? true) == false else { return }
        self.args = [String]()
        self.command = "/usr/bin/ssh"
        self.args?.append(self.command ?? "")
        if ViewControllerReference.shared.sshport != nil { self.sshport() }
        self.args?.append("-i")
        self.args?.append(self.globalsshkeypathandidentityfile ?? "")
        let usernameandservername = (self.config?.offsiteUsername ?? "") + "@" + (self.config?.offsiteServer ?? "")
        self.args?.append(usernameandservername)
        self.commandCopyPasteTerminal = self.args?.joined(separator: " ")
    }

    private func sshport() {
        self.args?.append("-p")
        self.args?.append(String(ViewControllerReference.shared.sshport ?? 22))
    }

    // Set the correct arguments
    func getArguments(operation: SshOperations) -> [String]? {
        switch operation {
        case .verifyremotekey:
            self.argumentscheckremotepubkey()
        case .createKey:
            self.argumentscreatekey()
        case .sshcopyid:
            self.argumentssshcopyid()
        }
        return self.args
    }

    func getCommand() -> String? {
        return self.command
    }

    init(hiddenID: Int?, sshkeypathandidentityfile: String?) {
        if let hiddenID = hiddenID {
            self.config = self.configurations?.getConfigurations()[self.configurations?.getIndex(hiddenID) ?? -1]
        }
        self.globalsshkeypathandidentityfile = sshkeypathandidentityfile ?? ""
        if let sshport = ViewControllerReference.shared.sshport {
            self.globalsshport = String(sshport)
        }
    }
}
