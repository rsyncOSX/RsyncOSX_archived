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

    var snapshotsloggdata: [NSMutableDictionary]?
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
        self.snapshotsloggdata = ScheduleLoggData().getallloggdata()?.filter({($0.value(forKey: "hiddenID") as? Int)! == config?.hiddenID})
    }

    private func mergedata() {
        guard self.catalogs != nil else { return }
        for i in 0 ..< self.catalogs!.count {
            let snapshotnum = "(" + self.catalogs![i].dropFirst(2) + ")"
            var filter = self.snapshotsloggdata?.filter({($0.value(forKey: "resultExecuted") as? String ?? "").contains(snapshotnum)})
            if filter!.count == 1 {
                filter![0].setObject(self.catalogs![i], forKey: "snapshotCatalog" as NSCopying)
            } else {
                let dict: NSMutableDictionary = ["snapshotCatalog": self.catalogs![i]]
                self.snapshotsloggdata!.append(dict)
            }
        }
    }

    init(config: Configuration) {
        self.snapshotsloggdata = ScheduleLoggData().getallloggdata()
        self.config = config
        self.getcataloginfo()
    }
}

extension SnapshotsLoggData: UpdateProgress {
    func processTermination() {
        self.catalogs = self.outputprocess?.trimoutput(trim: .one)
        self.getloggdata()
        self.mergedata()
    }

    func fileHandler() {
        //
    }
}
