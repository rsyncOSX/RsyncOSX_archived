//
//  SnapshotsLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class SnapshotsLoggData {

    var loggdata: [NSMutableDictionary]?
    var snapshotsubcatalogs: [String]?
    var config: Configuration?
    var outputprocess: OutputProcess?
    private var catalogs: [String]?

    private func getcataloginfo() {
        self.outputprocess = OutputProcess()
        let arguments = CopyFileArguments(task: .snapshotcatalogs, config: self.config!, remoteFile: nil, localCatalog: nil, drynrun: nil)
        let object = SnapshotCommandSubCatalogs(command: arguments.getCommand(), arguments: arguments.getArguments())
        object.executeProcess(outputprocess: self.outputprocess)
    }

    private func getloggdata() {
        self.loggdata = ScheduleLoggData().getallloggdata()
    }

    init(config: Configuration) {
        self.loggdata = ScheduleLoggData().getallloggdata()
        self.config = config
        self.getcataloginfo()
    }
}

extension SnapshotsLoggData: UpdateProgress {
    func processTermination() {
        self.catalogs = self.outputprocess?.trimoutput(trim: .one)
        self.getloggdata()
    }

    func fileHandler() {
        //
    }
}
