//
//  SnapshotsLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class SnapshotsLoggData {

    var loggdata: [NSMutableDictionary]?
    var snapshotsubcatalogs: [String]?
    var config: Configuration?
    var outputprocess: OutputProcess?

    private func get() {
        let arguments = CopyFileArguments(task: .snapshotcatalogs, config: self.config!, remoteFile: nil, localCatalog: nil, drynrun: nil)
        let object = SnapshotCommandSubCatalogs(command: arguments.getCommand(), arguments: arguments.getArguments())
        object.executeProcess(outputprocess: self.outputprocess)
    }

    init(config: Configuration) {
        self.loggdata = ScheduleLoggData().getallloggdata()
        self.config = config
        self.outputprocess = OutputProcess()
        self.get()
    }
}
