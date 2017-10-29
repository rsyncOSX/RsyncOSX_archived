//
//  scpNSTaskArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27/06/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

enum Enumscopyfiles {
    case rsyncCmd
    case duCmd
}

final class CopyFileArguments: ProcessArguments {

    private var file: String?
    private var arguments: Array<String>?
    private var argDisplay: String?
    private var command: String?
    private var config: Configuration?

    func getArguments() -> Array<String>? {
        return self.arguments
    }

    func getCommand() -> String? {
        return self.command
    }

    func getcommandDisplay() -> String {
        guard self.argDisplay != nil else {
            return ""
        }
        return self.argDisplay!
    }

    init (task: Enumscopyfiles, config: Configuration, remoteFile: String?, localCatalog: String?, drynrun: Bool?) {
        self.arguments = nil
        self.arguments = Array<String>()
        self.config = config
        switch task {
        case .rsyncCmd:
            let arguments = RsyncArguments(config: config, remoteFile: remoteFile,
                                           localCatalog: localCatalog, drynrun: drynrun)
            self.arguments = arguments.getArguments()
            self.command = arguments.getCommand()
            self.argDisplay = arguments.getArgumentsDisplay()
        case .duCmd:
            let arguments = GetRemoteFilesArguments(config: config)
            self.arguments = arguments.getArguments()
            self.command = arguments.getCommand()
        }
    }
}
