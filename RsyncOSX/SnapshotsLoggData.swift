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
    var remotecatalogstodelete: [String]?
    var insnapshot: Bool = true

    private func getremotecataloginfo(insnapshots: Bool) {
        self.outputprocess = OutputProcess()
        let arguments = CopyFileArguments(task: .snapshotcatalogs, config: self.config!, remoteFile: nil, localCatalog: nil, drynrun: nil)
        if insnapshots {
            let object = SnapshotCommandSubCatalogs(command: arguments.getCommand(), arguments: arguments.getArguments())
            object.executeProcess(outputprocess: self.outputprocess)
        } else {
            let object = SnapshotCommandSubCatalogsLogview(command: arguments.getCommand(), arguments: arguments.getArguments())
            object.executeProcess(outputprocess: self.outputprocess)
        }
    }

    private func getsnapshotlogs() {
        self.snapshotslogs = ScheduleLoggData(sortdirection: true).loggdata?.filter({($0.value(forKey: "hiddenID") as? Int)! == config?.hiddenID})
        guard self.snapshotslogs != nil else { return }
        for i in 0 ..< self.snapshotslogs!.count {
            if let dateRun = self.snapshotslogs![i].object(forKey: "dateExecuted") {
                if let secondssince = self.calculatedays(datestringlocalized: dateRun as? String ?? "") {
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
                return self.insnapshot
            } else {
                return !self.insnapshot
            }
        }
        self.snapshotslogs = sorted.filter({($0.value(forKey: "snapshotCatalog") as? String)?.isEmpty == false})
    }

    private func calculatedays(datestringlocalized: String) -> Double? {
        guard datestringlocalized != "" else { return nil }
        let formatter = DateFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let lastbackup = formatter.date(from: datestringlocalized)
        let seconds: TimeInterval = lastbackup!.timeIntervalSinceNow
        return seconds * (-1)
    }

    func preparecatalogstodelete() {
        guard self.snapshotslogs != nil else { return }
        for i in 0 ..< self.snapshotslogs!.count - 1 {
            if self.snapshotslogs![i].value(forKey: "selectCellID") as? Int == 1 {
                if self.remotecatalogstodelete == nil { self.remotecatalogstodelete = [] }
                let snaproot = self.config!.offsiteCatalog
                let snapcatalog = self.snapshotslogs![i].value(forKey: "snapshotCatalog") as? String
                self.remotecatalogstodelete!.append(snaproot + snapcatalog!.dropFirst(2))
            }
        }
    }

    func countbydays(num: Double) -> Int {
        var j: Int = 0
        guard self.snapshotslogs != nil else { return 0}
        for i in 0 ..< self.snapshotslogs!.count - 1 {
            let days: String = self.snapshotslogs![i].value(forKey: "days") as? String ?? "0"
            if Double(days)! >= num {
                j+=1
            }
        }
        return j - 1
    }

    init(config: Configuration, insnapshot: Bool) {
        guard config.task == ViewControllerReference.shared.snapshot else { return }
        self.insnapshot = insnapshot
        self.snapshotslogs = ScheduleLoggData(sortdirection: true).loggdata
        self.config = config
        self.getremotecataloginfo(insnapshots: insnapshot)
    }
}

extension SnapshotsLoggData: UpdateProgress {
    func processTermination() {
        _ = self.outputprocess?.trimoutput(trim: .two)
        guard outputprocess!.error == false else { return }
        self.catalogs = self.outputprocess?.trimoutput(trim: .one)
        if self.catalogs?.count ?? 0 > 1 {
            if self.catalogs![0] == "./." {
                self.catalogs?.remove(at: 0)
            }
        }
        self.getsnapshotlogs()
        self.mergeremotecatalogsandlogs()
    }

    func fileHandler() {
        //
    }
}
