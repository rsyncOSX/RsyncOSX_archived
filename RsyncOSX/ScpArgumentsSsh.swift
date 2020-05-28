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
    case checkKey
    case createKey
    case createRemoteSshCatalog
    case chmod
}

/*

 Here are the ssh commands to make this method work:
 $ssh-keypath = "~/Documents/Rsync/testkey"
 (you could also put it in .ssh, but I think that actually might not always be something the user wants)

 $ssh-address = "backup@server.com"
 $ssh-options = ""

 Generate a passwordless RSA keyfile (-N sets password, "" makes it blank - i tested this and it works)
 ssh-keygen -t rsa -N "" -f $ssh-keypath
 copy to server
 ssh-copy-id -i $ssh-keypath $ssh-address
 test if keys are there (unnecessary in my opinion)
 ssh-copy-id -n -i $ssh-keypath $ssh-address
 connect via ssh
 ssh $ssh-options -i $ssh-keypath $ssh-address

 */

final class ScpArgumentsSsh: SetConfigurations {
    var commandCopyPasteTerminal: String?
    private var config: Configuration?
    private var args: [String]?
    private var command: String?
    private var remoteRsaPubkeyString: String = ".ssh/authorized_keys"
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
        if ViewControllerReference.shared.sshport != nil { self.sshport() }
        self.args?.append("-i")
        self.args?.append(self.globalsshkeypathandidentityfile ?? "")
        let usernameandservername = (self.config?.offsiteUsername ?? "") + "@" + (self.config?.offsiteServer ?? "")
        self.args?.append(usernameandservername)
        self.command = "/usr/bin/ssh"
    }

    // Chmod .ssh catalog
    // either ssh or ssh "-p port"
    private func argumentsChmod() {
        var remotearg: String?
        guard self.config != nil else { return }
        guard self.config!.offsiteServer.isEmpty == false else { return }
        self.args = [String]()
        if ViewControllerReference.shared.sshport != nil { self.sshport() }
        remotearg = (self.config?.offsiteUsername ?? "") + "@" + (self.config?.offsiteServer ?? "")
        self.args?.append(remotearg!)
        self.args?.append("chmod 700 ~/.ssh; chmod 600 ~/" + self.remoteRsaPubkeyString)
        self.command = "/usr/bin/ssh"
    }

    //  Create remote catalog
    // either ssh or ssh "-p port"
    private func argumentsCreateRemoteSshCatalog() {
        var remotearg: String?
        guard self.config != nil else { return }
        guard (self.config?.offsiteServer.isEmpty ?? true) == false else { return }
        self.args = [String]()
        self.command = "/usr/bin/ssh"
        self.args?.append(self.command ?? "")
        if ViewControllerReference.shared.sshport != nil {
            let sshport: String = "\"" + "-p " + String(ViewControllerReference.shared.sshport ?? 22) + "\""
            self.args?.append(sshport)
        }
        remotearg = (self.config?.offsiteUsername ?? "") + "@" + (self.config?.offsiteServer ?? "")
        self.args?.append(remotearg!)
        self.args?.append("\"")
        self.args?.append("mkdir ~/.ssh")
        self.commandCopyPasteTerminal = self.args?.joined(separator: " ")
        self.commandCopyPasteTerminal = self.commandCopyPasteTerminal! + "\""
    }

    private func sshport() {
        self.args?.append("-p")
        self.args?.append(String(ViewControllerReference.shared.sshport ?? 22))
    }

    // Set the correct arguments
    func getArguments(operation: SshOperations) -> [String]? {
        switch operation {
        case .checkKey:
            self.argumentscheckremotepubkey()
        case .createKey:
            self.argumentscreatekey()
        case .sshcopyid:
            self.argumentssshcopyid()
        case .createRemoteSshCatalog:
            self.argumentsCreateRemoteSshCatalog()
        case .chmod:
            self.argumentsChmod()
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
