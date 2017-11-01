//
//  rsyncArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

class RsyncArguments: ProcessArguments {

    let archive: String = "--archive"
    let verbose: String = "--verbose"
    let compress: String = "--compress"
    let delete: String = "--delete"
    let eparam: String = "-e"
    let ssh: String = "ssh"
    let sshp: String = "ssh -p"
    let dryrun: String = "--dry-run"

    private var config: Configuration?
    private var args: Array<String>?
    private var command: String?
    private var file: String?
    private var argDisplay: String?

    // Set parameters for rsync
    private func arguments(remoteFile: String?, localCatalog: String?, drynrun: Bool?) {

        if let config = self.config {
            // Drop the two first characeters ("./") as result from the find . -name
            let remote_with_whitespace: String = String(remoteFile!.dropFirst(2))
            // Replace remote for white spaces
            let whitespace: String = "\\ "
            let remote = remote_with_whitespace.replacingOccurrences(of: " ", with: whitespace)
            let local: String = localCatalog!
            if config.sshport != nil {
                self.args!.append(self.eparam)
                self.args!.append(self.sshp + String(config.sshport!))
            } else {
                self.args!.append(self.eparam)
                self.args!.append(self.ssh)
            }
            self.args!.append(self.archive)
            self.args!.append(self.verbose)
            // If copy over network compress files
            if config.offsiteServer.isEmpty {
                self.args!.append(self.compress)
            }
            // Set dryrun or not
            if drynrun != nil {
                if drynrun == true {
                    self.args!.append(self.dryrun)
                }
            }
            if config.offsiteServer.isEmpty {
                self.args!.append(config.offsiteCatalog + remote)
            } else {
                let rarg = config.offsiteUsername + "@" + config.offsiteServer + ":" + config.offsiteCatalog + remote
                self.args!.append(rarg)
            }
            self.args!.append(local)
            // Set command to Process /usr/bin/rysnc or /usr/local/bin/rsync
            // or other set by userconfiguration
            self.command = Tools().rsyncpath()
            // Prepare the display version of arguments
            self.argDisplay = self.command! + " "
            for i in 0 ..< self.args!.count {
                self.argDisplay = self.argDisplay!  + self.args![i] + " "
            }
        }
    }

    func getArguments() -> Array<String>? {
        return self.args
    }

    func getArgumentsDisplay() -> String? {
        return self.argDisplay
    }

    func getCommand() -> String? {
        return self.command
    }

    init(config: Configuration, remoteFile: String?, localCatalog: String?, drynrun: Bool?) {
        self.config = config
        // Initialize the argument array
        self.args = nil
        self.args = Array<String>()
        self.arguments(remoteFile: remoteFile, localCatalog: localCatalog, drynrun: drynrun)
    }
}
