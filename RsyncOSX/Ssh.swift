//
//  ssh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class Ssh: Catalogsandfiles {
    var commandCopyPasteTerminal: String?
    var rsaStringPath: String?
    // Arrays listing all key files
    var keyFileURLS: [URL]?
    var keyFileStrings: [String]?
    var argumentsssh: ArgumentsSsh?
    var command: String?
    var arguments: [String]?
    // Process
    var process: CommandSsh?
    var outputprocess: OutputProcess?

    // Create rsa keypair
    func creatersakeypair() {
        guard self.islocalpublicrsakeypresent() == false else { return }
        self.argumentsssh = ArgumentsSsh(hiddenID: nil, sshkeypathandidentityfile: (self.rootpath ?? "") +
            "/" + (self.identityfile ?? ""))
        self.arguments = argumentsssh?.getArguments(operation: .createKey)
        self.command = self.argumentsssh?.getCommand()
        self.executeSshCommand()
    }

    // Check if rsa pub key exists
    func islocalpublicrsakeypresent() -> Bool {
        guard self.keyFileStrings != nil else { return false }
        guard self.keyFileStrings!.filter({ $0.contains(self.identityfile ?? "") }).count > 0 else { return false }
        self.rsaStringPath = self.keyFileStrings!.filter { $0.contains((self.identityfile ?? "") + ".pub") }[0]
        guard self.rsaStringPath?.count ?? 0 > 0 else { return false }
        return true
    }

    // Secure copy of public key from local to remote catalog
    func copykeyfile(hiddenID: Int) {
        self.argumentsssh = ArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: (self.rootpath ?? "") +
            "/" + (self.identityfile ?? ""))
        self.arguments = argumentsssh?.getArguments(operation: .sshcopyid)
        self.commandCopyPasteTerminal = self.argumentsssh?.commandCopyPasteTerminal
    }

    // Check for remote pub keys
    func verifyremotekey(hiddenID: Int) {
        self.argumentsssh = ArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: (self.rootpath ?? "") +
            "/" + (self.identityfile ?? ""))
        self.arguments = argumentsssh?.getArguments(operation: .verifyremotekey)
        self.commandCopyPasteTerminal = self.argumentsssh?.commandCopyPasteTerminal
    }

    // Execute command
    func executeSshCommand() {
        guard self.arguments != nil else { return }
        self.process = CommandSsh(command: self.command, arguments: self.arguments)
        self.process?.executeProcess(outputprocess: self.outputprocess)
    }

    // get output
    func getOutput() -> [String]? {
        return self.outputprocess?.getOutput()
    }

    init(outputprocess: OutputProcess?) {
        super.init(profileorsshrootpath: .sshroot)
        self.outputprocess = outputprocess
        self.keyFileURLS = self.getcatalogsasURLnames()
        self.keyFileStrings = self.getfilesasstringnames()
        self.createprofilecatalog()
    }
}
