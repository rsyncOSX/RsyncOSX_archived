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
    var allconfigurations: [Configuration]?
    private var allprofiles: [String]?

    private func readallconfigurations() {
        var configurations: [Configuration]?
        for i in 0 ..< (self.allprofiles?.count ?? 0) {
            let profile = self.allprofiles?[i]
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
                configurations?[j].profile = profile
                if let config = configurations?[j] {
                    self.allconfigurations?.append(config)
                }
            }
        }
    }

    func sorttest(data: [Configuration], type: Int) -> [Configuration]? {
        switch type {
        case 0:
            return data.sorted(by: \.backupID, using: >)
        case 1:
            return data.sorted(by: \.offsiteCatalog, using: >)
        default:
            return data.sorted(by: \.dateRun!, using: >)
        }
    }

    init() {
        self.allprofiles = AllProfilenames().allprofiles
        self.readallconfigurations()
        // self.setConfigurationsDataSourcecountBackupSnapshot()
    }
}
