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
    var expandedcatalogs: [String]?
    var catalogstodelete: [String]?

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
            if self.catalogs![i].contains(".DS_Store") == false {
                let snapshotnum = "(" + self.catalogs![i].dropFirst(2) + ")"
                var filter = self.snapshotsloggdata?.filter({($0.value(forKey: "resultExecuted") as? String ?? "").contains(snapshotnum)})
                if filter!.count == 1 {
                    filter![0].setObject(self.catalogs![i], forKey: "snapshotCatalog" as NSCopying)
                } else {
                    let dict: NSMutableDictionary = ["snapshotCatalog": self.catalogs![i],
                                                     "dateExecuted": "no logg"]
                    self.snapshotsloggdata!.append(dict)
                }
            }
        }
        let sorted = self.snapshotsloggdata!.sorted { (di1, di2) -> Bool in
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
        self.snapshotsloggdata = sorted
    }

    private func sortedandexpandedcatalog() {
        guard self.expandedcatalogs != nil else { return }
        var sorted = self.expandedcatalogs?.sorted { (di1, di2) -> Bool in
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
        self.expandedcatalogs = sorted
        for i in 0 ..< self.expandedcatalogs!.count {
            let expanded = self.config!.offsiteCatalog + self.expandedcatalogs![i]
            self.expandedcatalogs![i] = expanded
        }
    }

    func preparecatalogstodelete(num: Int) {
        guard num < self.expandedcatalogs?.count ?? 0 else { return }
        self.catalogstodelete = []
        for i in 0 ..< num {
            self.catalogstodelete!.append(self.expandedcatalogs![i])
        }
    }

    init(config: Configuration) {
        self.snapshotsloggdata = ScheduleLoggData().getallloggdata()
        self.config = config
        guard config.task == "snapshot" else { return }
        self.getcataloginfo()
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
        self.expandedcatalogs = self.outputprocess?.trimoutput(trim: .three)
        self.getloggdata()
        self.mergedata()
        self.sortedandexpandedcatalog()
    }

    func fileHandler() {
        //
    }
}
