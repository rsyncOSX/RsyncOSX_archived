//
//  ConfigurationsRclone.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class ConfigurationsRclone {

    var storageapi: RclonePersistentStorageAPI?
    private var profile: String?
    private var configurations: [ConfigurationRclone]?
    private var argumentAllConfigurations: NSMutableArray?

    func arguments4rclone (index: Int) -> [String] {
        let allarguments = (self.argumentAllConfigurations![index] as? RcloneArgumentsOneConfiguration)!
        return allarguments.arg!
    }

    func getConfigurations() -> [ConfigurationRclone] {
        return self.configurations ?? []
    }

    private func readconfigurations() {
        self.configurations = [ConfigurationRclone]()
        self.argumentAllConfigurations = NSMutableArray()
        var store: [ConfigurationRclone]? = self.storageapi!.getConfigurations()
        guard store != nil else { return }
        for i in 0 ..< store!.count {
            self.configurations!.append(store![i])
            let rsyncArgumentsOneConfig = RcloneArgumentsOneConfiguration(config: store![i])
            self.argumentAllConfigurations!.add(rsyncArgumentsOneConfig)
        }
    }

    init(profile: String?) {
        self.profile = profile
        self.storageapi = RclonePersistentStorageAPI(profile: self.profile)
        self.readconfigurations()
    }
}
