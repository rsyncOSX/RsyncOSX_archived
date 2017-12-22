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

class QuickBackup: SetConfigurations {
    var backuplist: [NSDictionary]?

    func sortbydays() -> [NSDictionary]? {
        guard self.backuplist != nil else {
            return nil
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
        guard sorted.count > 0 else {
            return nil
        }
        return sorted
    }

    func sortbystrings(sort: Sort) -> [NSDictionary]? {
        var sortby: String?
        guard self.backuplist != nil else {
            return nil
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
        let sorted = self.backuplist!.sorted {($0.value(forKey: sortby!) as? String)!.localizedStandardCompare(($1.value(forKey: sortby!) as? String)!) == .orderedAscending}
        guard sorted.count > 0 else {
            return nil
        }
        return sorted
    }

    init() {
        self.backuplist = self.configurations!.getConfigurationsDataSourcecountBackupOnly()
    }
}
