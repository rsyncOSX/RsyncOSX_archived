//
//  Remotefilelist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 14/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class Remotefilelist: SetConfigurations {
    var config: Configuration?
    var remotefilelist: [String]?
    var outputprocess: OutputfromProcess?
    weak var setremotefilelistDelegate: Updateremotefilelist?
    weak var outputeverythingDelegate: ViewOutputDetails?

    init(hiddenID: Int) {
        setremotefilelistDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        outputeverythingDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if let index = configurations?.getIndex(hiddenID) {
            config = configurations?.getConfigurations()?[index]
            outputprocess = OutputfromProcess()
            let arguments = RestorefilesArguments(task: .rsyncfilelistings,
                                                  config: config,
                                                  remoteFile: nil,
                                                  localCatalog: nil,
                                                  drynrun: nil).getArguments()
            let command = RsyncProcess(arguments: arguments,
                                       config: config,
                                       processtermination: processtermination,
                                       filehandler: filehandler)
            command.executeProcess(outputprocess: outputprocess)
        }
    }
}

extension Remotefilelist {
    func processtermination() {
        remotefilelist = TrimOne(outputprocess?.getOutput() ?? []).trimmeddata
        setremotefilelistDelegate?.updateremotefilelist()
    }

    func filehandler() {
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
