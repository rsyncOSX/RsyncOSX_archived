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
    var argumentsObject: CopyFileArguments?
    private var commandDisplay: String?
    var process: ProcessCmd?
    var outputprocess: OutputProcess?
    weak var sendprocess: SendProcessreference?

    func getOutput() -> [String] {
        return self.outputprocess?.getOutput() ?? []
    }

    func abort() {
        guard self.process != nil else { return }
        self.process!.abortProcess()
    }

    func executecopyfiles(remotefile: String, localCatalog: String, dryrun: Bool, updateprogress: UpdateProgress) {
        var arguments: [String]?
        guard self.config != nil else { return }
        if dryrun {
            self.argumentsObject = CopyFileArguments(task: .rsyncCmd, config: self.config!, remoteFile: remotefile,
                                                     localCatalog: localCatalog, drynrun: true)
            arguments = self.argumentsObject!.getArguments()
        } else {
            self.argumentsObject = CopyFileArguments(task: .rsyncCmd, config: self.config!, remoteFile: remotefile,
                                                     localCatalog: localCatalog, drynrun: false)
            arguments = self.argumentsObject!.getArguments()
        }
        self.outputprocess = OutputProcess()
        self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
        self.process = ProcessCmd(command: nil, arguments: arguments)
        self.process?.setupdateDelegate(object: updateprogress)
        self.process!.executeProcess(outputprocess: self.outputprocess)
    }

    func getCommandDisplayinView(remotefile: String, localCatalog: String) -> String {
        guard self.config != nil else { return "" }
        self.commandDisplay = CopyFileArguments(task: .rsyncCmd, config: self.config!, remoteFile: remotefile,
                                                localCatalog: localCatalog, drynrun: true).getcommandDisplay()
        return self.commandDisplay ?? ""
    }

    init (hiddenID: Int) {
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.index = self.configurations?.getIndex(hiddenID)
        self.config = self.configurations!.getConfigurations()[self.index!]
    }
  }
