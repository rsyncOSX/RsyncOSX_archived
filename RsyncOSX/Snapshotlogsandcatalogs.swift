//
//  SnapshotsLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

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

    // Getting, from process, remote snapshotcatalogs
    // sort snapshotcatalogs
    private func prepareremotesnapshotcatalogs() {
        _ = self.outputprocess?.trimoutput(trim: .two)
        guard outputprocess?.error == false else { return }
        self.snapshotcatalogs = self.outputprocess?.trimoutput(trim: .one)
        let datessnapshotcatalogs = self.outputprocess?.trimoutput(trim: .four)
        /*
             if self.snapshotcatalogs?.count ?? 0 > 0 {
                 if self.snapshotcatalogs?[0] == "./." {
                     self.snapshotcatalogs?.remove(at: 0)
                 }
             }
         */
        self.snapshotcatalogs = self.snapshotcatalogs?.sorted { cat1, cat2 -> Bool in
            let nr1 = Int(cat1.dropFirst(2)) ?? 0
            let nr2 = Int(cat2.dropFirst(2)) ?? 0
            if nr1 > nr2 {
                return true
            } else {
                return false
            }
        }
    }

    // Calculating days since snaphot was executed
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

    // Merging remote snaphotcatalogs and existing logs
    private func mergeremotecatalogsandlogs() {
        var adjustedlogrecords = [Logrecordsschedules]()
        for i in 0 ..< (self.snapshotcatalogs?.count ?? 0) {
            if let logrecordssnapshot = self.logrecordssnapshot {
                if logrecordssnapshot.contains(where: { record in
                    let catalogelement = record.resultExecuted.split(separator: " ")[0]
                    let snapshotcatalogfromschedulelog = "./" + catalogelement.dropFirst().dropLast()
                    if snapshotcatalogfromschedulelog == self.snapshotcatalogs?[i] {
                        self.logrecordssnapshot?[i].period = "... not yet tagged ..."
                        self.logrecordssnapshot?[i].snapshotCatalog = snapshotcatalogfromschedulelog
                        if let record = self.logrecordssnapshot?[i] {
                            adjustedlogrecords.append(record)
                        }
                        return true
                    }
                    return false
                }) {} else {
                    var record = self.logrecordssnapshot?[0]
                    record?.snapshotCatalog = self.snapshotcatalogs?[i]
                    record?.period = "... not yet tagged ..."
                    record?.resultExecuted = "... no log ..."
                    record?.days = ""
                    record?.seconds = 0
                    record?.dateExecuted = Date().long_localized_string_from_date()
                    if let record = record {
                        adjustedlogrecords.append(record)
                    }
                }
            }
        }
        self.logrecordssnapshot = adjustedlogrecords.sorted { (cat1, cat2) -> Bool in
            if let cat1 = cat1.snapshotCatalog,
               let cat2 = cat2.snapshotCatalog
            {
                let nr1 = Int(cat1.dropFirst(2)) ?? 0
                let nr2 = Int(cat2.dropFirst(2)) ?? 0
                if nr1 > nr2 {
                    return true
                } else {
                    return false
                }
            }
            return false
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
        let selectedrecords = self.logrecordssnapshot?.filter { ($0.selectCellID == 1) }
        guard selectedrecords?.count == self.snapshotcatalogstodelete?.count else { return false }
        // for i in 0 ..< (self.snapshotcatalogstodelete?.count ?? 0) {}
        return true
    }

    func countbydays(num: Double) -> Int {
        guard self.logrecordssnapshot?.count ?? 0 > 0 else { return 0 }
        var j: Int = 0
        for i in 0 ..< (self.logrecordssnapshot?.count ?? 0) - 1 {
            if let days: String = self.logrecordssnapshot?[i].days {
                if Double(days) ?? 0 >= num {
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
        weak var reloadsnapshots: Reloadandrefresh?
        reloadsnapshots = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        reloadsnapshots?.reloadtabledata()
        weak var reloadlogg: Reloadandrefresh?
        reloadlogg = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        reloadlogg?.reloadtabledata()
    }

    func filehandler() {}
}
