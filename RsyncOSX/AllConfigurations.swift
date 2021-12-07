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
        globalDefaultQueue.async { () in
            self.allconfigurations = self.allconfigurations?.filter { $0.dateRun!.contains(search ?? "") }
        }
    }

    func readallconfigurations() {
        var configurations: [Configuration]?
        for i in 0 ..< (allprofiles?.count ?? 0) {
            let profile = allprofiles?[i]
            if allconfigurations == nil {
                allconfigurations = [Configuration]()
            }
            if profile == NSLocalizedString("Default profile", comment: "default profile") {
                configurations = ReadConfigurationJSON(nil).configurations
            } else {
                configurations = ReadConfigurationJSON(profile).configurations
            }
            guard configurations != nil else { return }
            for j in 0 ..< (configurations?.count ?? 0) {
                configurations?[j].profile = profile
                if let config = configurations?[j] {
                    allconfigurations?.append(config)
                }
            }
        }
    }

    init() {
        allprofiles = Catalogsandfiles(.configurations).getcatalogsasstringnames()
        readallconfigurations()
    }

    deinit {
        // print("deinit AllConfigurations")
    }
}
