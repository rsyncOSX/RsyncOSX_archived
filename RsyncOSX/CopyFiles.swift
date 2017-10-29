//
//  CopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

final class CopyFiles: SetConfigurations {

    private var index: Int?
    private var config: Configuration?
    private var files: Array<String>?
    private var arguments: Array<String>?
    private var command: String?
    var argumentsObject: CopyFileArguments?
    private var argumentsRsync: Array<String>?
    private var argymentsRsyncDrynRun: Array<String>?
    private var commandDisplay: String?
    weak var progressDelegate: StartStopProgressIndicator?
    var process: CommandCopyFiles?
    var output: OutputProcess?

    func getOutput() -> Array<String> {
        return self.output?.getOutput() ?? [""]
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
        self.command = nil
        self.output = nil
        self.output = OutputProcess()
        self.process = CommandCopyFiles(command: nil, arguments: self.arguments)
        self.process!.executeProcess(output: self.output)
    }

    func getCommandDisplayinView(remotefile: String, localCatalog: String) -> String {
        guard self.config != nil else {
            return ""
        }
        self.commandDisplay = CopyFileArguments(task: .rsyncCmd, config: self.config!, remoteFile: remotefile,
                                                localCatalog: localCatalog, drynrun: true).getcommandDisplay()
        guard self.commandDisplay != nil else { return "" }
        return self.commandDisplay!
    }

    private func getRemoteFileList() {
        self.output = nil
        self.output = OutputProcess()
        self.argumentsObject = CopyFileArguments(task: .duCmd, config: self.config!, remoteFile: nil,
                                                 localCatalog: nil, drynrun: nil)
        self.arguments = self.argumentsObject!.getArguments()
        self.command = self.argumentsObject!.getCommand()
        self.process = CommandCopyFiles(command: self.command, arguments: self.arguments)
        self.process!.executeProcess(output: self.output)
    }

    func setRemoteFileList() {
        self.files = self.output?.trimoutput(trim: .one)
    }

    func filter(search: String?) -> Array<String> {
        guard search != nil else {
            if self.files != nil {
                return self.files!
            } else {
              return [""]
            }
        }
        if search!.isEmpty == false {
            return self.files!.filter({$0.contains(search!)})
        } else {
            return self.files!
        }
    }

    init (index: Int) {
        self.index = index
        self.config = self.configurations!.getConfigurations()[self.index!]
        self.getRemoteFileList()
    }

  }
