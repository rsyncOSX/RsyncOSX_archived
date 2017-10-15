//
//  ssh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation
import Cocoa

class Ssh: Files {

    var commandCopyPasteTermninal: String?

    // Local public rsa and dsa based keys
    let rsaPubKey: String = "id_rsa.pub"
    let dsaPubKey: String = "id_dsa.pub"
    let sshCatalog: String = ".ssh/"
    var dsaPubKeyExist: Bool = false
    var rsaPubKeyExist: Bool = false

    // Full URL paths to local public keys
    var rsaURLpath: URL?
    var dsaURLpath: URL?
    // Full String paths to local public keys
    var rsaStringPath: String?
    var dsaStringPath: String?

    // Arrays listing all key files
    var keyFileURLS: Array<URL>?
    var keyFileStrings: Array<String>?

    var scpArguments: ScpArgumentsSsh?
    var command: String?
    var arguments: Array<String>?

    // Process
    var process: CommandSsh?
    var output: OutputProcess?

    // Chmod
    var chmod: ChmodPubKey?

    // Create local rsa keys
    func createLocalKeysRsa() {
        guard self.rsaPubKeyExist == false else {
            return
        }
        self.scpArguments = nil
        self.scpArguments = ScpArgumentsSsh(hiddenID: nil)
        self.arguments = scpArguments!.getArguments(operation: .createKey, key: "rsa", path: self.rootpath)
        self.command = self.scpArguments!.getCommand()
        self.executeSshCommand()
    }

    // Create local dsa keys
    func createLocalKeysDsa() {
        guard self.dsaPubKeyExist == false else {
            return
        }
        self.scpArguments = nil
        self.scpArguments = ScpArgumentsSsh(hiddenID: nil)
        self.arguments = scpArguments!.getArguments(operation: .createKey, key: "dsa", path: self.rootpath)
        self.command = self.scpArguments!.getCommand()
        self.executeSshCommand()
    }

    // Check for local public keys
    func checkForLocalPubKeys() {
        self.dsaPubKeyExist = self.isLocalPublicKeysPresent(key: self.dsaPubKey)
        self.rsaPubKeyExist = self.isLocalPublicKeysPresent(key: self.rsaPubKey)
    }

    // Check if rsa and/or dsa is existing in local .ssh catalog
    func isLocalPublicKeysPresent (key: String) -> Bool {
        guard self.keyFileStrings != nil else {
            return false
        }
        guard self.keyFileStrings!.filter({$0.contains(key)}).count > 0 else {
            return false
        }
        switch key {
        case rsaPubKey:
            self.rsaURLpath = URL(string: self.keyFileStrings!.filter({$0.contains(self.sshCatalog + key)})[0])
            self.rsaStringPath = self.keyFileStrings!.filter({$0.contains(self.sshCatalog + key)})[0]
        case dsaPubKey:
            self.dsaURLpath = URL(string: self.keyFileStrings!.filter({$0.contains(self.sshCatalog + key)})[0])
            self.dsaStringPath = self.keyFileStrings!.filter({$0.contains(self.sshCatalog + key)})[0]
        default:
            return false
        }
        return true
    }

    // Secure copy of public key from local to remote catalog
    func scpPubKey(key: String, hiddenID: Int) {
        self.scpArguments = nil
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID)
        switch key {
        case "rsa":
            guard self.rsaStringPath != nil else {
                return
            }
            self.arguments = scpArguments!.getArguments(operation: .scpKey, key: key, path: self.rsaStringPath!)
        case "dsa":
            guard self.dsaStringPath != nil else {
                return
            }
            self.arguments = scpArguments!.getArguments(operation: .scpKey, key: key, path: self.dsaStringPath!)
        default:
            break
        }
        self.command = self.scpArguments!.getCommand()
        self.commandCopyPasteTermninal = self.scpArguments!.commandCopyPasteTermninal
    }

    // Check for remote pub keys
    func checkRemotePubKey(key: String, hiddenID: Int) {
        self.scpArguments = nil
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID)
        switch key {
        case "rsa":
            guard self.rsaStringPath != nil else {
                return
            }
            self.arguments = scpArguments!.getArguments(operation: .checkKey, key: key, path: nil)
        case "dsa":
            guard self.dsaStringPath != nil else {
                return
            }
            self.arguments = scpArguments!.getArguments(operation: .checkKey, key: key, path: nil)
        default:
            break
        }
        self.command = self.scpArguments!.getCommand()
    }

    // Create remote ssh directory
    func createSshRemoteDirectory(hiddenID: Int) {
        self.scpArguments = nil
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID)
        self.arguments = scpArguments!.getArguments(operation: .createRemoteSshCatalog, key: nil, path: nil)
        self.command = self.scpArguments!.getCommand()
        self.commandCopyPasteTermninal = self.scpArguments!.commandCopyPasteTermninal
    }

    // Chmod remote .ssh directory
    func chmodSsh(key: String, hiddenID: Int) {
        self.scpArguments = nil
        self.scpArguments = ScpArgumentsSsh(hiddenID: hiddenID)
        self.arguments = scpArguments!.getArguments(operation: .chmod, key: key, path: nil)
        self.command = self.scpArguments!.getCommand()
        self.chmod = ChmodPubKey(key: key)
    }

    // Execute command
    func executeSshCommand() {
        self.process = CommandSsh(command: self.command, arguments: self.arguments)
        self.process!.executeProcess(output: self.output!)
    }

    // get output
    func getOutput() -> Array<String>? {
        return self.output?.getOutput()
    }

    // Open Terminal.app
    func openTerminal() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/Applications/Utilities/Terminal.app"))
    }

    init(output: OutputProcess?) {
        super.init(root: .sshRoot)
        self.output = output
        self.keyFileURLS = self.getFilesURLs()
        self.keyFileStrings = self.getFileStrings()
        self.checkForLocalPubKeys()
        self.createDirectory()
    }

}
