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
    // Local public rsa and dsa based keys
    let rsaPubKey: String = "id_rsa.pub"
    let sshCatalog: String = ".ssh/"
    var rsaPubKeyExist: Bool = false
    // Full URL paths to local public keys
    var rsaURLpath: URL?
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

    // Create local rsa keys
    func createLocalKeysRsa() {
        guard self.rsaPubKeyExist == false else { return }
        self.scpArguments = ScpArgumentsSsh(hiddenID: nil, sshkeypathandidentityfile: (self.rootpath ?? "") +
            "/" + (self.identityfile ?? ""))
        self.arguments = scpArguments?.getArguments(operation: .createKey)
        self.command = self.scpArguments?.getCommand()
        self.executeSshCommand()
    }

    // Check for local public keys
    func checkForLocalPubKeys() {
        self.rsaPubKeyExist = self.isLocalPublicKeysPresent(key: self.rsaPubKey)
    }

    // Check if rsa and/or dsa is existing in local .ssh catalog
    func isLocalPublicKeysPresent(key: String) -> Bool {
        guard self.keyFileStrings != nil else { return false }
        guard self.keyFileStrings!.filter({ $0.contains(key) }).count > 0 else { return false }
        switch key {
        case rsaPubKey:
            self.rsaURLpath = URL(string: self.keyFileStrings!.filter { $0.contains(self.sshCatalog + key) }[0])
            self.rsaStringPath = self.keyFileStrings!.filter { $0.contains(self.sshCatalog + key) }[0]
        default:
            return false
        }
        return true
    }

    // Secure copy of public key from local to remote catalog
    func copykeyfile(hiddenID: Int) {
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: nil)
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
    func chmodSsh(key: String, hiddenID: Int) {
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: nil)
        self.arguments = scpArguments?.getArguments(operation: .chmod)
        self.command = self.scpArguments?.getCommand()
        self.chmod = ChmodPubKey(key: key)
    }

    // Execute command
    func executeSshCommand() {
        self.process = CommandSsh(command: self.command, arguments: self.arguments)
        self.process?.executeProcess(outputprocess: self.outputprocess!)
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
        self.checkForLocalPubKeys()
        self.createDirectory()
    }
}
