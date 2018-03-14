//
//  AllProfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class AllProfiles {
    // Configurations object
    private var allconfigurations: [Configuration]?
    var allconfigurationsasdictionary: [NSDictionary]?
    private var allprofiles: [String]?
    var sortedascendigdesending: Bool = false
    weak var sortdirection: Sortdirection?

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

    func sortbyrundate() {
        guard self.allconfigurationsasdictionary != nil else { return }
        if self.sortedascendigdesending == true {
            self.sortedascendigdesending = false
            self.sortdirection?.sortdirection(directionup: false)
        } else {
            self.sortedascendigdesending = true
            self.sortdirection?.sortdirection(directionup: true)
        }
        let dateformatter = Tools().setDateformat()
        guard self.allconfigurationsasdictionary != nil else { return }
        let sorted = self.allconfigurationsasdictionary!.sorted { (dict1, dict2) -> Bool in
            let date1 = (dateformatter.date(from: (dict1.value(forKey: "runDateCellID") as? String) ?? "") ?? dateformatter.date(from: "01 Jan 1900 00:00")!)
            let date2 = (dateformatter.date(from: (dict2.value(forKey: "runDateCellID") as? String) ?? "") ?? dateformatter.date(from: "01 Jan 1900 00:00")!)
            if date1.timeIntervalSince(date2) > 0 {
                return self.sortedascendigdesending
            } else {
                return !self.sortedascendigdesending
            }
        }
        self.allconfigurationsasdictionary = sorted
    }

    private func filterbystring(filterby: Sortandfilter) -> String {
        switch filterby {
        case .localcatalog:
            return "localCatalogCellID"
        case .profile:
            return "profile"
        case .remotecatalog:
            return "offsiteCatalogCellID"
        case .remoteserver:
            return "offsiteServerCellID"
        case .task:
            return "taskCellID"
        case .backupid:
            return "backupIDCellID"
        case .numberofdays:
            return ""
        case .executedate:
            return ""
        }
    }

    func sortbystring(sortby: Sortandfilter) {
        guard self.allconfigurationsasdictionary != nil else { return }
        if self.sortedascendigdesending == true {
            self.sortedascendigdesending = false
            self.sortdirection?.sortdirection(directionup: false)
        } else {
            self.sortedascendigdesending = true
            self.sortdirection?.sortdirection(directionup: true)
        }
        let sortstring = self.filterbystring(filterby: sortby)
        let sorted = self.allconfigurationsasdictionary!.sorted { (dict1, dict2) -> Bool in
            if (dict1.value(forKey: sortstring) as? String) ?? "" > (dict2.value(forKey: sortstring) as? String) ?? "" {
                return self.sortedascendigdesending
            } else {
                return !self.sortedascendigdesending
            }
        }
        self.allconfigurationsasdictionary = sorted
    }

    // Function for filter
    func filter(search: String?, column: Int, filterby: Sortandfilter?) {
        guard search != nil || self.allconfigurationsasdictionary != nil else { return }
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
        self.sortdirection = ViewControllerReference.shared.getvcref(viewcontroller: .vcallprofiles) as? ViewControllerAllProfiles
        self.getprofiles()
        self.getallconfigurations()
        self.setConfigurationsDataSourcecountBackupSnapshot()
    }

}
