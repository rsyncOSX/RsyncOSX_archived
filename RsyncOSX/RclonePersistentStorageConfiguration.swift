//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

final class RclonePersistentStorageConfiguration: ReadWriteDictionary {

    private var configurationsasdictionary: [NSDictionary]?

    func readConfigurationsFromPermanentStore() -> [NSDictionary]? {
        return self.configurationsasdictionary
    }

    init(profile: String?) {
        super.init(task: .configuration, profile: profile, configpath: RcloneReference.shared.configpath)
        self.configurationsasdictionary = self.ReadNSDictionaryFromPersistentStore()
    }
}
