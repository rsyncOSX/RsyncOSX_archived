//
//  Remotefilelist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 14/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class Remotefilelist: SetConfigurations, Presentoutput {
    var config: Configuration?
    var remotefilelist: [String]?
    weak var setremotefilelistDelegate: Updateremotefilelist?

    @MainActor
    private func getfilelist(arguments: [String]) async {
        let command = RsyncAsync(arguments: arguments,
                                 processtermination: processtermination)
        await command.executeProcess()
    }

    init(hiddenID: Int) {
        setremotefilelistDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        if let index = configurations?.getIndex(hiddenID) {
            config = configurations?.getConfigurations()?[index]
            let arguments = RestorefilesArguments(task: .rsyncfilelistings,
                                                  config: config,
                                                  remoteFile: nil,
                                                  localCatalog: nil,
                                                  drynrun: nil).getArguments()
            guard arguments != nil else { return }
            Task {
                await getfilelist(arguments: arguments ?? [])
            }
        }
    }
}

extension Remotefilelist {
    func processtermination(data: [String]?) {
        remotefilelist = TrimOne(data ?? []).trimmeddata
        setremotefilelistDelegate?.updateremotefilelist()
        presentoutputfromrsync(data: data)
    }
}

protocol Presentoutput {
    func presentoutputfromrsync(data: [String]?)
}

extension Presentoutput {
    func presentoutputfromrsync(data: [String]?) {
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.outputfromrsync(data: data)
            outputeverythingDelegate?.reloadtable()
        }
    }
}
