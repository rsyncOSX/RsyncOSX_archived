//
//  scpNSTaskArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27/06/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

enum Enumscopyfiles {
    case rsyncCmd
    case rsyncCmdFileListings
    case snapshotcatalogs
}

final class CopyFileArguments: ProcessArguments {

    private var file: String?
    private var arguments: [String]?
    private var argDisplay: String?
    private var command: String?
    private var config: Configuration?

    func getArguments() -> [String]? {
        return self.arguments
    }

    func getCommand() -> String? {
        return self.command
    }

    func getcommandDisplay() -> String {
        guard self.argDisplay != nil else { return "" }
        return self.argDisplay!
    }

    init (task: Enumscopyfiles, config: Configuration, remoteFile: String?, localCatalog: String?, drynrun: Bool?) {
        self.arguments = [String]()
        self.config = config
        switch task {
        case .rsyncCmd:
            let arguments = RsyncParametersSingleFilesArguments(config: config, remoteFile: remoteFile, localCatalog: localCatalog, drynrun: drynrun)
            self.arguments = arguments.getArguments()
            self.command = arguments.getCommand()
            self.argDisplay = arguments.getArgumentsDisplay()
        case .rsyncCmdFileListings:
            let arguments = GetRemoteFileListingsArguments(config: config, recursive: true)
            self.arguments = arguments.getArguments()
            self.command = arguments.getCommand()
        case .snapshotcatalogs:
            let arguments = GetRemoteFileListingsArguments(config: config, recursive: false)
            self.arguments = arguments.getArguments()
            self.command = arguments.getCommand()
        }
    }
}
