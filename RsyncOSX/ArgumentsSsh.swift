//
//  ArgumentsSsh.swift
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

    // Set parameters for ssh-copy-id for copy public ssh key to server
    // ssh-address = "backup@server.com"
    // ssh-copy-id -i $ssh-keypath -p port $ssh-address
    private func argumentssshcopyid() {
        guard config != nil else { return }
        guard (config?.offsiteServer.isEmpty ?? true) == false else { return }
        args = [String]()
        command = "/usr/bin/ssh-copy-id"
        args?.append(command ?? "")
        args?.append("-i")
        args?.append(globalsshkeypathandidentityfile ?? "")
        if SharedReference.shared.sshport != nil { sshport() }
        let usernameandservername = (config?.offsiteUsername ?? "") + "@" + (config?.offsiteServer ?? "")
        args?.append(usernameandservername)
        commandCopyPasteTerminal = args?.joined(separator: " ")
    }

    // Create local key with ssh-keygen
    // Generate a passwordless RSA keyfile -N sets password, "" makes it blank
    // ssh-keygen -t rsa -N "" -f $ssh-keypath
    private func argumentscreatekey() {
        args = [String]()
        args?.append("-t")
        args?.append("rsa")
        args?.append("-N")
        args?.append("")
        args?.append("-f")
        args?.append(globalsshkeypathandidentityfile ?? "")
        command = "/usr/bin/ssh-keygen"
    }

    // Check if pub key exists on remote server
    // ssh -p port -i $ssh-keypath $ssh-address
    private func argumentscheckremotepubkey() {
        guard config != nil else { return }
        guard (config?.offsiteServer.isEmpty ?? true) == false else { return }
        args = [String]()
        command = "/usr/bin/ssh"
        args?.append(command ?? "")
        if SharedReference.shared.sshport != nil { sshport() }
        args?.append("-i")
        args?.append(globalsshkeypathandidentityfile ?? "")
        let usernameandservername = (config?.offsiteUsername ?? "") + "@" + (config?.offsiteServer ?? "")
        args?.append(usernameandservername)
        commandCopyPasteTerminal = args?.joined(separator: " ")
    }

    private func sshport() {
        args?.append("-p")
        args?.append(String(SharedReference.shared.sshport ?? 22))
    }

    // Set the correct arguments
    func getArguments(operation: SshOperations) -> [String]? {
        switch operation {
        case .verifyremotekey:
            argumentscheckremotepubkey()
        case .createKey:
            argumentscreatekey()
        case .sshcopyid:
            argumentssshcopyid()
        }
        return args
    }

    func getCommand() -> String? {
        return command
    }

    init(hiddenID: Int?, sshkeypathandidentityfile: String?) {
        if let hiddenID = hiddenID {
            config = configurations?.getConfigurations()?[configurations?.getIndex(hiddenID) ?? -1]
        }
        globalsshkeypathandidentityfile = sshkeypathandidentityfile ?? ""
    }
}
