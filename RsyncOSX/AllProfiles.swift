//
//  AllProfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class AllProfiles: Sorting {
    // Configurations object
    private var allconfigurations: [Configuration]?
    var allconfigurationsasdictionary: [NSMutableDictionary]?
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
        var data = [NSMutableDictionary]()
        for i in 0 ..< configurations.count {
            if configurations[i].offsiteServer.isEmpty == true {
                configurations[i].offsiteServer = "localhost"
            }
            let row: NSMutableDictionary = [
                "profile": configurations[i].profile ?? "",
                "task": configurations[i].task,
                "hiddenID": configurations[i].hiddenID,
                "localCatalog": configurations[i].localCatalog,
                "offsiteCatalog": configurations[i].offsiteCatalog,
                "offsiteServer": configurations[i].offsiteServer,
                "backupID": configurations[i].backupID,
                "dateExecuted": configurations[i].dateRun!,
                "days": configurations[i].dayssincelastbackup ?? "",
                "markdays": configurations[i].markdays,
                "selectCellID": 0
            ]
            data.append(row)
        }
        self.allconfigurationsasdictionary = data
    }

    // Function for filter
    func filter(search: String?, column: Int, filterby: Sortandfilter?) {
        guard search != nil && self.allconfigurationsasdictionary != nil && filterby != nil else { return }
        globalDefaultQueue.async(execute: {() -> Void in
            switch column {
            case 0, 1, 2, 3, 4, 5:
                guard filterby != nil else { return }
                let valueforkey = self.filterbystring(filterby: filterby!)
                let filtereddata = self.allconfigurationsasdictionary?.filter({
                    ($0.value(forKey: valueforkey) as? String)!.contains(search!)
                })
                self.allconfigurationsasdictionary = filtereddata
            case 6:
                let filtereddata = self.allconfigurationsasdictionary?.filter({
                    ($0.value(forKey: "daysID") as? String)!.contains(search!)
                })
                self.allconfigurationsasdictionary = filtereddata
            case 7:
                let filtereddata = self.allconfigurationsasdictionary?.filter({
                    ($0.value(forKey: "runDateCellID") as? String)!.contains(search!)
                })
                self.allconfigurationsasdictionary = filtereddata
            default:
                return
            }
        })
    }

    init() {
        self.getprofiles()
        self.getallconfigurations()
        self.setConfigurationsDataSourcecountBackupSnapshot()
    }

}
