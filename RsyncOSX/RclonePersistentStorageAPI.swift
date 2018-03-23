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
    func getConfigurations() -> [ConfigurationRclone]? {
        var read: RclonePersistentStorageConfiguration?
        read = RclonePersistentStorageConfiguration(profile: self.profile)
        // Either read from persistent store or
        // return Configurations already in memory
        if read!.readConfigurationsFromPermanentStore() != nil {
            var Configurations = [ConfigurationRclone]()
            for dict in read!.readConfigurationsFromPermanentStore()! {
                let conf = ConfigurationRclone(dictionary: dict)
                Configurations.append(conf)
            }
            return Configurations
        } else {
            return nil
        }
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
