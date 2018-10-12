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

    var snapshotslogs: [NSMutableDictionary]?
    var config: Configuration?
    var outputprocess: OutputProcess?
    private var catalogs: [String]?
    var expandedremotecatalogs: [String]?
    var remotecatalogstodelete: [String]?

    private func getremotecataloginfo() {
        self.outputprocess = OutputProcess()
        let arguments = CopyFileArguments(task: .snapshotcatalogs, config: self.config!, remoteFile: nil, localCatalog: nil, drynrun: nil)
        let object = SnapshotCommandSubCatalogs(command: arguments.getCommand(), arguments: arguments.getArguments())
        object.executeProcess(outputprocess: self.outputprocess)
    }

    private func getsnapshotlogs() {
        self.snapshotslogs = ScheduleLoggData(sortdirection: true).loggdata?.filter({($0.value(forKey: "hiddenID") as? Int)! == config?.hiddenID})
        guard self.snapshotslogs != nil else { return }
        for i in 0 ..< self.snapshotslogs!.count {
            if let dateRun = self.snapshotslogs![i].object(forKey: "dateExecuted") {
                if let secondssince = self.calculatedays(date: dateRun as? String ?? "") {
                    let dayssincelastbackup = String(format: "%.2f", secondssince/(60*60*24))
                    self.snapshotslogs![i].setObject(dayssincelastbackup, forKey: "days" as NSCopying)
                }
            }
        }
    }

    private func mergeremotecatalogsandlogs() {
        guard self.catalogs != nil else { return }
        for i in 0 ..< self.catalogs!.count {
            if self.catalogs![i].contains(".DS_Store") == false {
                let snapshotnum = "(" + self.catalogs![i].dropFirst(2) + ")"
                var filter = self.snapshotslogs?.filter({($0.value(forKey: "resultExecuted") as? String ?? "").contains(snapshotnum)})
                if filter!.count == 1 {
                    filter![0].setObject(self.catalogs![i], forKey: "snapshotCatalog" as NSCopying)
                } else {
                    let dict: NSMutableDictionary = ["snapshotCatalog": self.catalogs![i],
                                                     "dateExecuted": "no log"]
                    self.snapshotslogs!.append(dict)
                }
            }
        }
        let sorted = self.snapshotslogs!.sorted { (di1, di2) -> Bool in
            let str1 = di1.value(forKey: "snapshotCatalog") as? String
            let str2 = di2.value(forKey: "snapshotCatalog") as? String
            let num1 = Int(str1?.dropFirst(2) ?? "") ?? 0
            let num2 = Int(str2?.dropFirst(2) ?? "") ?? 0
            if num1 <= num2 {
                return true
            } else {
                return false
            }
        }
        self.snapshotslogs = sorted.filter({($0.value(forKey: "snapshotCatalog") as? String)?.isEmpty == false})
    }

    private func calculatedays(date: String) -> Double? {
        guard date != "" else { return nil }
        let dateformatter = Dateandtime().setDateformat()
        let lastbackup = dateformatter.date(from: date)
        let seconds: TimeInterval = lastbackup!.timeIntervalSinceNow
        return seconds * (-1)
    }

    private func sortedandexpandremotecatalogs() {
        guard self.expandedremotecatalogs != nil else { return }
        var sorted = self.expandedremotecatalogs?.sorted { (di1, di2) -> Bool in
            let num1 = Int(di1) ?? 0
            let num2 = Int(di2) ?? 0
            if num1 <= num2 {
                return true
            } else {
                return false
            }
        }
        // Remove the top ./ catalog
        if sorted?.count ?? 0 > 1 {
            if sorted![0] == "." {
                sorted?.remove(at: 0)
            }
        }
        self.expandedremotecatalogs = sorted
        for i in 0 ..< self.expandedremotecatalogs!.count {
            let expanded = self.config!.offsiteCatalog + self.expandedremotecatalogs![i]
            self.expandedremotecatalogs![i] = expanded
        }
    }

    func preparecatalogstodelete(num: Int) {
        guard num < self.expandedremotecatalogs?.count ?? 0 else { return }
        self.remotecatalogstodelete = []
        for i in 0 ..< num {
            self.remotecatalogstodelete!.append(self.expandedremotecatalogs![i])
        }
    }

    init(config: Configuration) {
        self.snapshotslogs = ScheduleLoggData(sortdirection: true).loggdata
        self.config = config
        guard config.task == ViewControllerReference.shared.snapshot else { return }
        self.getremotecataloginfo()
    }
}

extension SnapshotsLoggData: UpdateProgress {
    func processTermination() {
        self.catalogs = self.outputprocess?.trimoutput(trim: .one)
        if self.catalogs?.count ?? 0 > 1 {
            if self.catalogs![0] == "./." {
                self.catalogs?.remove(at: 0)
            }
        }
        self.expandedremotecatalogs = self.outputprocess?.trimoutput(trim: .three)
        self.getsnapshotlogs()
        self.mergeremotecatalogsandlogs()
        self.sortedandexpandremotecatalogs()
    }

    func fileHandler() {
        //
    }
}
