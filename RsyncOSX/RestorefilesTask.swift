//
//  CopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class RestorefilesTask: SetConfigurations {
    private var config: Configuration?
    private var commandDisplay: String?
    var process: RsyncProcessCmdClosure?
    var outputprocess: OutputProcess?
    weak var sendprocess: SendOutputProcessreference?

    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void

    func getOutput() -> [String] {
        return self.outputprocess?.getOutput() ?? []
    }

    func abort() {
        self.process?.abortProcess()
    }

    func executecopyfiles(remotefile: String, localCatalog: String, dryrun: Bool) {
        if let config = self.config {
            let arguments = RestorefilesArguments(task: .rsync, config: config, remoteFile: remotefile,
                                                  localCatalog: localCatalog, drynrun: dryrun).getArguments()
            self.outputprocess = OutputProcessRsync()
            self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
            self.process = RsyncProcessCmdClosure(arguments: arguments, config: nil, processtermination: self.processtermination, filehandler: self.filehandler)
            self.process?.executeProcess(outputprocess: self.outputprocess)
        }
    }

    init(hiddenID: Int, processtermination: @escaping () -> Void, filehandler: @escaping () -> Void) {
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.processtermination = processtermination
        self.filehandler = filehandler
        if let index = self.configurations?.getIndex(hiddenID) {
            self.config = self.configurations?.getConfigurations()?[index]
        }
    }
}
