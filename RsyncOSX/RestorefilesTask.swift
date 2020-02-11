//
//  CopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class RestorefilesTask: SetConfigurations {
    private var index: Int?
    private var config: Configuration?
    private var commandDisplay: String?
    var process: ProcessCmd?
    var outputprocess: OutputProcess?
    weak var sendprocess: SendProcessreference?

    func getOutput() -> [String] {
        return self.outputprocess?.getOutput() ?? []
    }

    func abort() {
        self.process?.abortProcess()
    }

    func executecopyfiles(remotefile: String, localCatalog: String, dryrun: Bool, updateprogress: UpdateProgress) {
        var arguments: [String]?
        guard self.config != nil else { return }
        arguments = CopyFilesArguments(task: .rsync, config: self.config!, remoteFile: remotefile,
                                       localCatalog: localCatalog, drynrun: dryrun).getArguments()
        self.outputprocess = OutputProcess()
        self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
        self.process = ProcessCmd(command: nil, arguments: arguments)
        self.process?.setupdateDelegate(object: updateprogress)
        self.process?.executeProcess(outputprocess: self.outputprocess)
    }

    init(hiddenID: Int) {
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.index = self.configurations?.getIndex(hiddenID)
        self.config = self.configurations!.getConfigurations()[self.index!]
    }
}
