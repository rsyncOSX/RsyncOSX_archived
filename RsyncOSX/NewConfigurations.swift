//
//  NewConfigurations.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class NewConfigurations {
    // Temporary structure to hold added Configurations before writing to permanent store
    private var newConfigurations: [NSMutableDictionary]?

    /// Function is getting all added (new) configurations
    /// - returns : Array of Dictionary storing all new configurations
    func getnewConfigurations() -> [NSMutableDictionary]? {
        return newConfigurations
    }

    // Appending
    func appendnewConfigurations(dict: NSMutableDictionary) {
        guard newConfigurations != nil else {
            newConfigurations = [NSMutableDictionary]()
            newConfigurations?.append(dict)
            return
        }
        newConfigurations?.append(dict)
    }

    func newConfigurationsCount() -> Int {
        return newConfigurations?.count ?? 0
    }

    init() {
        newConfigurations = [NSMutableDictionary]()
    }
}
