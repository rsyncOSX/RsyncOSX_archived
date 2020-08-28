//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorageConfiguration: ReadWriteDictionary, SetConfigurations {
    // Variable holds all configuration data from persisten storage
    var configurationsasdictionary: [NSDictionary]?

    // Variable computes max hiddenID used
    // MaxhiddenID is used when new configurations are added.
    var maxhiddenID: Int {
        // Reading Configurations from memory
        if let store = self.configurations?.getConfigurations() {
            if store.count > 0 {
                _ = store.sorted { (config1, config2) -> Bool in
                    if config1.hiddenID > config2.hiddenID {
                        return true
                    } else {
                        return false
                    }
                }
                let index = store.count - 1
                return store[index].hiddenID
            }
        } else {
            return 0
        }
        return 0
    }

    // Read configurations from persisten store
    func readconfigurations() -> [Configuration]? {
        guard self.configurationsasdictionary != nil else { return nil }
        var configurations = [Configuration]()
        for dict in self.configurationsasdictionary ?? [] {
            configurations.append(Configuration(dictionary: dict))
        }
        return configurations
    }

    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        var array = [NSDictionary]()
        if let configurations = self.configurations?.getConfigurations() {
            for i in 0 ..< configurations.count {
                if let dict: NSMutableDictionary = ConvertConfigurations(index: i).configuration {
                    array.append(dict)
                }
            }
            self.writeToStore(array: array)
        }
    }

    // Add new configuration in memory to permanent storage
    func newConfigurations(dict: NSMutableDictionary) {
        var array = [NSDictionary]()
        if let configs: [Configuration] = self.configurations?.getConfigurations() {
            for i in 0 ..< configs.count {
                if let dict: NSMutableDictionary = ConvertConfigurations(index: i).configuration {
                    array.append(dict)
                }
            }
            dict.setObject(self.maxhiddenID + 1, forKey: "hiddenID" as NSCopying)
            array.append(dict)
            self.configurations?.appendconfigurationstomemory(dict: array[array.count - 1])
            self.saveconfigInMemoryToPersistentStore()
        }
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        if self.writeNSDictionaryToPersistentStorage(array: array) {
            self.configurationsDelegate?.reloadconfigurationsobject()
        }
    }

    init(profile: String?) {
        super.init(whattoreadwrite: .configuration, profile: profile, configpath: Configpath().configpath ?? "")
        if self.configurations == nil {
            self.configurationsasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }

    init(profile: String?, allprofiles _: Bool) {
        super.init(whattoreadwrite: .configuration, profile: profile, configpath: Configpath().configpath ?? "")
        self.configurationsasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}
