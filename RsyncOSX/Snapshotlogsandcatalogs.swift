//
//  SnapshotsLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class Snapshotlogsandcatalogs {
    var logrecordssnapshot: [Logrecordsschedules]?
    var config: Configuration?
    var outputprocess: OutputProcess?
    var snapshotcatalogs: [String]?
    var snapshotcatalogstodelete: [String]?

    private func getremotecataloginfo() {
        self.outputprocess = OutputProcess()
        let arguments = RestorefilesArguments(task: .snapshotcatalogs,
                                              config: self.config,
                                              remoteFile: nil,
                                              localCatalog: nil,
                                              drynrun: nil)
        let command = RsyncProcessCmdClosure(arguments: arguments.getArguments(),
                                             config: nil,
                                             processtermination: self.processtermination,
                                             filehandler: self.filehandler)
        command.executeProcess(outputprocess: self.outputprocess)
    }

    private func reducetosnapshotlogs() {
        for i in 0 ..< (self.logrecordssnapshot?.count ?? 0) {
            if let dateRun = self.logrecordssnapshot?[i].dateExecuted {
                if let secondssince = self.calculatedays(datestringlocalized: dateRun) {
                    self.logrecordssnapshot?[i].days = String(format: "%.2f", secondssince / (60 * 60 * 24))
                    self.logrecordssnapshot?[i].seconds = Int(secondssince)
                }
            }
        }
    }

    private func mergeremotecatalogsandlogs() {
        for i in 0 ..< (self.snapshotcatalogs?.count ?? 0) {
            if self.snapshotcatalogs?[i].contains(".DS_Store") == false {
                let snapshotnum = "(" + (self.snapshotcatalogs?[i] ?? "").dropFirst(2) + ")"
                var filter = self.logrecordssnapshot?.filter { $0.resultExecuted.contains(snapshotnum) }
                if filter?.count == 1 {
                    filter?[0].snapshotCatalog = self.snapshotcatalogs?[i]
                } else {
                    self.logrecordssnapshot?[i].snapshotCatalog = "no log"
                }
            }
        }
        self.logrecordssnapshot = self.logrecordssnapshot?.sorted { (d1, d2) -> Bool in
            if d1.seconds < d2.seconds {
                return false
            } else {
                return true
            }
        }
        // self.logrecordssnapshot = sorted?.filter { $0.snapshotCatalog!.isEmpty == false }
    }

    func calculatedays(datestringlocalized: String) -> Double? {
        guard datestringlocalized != "" else { return nil }
        let lastbackup = datestringlocalized.localized_date_from_string()
        let seconds: TimeInterval = lastbackup.timeIntervalSinceNow
        return seconds * (-1)
    }

    func preparecatalogstodelete() {
        for i in 0 ..< ((self.logrecordssnapshot?.count ?? 0) - 1) where self.logrecordssnapshot?[i].selectCellID == 1 {
            if self.snapshotcatalogstodelete == nil { self.snapshotcatalogstodelete = [] }
            let snaproot = self.config?.offsiteCatalog
            let snapcatalog = self.logrecordssnapshot?[i].snapshotCatalog
            self.snapshotcatalogstodelete?.append((snaproot ?? "") + (snapcatalog ?? "").dropFirst(2))
        }
    }

    func countbydays(num: Double) -> Int {
        var j: Int = 0
        for i in 0 ..< (self.logrecordssnapshot?.count ?? 0) - 1 {
            if let days: String = self.logrecordssnapshot?[i].days {
                if Double(days)! >= num {
                    j += 1
                }
            }
        }
        return j - 1
    }

    init(config: Configuration) {
        guard config.task == ViewControllerReference.shared.snapshot else { return }
        self.config = config
        self.logrecordssnapshot = ScheduleLoggData(hiddenID: config.hiddenID, sortascending: true).loggrecords
        self.getremotecataloginfo()
    }
}

extension Snapshotlogsandcatalogs {
    func processtermination() {
        _ = self.outputprocess?.trimoutput(trim: .two)
        guard outputprocess?.error == false else { return }
        self.snapshotcatalogs = self.outputprocess?.trimoutput(trim: .one)
        if self.snapshotcatalogs?.count ?? 0 > 1 {
            if self.snapshotcatalogs![0] == "./." {
                self.snapshotcatalogs?.remove(at: 0)
            }
        }
        self.reducetosnapshotlogs()
        self.mergeremotecatalogsandlogs()

        weak var test: Reloadandrefresh?
        test = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        test?.reloadtabledata()
    }

    func filehandler() {
        //
    }
}
