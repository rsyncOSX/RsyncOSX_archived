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

    private func prepareremotesnapshotcatalogs() {
        _ = self.outputprocess?.trimoutput(trim: .two)
        guard outputprocess?.error == false else { return }
        self.snapshotcatalogs = self.outputprocess?.trimoutput(trim: .one)
        if self.snapshotcatalogs?.count ?? 0 > 0 {
            if self.snapshotcatalogs?[0] == "./." {
                self.snapshotcatalogs?.remove(at: 0)
            }
        }
    }

    private func calculateddayssincesynchronize() {
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
        for i in 0 ..< (self.logrecordssnapshot?.count ?? 0) {
            self.logrecordssnapshot?[i].period = "... not yet tagged..."
            if (self.logrecordssnapshot?[i].resultExecuted ?? "").split(separator: " ").count > 0 {
                let catalogelement = (self.logrecordssnapshot?[i].resultExecuted ?? "").split(separator: " ")[0]
                let snapshotcatalog = "./" + catalogelement.dropFirst().dropLast()
                if (self.snapshotcatalogs?.filter { $0.contains(snapshotcatalog) }) != nil {
                    self.logrecordssnapshot?[i].snapshotCatalog = snapshotcatalog
                }
            } else {
                self.logrecordssnapshot?[i].snapshotCatalog = "no log"
            }
        }
        self.logrecordssnapshot = self.logrecordssnapshot?.sorted { (d1, d2) -> Bool in
            if d1.seconds < d2.seconds {
                return false
            } else {
                return true
            }
        }
    }

    func calculatedays(datestringlocalized: String) -> Double? {
        guard datestringlocalized != "" else { return nil }
        let lastbackup = datestringlocalized.localized_date_from_string()
        let seconds: TimeInterval = lastbackup.timeIntervalSinceNow
        return seconds * (-1)
    }

    func preparesnapshotcatalogsfordelete() {
        for i in 0 ..< ((self.logrecordssnapshot?.count ?? 0) - 1) where self.logrecordssnapshot?[i].selectCellID == 1 {
            if self.snapshotcatalogstodelete == nil { self.snapshotcatalogstodelete = [] }
            let snaproot = self.config?.offsiteCatalog
            let snapcatalog = self.logrecordssnapshot?[i].snapshotCatalog
            self.snapshotcatalogstodelete?.append((snaproot ?? "") + (snapcatalog ?? "").dropFirst(2))
        }
        if self.validatedelete() == false {
            self.snapshotcatalogstodelete = nil
        }
    }

    func validatedelete() -> Bool {
        guard (self.snapshotcatalogstodelete?.count ?? 0) > 0 else { return false }
        for i in 0 ..< (self.snapshotcatalogstodelete?.count ?? 0) {
            // print(self.snapshotcatalogstodelete?[i])
        }
        return false
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
        self.logrecordssnapshot = ScheduleLoggData(hiddenID: config.hiddenID).loggrecords
        self.getremotecataloginfo()
    }
}

extension Snapshotlogsandcatalogs {
    func processtermination() {
        self.prepareremotesnapshotcatalogs()
        self.calculateddayssincesynchronize()
        self.mergeremotecatalogsandlogs()
        weak var reload: Reloadandrefresh?
        reload = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        reload?.reloadtabledata()
    }

    func filehandler() {}
}
