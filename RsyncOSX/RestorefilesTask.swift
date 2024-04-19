//
//  RestorefilesTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class RestorefilesTask: SetConfigurations {
    private var config: Configuration?
    var process: RsyncProcess?
    var outputprocess: OutputfromProcess?
    weak var sendprocess: SendOutputProcessreference?

    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void

    func executecopyfiles(remotefile: String, localCatalog: String, dryrun: Bool) {
        if let config = config {
            let arguments = RestorefilesArguments(task: .rsync, config: config, remoteFile: remotefile,
                                                  localCatalog: localCatalog, drynrun: dryrun).getArguments()
            outputprocess = OutputfromProcessRsync()
            sendprocess?.sendoutputprocessreference(outputprocess: outputprocess)
            process = RsyncProcess(arguments: arguments, config: nil, processtermination: processtermination, filehandler: filehandler)
            process?.executeProcess(outputprocess: outputprocess)
        }
    }

    init(hiddenID: Int, processtermination: @escaping () -> Void, filehandler: @escaping () -> Void) {
        sendprocess = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.processtermination = processtermination
        self.filehandler = filehandler
        if let index = configurations?.getIndex(hiddenID) {
            config = configurations?.getConfigurations()?[index]
        }
    }
}
