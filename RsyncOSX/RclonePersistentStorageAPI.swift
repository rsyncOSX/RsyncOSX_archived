//
//  persistentStoreAPI.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

final class RclonePersistentStorageAPI {

    var profile: String?

    // CONFIGURATIONS
    // Read configurations from persisten store
    func getConfigurations() -> [RcloneConfiguration]? {
        let read = RclonePersistentStorageConfiguration(profile: self.profile)
        guard read.configurationsasdictionary != nil else { return nil}
        var Configurations = [RcloneConfiguration]()
        for dict in read.configurationsasdictionary! {
            let conf = RcloneConfiguration(dictionary: dict)
            Configurations.append(conf)
        }
        return Configurations
    }

    // USERCONFIG
    func getUserconfiguration () -> [NSDictionary]? {
        let store = RclonePersistentStorageUserconfiguration()
        return store.readUserconfigurationsFromPermanentStore()
    }

    init(profile: String?) {
        self.profile = profile
    }

}
