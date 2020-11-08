//
//  AllConfigurations.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Foundation

final class AllConfigurations: Sorting {
    private var allconfigurations: [Configuration]?
    var allconfigurationsasdictionary: [NSMutableDictionary]?
    private var allprofiles: [String]?

    private func readallconfigurations() {
        guard self.allprofiles != nil else { return }
        var configurations: [Configuration]?
        for i in 0 ..< (self.allprofiles?.count ?? 0) {
            let profile = self.allprofiles![i]
            if self.allconfigurations == nil {
                self.allconfigurations = []
            }
            if profile == NSLocalizedString("Default profile", comment: "default profile") {
                configurations = PersistentStorageAllprofilesAPI(profile: nil).getallconfigurations()
            } else {
                configurations = PersistentStorageAllprofilesAPI(profile: profile).getallconfigurations()
            }
            guard configurations != nil else { return }
            for j in 0 ..< (configurations?.count ?? 0) {
                configurations![j].profile = profile
                self.allconfigurations!.append(configurations![j])
            }
        }
    }

    private func setConfigurationsDataSourcecountBackupSnapshot() {
        guard self.allconfigurations != nil else { return }
        var configurations: [Configuration] = self.allconfigurations!.filter {
            ViewControllerReference.shared.synctasks.contains($0.task)
        }
        var data = [NSMutableDictionary]()
        for i in 0 ..< configurations.count {
            if configurations[i].offsiteServer.isEmpty == true {
                configurations[i].offsiteServer = "localhost"
            }
            var date: String = ""
            let stringdate = configurations[i].dateRun ?? ""
            if stringdate.isEmpty == false {
                date = stringdate.en_us_date_from_string().localized_string_from_date()
            }
            let row: NSMutableDictionary = [
                "profile": configurations[i].profile ?? "",
                "task": configurations[i].task,
                "hiddenID": configurations[i].hiddenID,
                "localCatalog": configurations[i].localCatalog,
                "offsiteCatalog": configurations[i].offsiteCatalog,
                "offsiteServer": configurations[i].offsiteServer,
                "offsiteUsername": configurations[i].offsiteUsername,
                "backupID": configurations[i].backupID,
                "dateExecuted": date,
                "daysID": configurations[i].dayssincelastbackup ?? "",
                "markdays": configurations[i].markdays,
                "selectCellID": 0,
            ]
            data.append(row)
        }
        self.allconfigurationsasdictionary = data
    }

    // Function for filter
    func filter(search: String?, filterby: Sortandfilter?) {
        guard search != nil, self.allconfigurationsasdictionary != nil, filterby != nil else { return }
        globalDefaultQueue.async { () -> Void in
            let valueforkey = self.filterbystring(filterby: filterby!)
            let filtereddata = self.allconfigurationsasdictionary?.filter {
                ($0.value(forKey: valueforkey) as? String)?.contains(search ?? "") ?? false
            }
            self.allconfigurationsasdictionary = filtereddata
        }
    }

    init() {
        self.allprofiles = AllProfilenames().allprofiles
        self.readallconfigurations()
        self.setConfigurationsDataSourcecountBackupSnapshot()
    }
}
