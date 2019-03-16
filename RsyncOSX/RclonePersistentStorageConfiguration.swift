//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

final class RclonePersistentStorageConfiguration: ReadWriteDictionary {

    var configurationsasdictionary: [NSDictionary]?

    init(profile: String?) {
        super.init(whattoreadwrite: .configuration, profile: profile, configpath: RcloneReference.shared.configpath)
        self.configurationsasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}
