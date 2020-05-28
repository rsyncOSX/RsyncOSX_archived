//
//  ssh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class Ssh: Files {
    var commandCopyPasteTermninal: String?
    // Full String paths to local public keys
    var rsaStringPath: String?
    // Arrays listing all key files
    var keyFileURLS: [URL]?
    var keyFileStrings: [String]?
    var scpArguments: ScpArgumentsSsh?
    var command: String?
    var arguments: [String]?
    // Process
    var process: CommandSsh?
    var outputprocess: OutputProcess?
    // Chmod
    var chmod: ChmodPubKey?

    // Create rsa keypair
    func creatersakeypair() {
        guard self.islocalpublicrsakeypresent() == false else { return }
        self.scpArguments = ScpArgumentsSsh(hiddenID: nil, sshkeypathandidentityfile: (self.rootpath ?? "") +
            "/" + (self.identityfile ?? ""))
        self.arguments = scpArguments?.getArguments(operation: .createKey)
        self.command = self.scpArguments?.getCommand()
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
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: (self.rootpath ?? "") +
            "/" + (self.identityfile ?? ""))
        self.arguments = scpArguments?.getArguments(operation: .sshcopyid)
        self.command = self.scpArguments?.getCommand()
        self.commandCopyPasteTermninal = self.scpArguments?.commandCopyPasteTerminal
    }

    // Check for remote pub keys
    func checkRemotePubKey(hiddenID: Int) {
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: nil)
        guard self.rsaStringPath != nil else { return }
        self.arguments = scpArguments?.getArguments(operation: .checkKey)
        self.command = self.scpArguments?.getCommand()
    }

    // Create remote ssh directory
    func createSshRemoteDirectory(hiddenID: Int) {
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: nil)
        self.arguments = scpArguments?.getArguments(operation: .createRemoteSshCatalog)
        self.command = self.scpArguments?.getCommand()
        self.commandCopyPasteTermninal = self.scpArguments?.commandCopyPasteTerminal
    }

    // Chmod remote .ssh directory
    func chmodSsh(hiddenID: Int) {
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: nil)
        self.arguments = scpArguments?.getArguments(operation: .chmod)
        self.command = self.scpArguments?.getCommand()
        self.chmod = ChmodPubKey()
    }

    // Execute command
    func executeSshCommand() {
        self.process = CommandSsh(command: self.command, arguments: self.arguments)
        self.process?.executeProcess(outputprocess: self.outputprocess)
    }

    // get output
    func getOutput() -> [String]? {
        return self.outputprocess?.getOutput()
    }

    init(outputprocess: OutputProcess?) {
        super.init(whichroot: .sshRoot, configpath: ViewControllerReference.shared.configpath)
        self.outputprocess = outputprocess
        self.keyFileURLS = self.getFilesURLs()
        self.keyFileStrings = self.getFileStrings()
        self.createDirectory()
    }
}
