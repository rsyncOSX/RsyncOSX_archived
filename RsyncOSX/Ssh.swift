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
    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void
    var commandCopyPasteTerminal: String?
    var rsaStringPath: String?
    // Arrays listing all key files
    var keyFileStrings: [String]?
    var argumentsssh: ArgumentsSsh?
    var command: String?
    var arguments: [String]?
    var outputprocess: OutputfromProcess?

    // Create rsa keypair
    func creatersakeypair() {
        guard islocalpublicrsakeypresent() == false else { return }
        argumentsssh = ArgumentsSsh(hiddenID: nil, sshkeypathandidentityfile: (fullpathsshkeys ?? "") +
            "/" + (identityfile ?? ""))
        arguments = argumentsssh?.getArguments(operation: .createKey)
        command = argumentsssh?.getCommand()
        executeSshCommand()
    }

    // Check if rsa pub key exists
    func islocalpublicrsakeypresent() -> Bool {
        guard keyFileStrings != nil else { return false }
        guard keyFileStrings?.filter({ $0.contains(self.identityfile ?? "") }).count ?? 0 > 0 else { return false }
        guard keyFileStrings?.filter({ $0.contains((self.identityfile ?? "") + ".pub") }).count ?? 0 > 0 else {
            return true
        }
        rsaStringPath = keyFileStrings?.filter { $0.contains((self.identityfile ?? "") + ".pub") }[0]
        guard rsaStringPath?.count ?? 0 > 0 else { return false }
        return true
    }

    // Secure copy of public key from local to remote catalog
    func copykeyfile(hiddenID: Int) {
        argumentsssh = ArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: (fullpathsshkeys ?? "") +
            "/" + (identityfile ?? ""))
        arguments = argumentsssh?.getArguments(operation: .sshcopyid)
        commandCopyPasteTerminal = argumentsssh?.commandCopyPasteTerminal
    }

    // Check for remote pub keys
    func verifyremotekey(hiddenID: Int) {
        argumentsssh = ArgumentsSsh(hiddenID: hiddenID, sshkeypathandidentityfile: (fullpathsshkeys ?? "") +
            "/" + (identityfile ?? ""))
        arguments = argumentsssh?.getArguments(operation: .verifyremotekey)
        commandCopyPasteTerminal = argumentsssh?.commandCopyPasteTerminal
    }

    // Execute command
    func executeSshCommand() {
        guard arguments != nil else { return }
        let process = OtherProcess(command: command,
                                   arguments: arguments,
                                   processtermination: processtermination,
                                   filehandler: filehandler)
        process.executeProcess(outputprocess: outputprocess)
    }

    init(outputprocess: OutputfromProcess?,
         processtermination: @escaping () -> Void,
         filehandler: @escaping () -> Void)
    {
        self.processtermination = processtermination
        self.filehandler = filehandler
        super.init(.ssh)
        self.outputprocess = outputprocess
        keyFileStrings = getfullpathsshkeys()
        createsshkeyrootpath()
    }
}
