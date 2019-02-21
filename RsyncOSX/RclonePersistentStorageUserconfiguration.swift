//
//  PersistentStoreageUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class RclonePersistentStorageUserconfiguration: ReadWriteDictionary {

    private var userconfiguration: [NSDictionary]?

    func readUserconfigurationsFromPermanentStore() -> [NSDictionary]? {
        return self.userconfiguration
    }

    init() {
        super.init(task: .userconfig, profile: nil, configpath: RcloneReference.shared.configpath)
        self.userconfiguration = self.readNSDictionaryFromPersistentStore()
    }
}
