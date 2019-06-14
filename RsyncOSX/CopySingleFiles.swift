//
//  CopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class CopySingleFiles: SetConfigurations {

    private var index: Int?
    private var config: Configuration?
    private var remotefilelist: [String]?
    private var arguments: [String]?
    private var command: String?
    var argumentsObject: CopyFileArguments?
    private var commandDisplay: String?
    var process: CommandCopyFiles?
    var outputprocess: OutputProcess?

    func getOutput() -> [String] {
        return self.outputprocess?.getOutput() ?? [""]
    }

    func abort() {
        guard self.process != nil else { return }
        self.process!.abortProcess()
    }

    func executeRsync(remotefile: String, localCatalog: String, dryrun: Bool) {
        guard self.config != nil else { return }
        if dryrun {
            self.argumentsObject = CopyFileArguments(task: .rsyncCmd, config: self.config!, remoteFile: remotefile,
                                                     localCatalog: localCatalog, drynrun: true)
            self.arguments = self.argumentsObject!.getArguments()
        } else {
            self.argumentsObject = CopyFileArguments(task: .rsyncCmd, config: self.config!, remoteFile: remotefile,
                                                     localCatalog: localCatalog, drynrun: false)
            self.arguments = self.argumentsObject!.getArguments()
        }
        self.outputprocess = OutputProcess()
        self.process = CommandCopyFiles(command: nil, arguments: self.arguments)
        self.process!.executeProcess(outputprocess: self.outputprocess)
    }

    func getCommandDisplayinView(remotefile: String, localCatalog: String) -> String {
        guard self.config != nil else { return "" }
        self.commandDisplay = CopyFileArguments(task: .rsyncCmd, config: self.config!, remoteFile: remotefile,
                                                localCatalog: localCatalog, drynrun: true).getcommandDisplay()
        guard self.commandDisplay != nil else { return "" }
        return self.commandDisplay!
    }

    init (hiddenID: Int) {
        self.index = self.configurations?.getIndex(hiddenID)
        self.config = self.configurations!.getConfigurations()[self.index!]
    }

  }
