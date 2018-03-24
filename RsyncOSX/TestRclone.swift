//
//  TestRclone.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class TestRclone {

    var configurationsrclone: ConfigurationsRclone?

    init() {
        var storage: RclonePersistentStorageAPI?
        // Insert code here to initialize your application
        // Read user configuration
        storage = RclonePersistentStorageAPI(profile: nil)
        if let userConfiguration =  storage?.getUserconfiguration() {
            _ = RcloneUserconfiguration(userconfigRsyncOSX: userConfiguration)
        }
        self.configurationsrclone = ConfigurationsRclone(profile: nil)
    }
}
