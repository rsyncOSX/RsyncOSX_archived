//
//  PersistentStoreageUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorageUserconfiguration: ReadWriteDictionary {

    /// Variable holds all configuration data
    var userconfiguration: [NSDictionary]?

    // Saving user configuration
    func saveUserconfiguration () {
        if let array: [NSDictionary] = ConvertUserconfiguration().userconfiguration {
            self.writeToStore(array: array)
        }
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        // Getting the object just for the write method, no read from persistent store
        _ = self.writeNSDictionaryToPersistentStorage(array)
    }

    init (readfromstorage: Bool) {
        super.init(whattoreadwrite: .userconfig, profile: nil, configpath: ViewControllerReference.shared.configpath)
        if readfromstorage {
            self.userconfiguration = self.readNSDictionaryFromPersistentStore()
        }
    }
}
