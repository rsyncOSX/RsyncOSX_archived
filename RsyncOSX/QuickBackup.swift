//
//  QuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

enum Sort {
    case localCatalog
    case offsiteCatalog
    case offsiteServer
    case backupId
}

struct Filtereddata2 {
    var filtereddata: [NSMutableDictionary]?
}

class QuickBackup: SetConfigurations {
    var backuplist: [NSMutableDictionary]?
    var sortedlist: [NSMutableDictionary]?
    typealias Row = (Int, Int)
    var stackoftasktobeexecuted: [Row]?
    var index: Int?

    func sortbydays() {
        guard self.backuplist != nil else {
            self.sortedlist = nil
            return
        }
        let sorted = self.backuplist!.sorted {(di1, di2) -> Bool in
            let di1 = (di1.value(forKey: "daysID") as? NSString)!.doubleValue
            let di2 = (di2.value(forKey: "daysID") as? NSString)!.doubleValue
            if di1 > di2 {
                return false
            } else {
                return true
            }
        }
        self.sortedlist = sorted
    }

    func sortbystrings(sort: Sort) {
        var sortby: String?
        guard self.backuplist != nil else {
            self.sortedlist = nil
            return
        }
        switch sort {
        case .localCatalog:
            sortby = "localCatalogCellID"
        case .backupId:
            sortby = "backupIDCellID"
        case .offsiteCatalog:
            sortby = "offsiteCatalogCellID"
        case .offsiteServer:
            sortby = "offsiteServerCellID"
        }
        let sorted = self.backuplist!.sorted {return ($0.value(forKey: sortby!) as? String)!.localizedStandardCompare(($1.value(forKey: sortby!) as? String)!) == .orderedAscending}
        self.sortedlist = sorted
    }

    private func executetasknow(hiddenID: Int) {
        let now: Date = Date()
        let dateformatter = Tools().setDateformat()
        let task: NSDictionary = [
            "start": now,
            "hiddenID": hiddenID,
            "dateStart": dateformatter.date(from: "01 Jan 1900 00:00") as Date!,
            "schedule": "manuel"]
        ViewControllerReference.shared.scheduledTask = task
        _ = OperationFactory()
    }

    func prepareandstartexecutetasks() {
        if let list = self.sortedlist {
            self.stackoftasktobeexecuted = nil
            self.stackoftasktobeexecuted = [Row]()
            for i in 0 ..< list.count {
                list[i].setObject(false, forKey: "completeCellID" as NSCopying)
                if list[i].value(forKey: "selectCellID") as? Int == 1 {
                    self.stackoftasktobeexecuted?.append(((list[i].value(forKey: "hiddenID") as? Int)!, i))
                }
            }
            guard self.stackoftasktobeexecuted!.count > 0 else { return }
            // Kick off first task
            let hiddenID = self.stackoftasktobeexecuted![0].0
            self.index = self.stackoftasktobeexecuted![0].1
            self.stackoftasktobeexecuted?.remove(at: 0)
            self.executetasknow(hiddenID: hiddenID)
        }
    }

    // Called before processTerminatiom
    func setcompleted() {
        self.sortedlist![self.index!].setValue(true, forKey: "completeCellID")
    }

    func processTermination() {
        guard self.stackoftasktobeexecuted != nil else { return }
        guard self.stackoftasktobeexecuted!.count > 0  else {
            let localProgressIndicatorDelegate: StartStopProgressIndicator?
            localProgressIndicatorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcquickbatch) as? ViewControllerQuickBackup
            localProgressIndicatorDelegate?.stop()
            self.stackoftasktobeexecuted = nil
            return
        }
        let hiddenID = self.stackoftasktobeexecuted![0].0
        self.index = self.stackoftasktobeexecuted![0].1
        self.stackoftasktobeexecuted?.remove(at: 0)
        self.executetasknow(hiddenID: hiddenID)
    }

    // Function for filter
    func filter(search: String?, what: Filterlogs?) {
        guard search != nil || self.sortedlist != nil else { return }
        globalDefaultQueue.async(execute: {() -> Void in
            var filtereddata = Filtereddata2()
            switch what! {
            case .executeDate:
                return
            case .localCatalog:
                filtereddata.filtereddata = self.sortedlist?.filter({
                    ($0.value(forKey: "localCatalogCellID") as? String)!.contains(search!)
                })
            case .remoteServer:
                filtereddata.filtereddata = self.sortedlist?.filter({
                    ($0.value(forKey: "offsiteServerCellID") as? String)!.contains(search!)
                })
            case .numberofdays:
                filtereddata.filtereddata = self.sortedlist?.filter({
                    ($0.value(forKey: "daysID") as? String)!.contains(search!)
                })
            case .remoteCatalog:
                filtereddata.filtereddata = self.sortedlist?.filter({
                    ($0.value(forKey: "offsiteCatalogCellID") as? String)!.contains(search!)
                })
            }
            self.sortedlist = filtereddata.filtereddata
        })
    }

    init() {
        self.backuplist = self.configurations!.getConfigurationsDataSourcecountBackupOnly()
        self.sortbydays()
    }
}
