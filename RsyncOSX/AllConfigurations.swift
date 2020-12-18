//
//  AllConfigurations.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class AllConfigurations {
    var allconfigurations: [Configuration]?
    var allprofiles: [String]?

    func filter(search: String?) {
        globalDefaultQueue.async { () -> Void in
            self.allconfigurations = self.allconfigurations?.filter { ($0.dateRun!.contains(search ?? "")) }
        }
    }

    func readallconfigurations() {
        var configurations: [Configuration]?
        for i in 0 ..< (self.allprofiles?.count ?? 0) {
            let profile = self.allprofiles?[i]
            if self.allconfigurations == nil {
                self.allconfigurations = [Configuration]()
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

    init() {
        self.allprofiles = AllProfilenames().allprofiles
        self.readallconfigurations()
    }

    deinit {
        print("deinit AllConfigurations")
    }
}
