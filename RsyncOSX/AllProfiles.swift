//
//  AllProfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

enum Sortstring {
    case remotecatalog
    case localcatalog
    case profile
    case remoteserver
}

class AllProfiles {
    // Configurations object
    private var allconfigurations: [Configuration]?
    var allconfigurationsasdictionary: [NSDictionary]?
    private var allprofiles: [String]?

    private func getprofiles() {
        let profile = Files(root: .profileRoot)
        self.allprofiles = profile.getDirectorysStrings()
        guard self.allprofiles != nil else { return }
        self.allprofiles!.append("Default profile")
    }

    private func getallconfigurations() {
        guard self.allprofiles != nil else { return }
        var configurations: [Configuration]?
        for i in 0 ..< self.allprofiles!.count {
            let profile = self.allprofiles![i]
            if self.allconfigurations == nil {
                self.allconfigurations = []
            }
            if profile == "Default profile" {
                configurations = PersistentStorageAPI(profile: nil, forceread: true).getConfigurations()
            } else {
                configurations = PersistentStorageAPI(profile: profile, forceread: true).getConfigurations()
            }
            guard configurations != nil else { return }
            for j in 0 ..< configurations!.count {
                configurations![j].profile = profile
                self.allconfigurations!.append(configurations![j])
            }
        }
    }

    private func setConfigurationsDataSourcecountBackupSnapshot() {
        guard self.allconfigurations != nil else { return }
        var configurations: [Configuration] = self.allconfigurations!.filter({return ($0.task == "backup" || $0.task == "snapshot" )})
        var data = [NSDictionary]()
        for i in 0 ..< configurations.count {
            if configurations[i].offsiteServer.isEmpty == true {
                configurations[i].offsiteServer = "localhost"
            }
            let row: NSDictionary = [
                "profile": configurations[i].profile ?? "",
                "taskCellID": configurations[i].task,
                "hiddenID": configurations[i].hiddenID,
                "localCatalogCellID": configurations[i].localCatalog,
                "offsiteCatalogCellID": configurations[i].offsiteCatalog,
                "offsiteServerCellID": configurations[i].offsiteServer,
                "backupIDCellID": configurations[i].backupID,
                "runDateCellID": configurations[i].dateRun!,
                "daysID": configurations[i].dayssincelastbackup ?? "",
                "markdays": configurations[i].markdays,
                "selectCellID": 0
            ]
            data.append(row)
        }
        self.allconfigurationsasdictionary = data
    }

    func sortrundate() {
        let dateformatter = Tools().setDateformat()
        guard self.allconfigurationsasdictionary != nil else { return }
        let sorted = self.allconfigurationsasdictionary!.sorted { (dict1, dict2) -> Bool in
            if (dateformatter.date(from: (dict1.value(forKey: "runDateCellID") as? String) ?? ""))!.timeIntervalSince(dateformatter.date(from: (dict2.value(forKey: "runDateCellID") as? String) ?? "")!) > 0 {
                return true
            } else {
                return false
            }
        }
        self.allconfigurationsasdictionary = sorted
    }

    func sortstring(sortby: Sortstring) {
        guard self.allconfigurationsasdictionary != nil else { return }
        var sortstring: String?
        switch sortby {
        case .localcatalog:
            sortstring = "localCatalogCellID"
        case .profile:
            sortstring = "profile"
        case .remotecatalog:
            sortstring = "offsiteCatalogCellID"
        case .remoteserver:
            sortstring = "offsiteServerCellID"
        }
        let sorted = self.allconfigurationsasdictionary!.sorted { (dict1, dict2) -> Bool in
            if (dict1.value(forKey: sortstring!) as? String) ?? "" > (dict2.value(forKey: sortstring!) as? String) ?? "" {
                return true
            } else {
                return false
            }
        }
        self.allconfigurationsasdictionary = sorted
    }

    init() {
        self.getprofiles()
        self.getallconfigurations()
        self.setConfigurationsDataSourcecountBackupSnapshot()
    }

}
