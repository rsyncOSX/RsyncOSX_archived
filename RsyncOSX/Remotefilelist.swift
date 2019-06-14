//
//  Remotefilelist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 14/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class Remotefilelist: ProcessCmd, SetConfigurations {

    var outputprocess: OutputProcess?
    var config: Configuration?
    var argumentsobject: CopyFileArguments?
    var remotefilelist: [String]?
    weak var setremotefilelistDelegate: Updateremotefilelist?

    init(hiddenID: Int) {
        super.init(command: nil, arguments: nil)
        let index = self.configurations?.getIndex(hiddenID) ?? -1
        self.config = self.configurations!.getConfigurations()[index]
        self.outputprocess = OutputProcess()
        self.argumentsobject = CopyFileArguments(task: .rsyncCmdFileListings, config: self.config!,
                                remoteFile: nil, localCatalog: nil, drynrun: nil)
        self.arguments = self.argumentsobject!.getArguments()
        self.command = self.argumentsobject!.getCommand()
        self.updateDelegate = self
        self.setremotefilelistDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
        self.executeProcess(outputprocess: self.outputprocess)
    }
}

extension Remotefilelist: UpdateProgress {
    func processTermination() {
        self.remotefilelist = self.outputprocess?.trimoutput(trim: .one)
        self.setremotefilelistDelegate?.updateremotefilelist()
    }

    func fileHandler() {
        // nothing
    }
}
