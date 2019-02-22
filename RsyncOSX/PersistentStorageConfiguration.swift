//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable function_body_length cyclomatic_complexity line_length

import Foundation

final class PersistentStorageConfiguration: ReadWriteDictionary, SetConfigurations {

    /// Variable holds all configuration data from persisten storage
    var configurationsasdictionary: [NSDictionary]?

    /// Variable computes max hiddenID used
    /// MaxhiddenID is used when new configurations are added.
    private var maxhiddenID: Int {
        // Reading Configurations from memory
        let store: [Configuration] = self.configurations!.getConfigurations()
        if store.count > 0 {
            _ = store.sorted { (config1, config2) -> Bool in
                if config1.hiddenID > config2.hiddenID {
                    return true
                } else {
                    return false
                }
            }
            let index = store.count-1
            return store[index].hiddenID
        } else {
            return 0
        }
    }

    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        var array = [NSDictionary]()
        // Reading Configurations from memory
        let configs: [Configuration] = self.configurations!.getConfigurations()
        for i in 0 ..< configs.count {
            array.append(self.dictionaryFromconfig(index: i))
        }
        // Write array to persistent store
        self.writeToStore(array: array)
    }

    // Add new configuration in memory to permanent storage
    // NB : Function does NOT store Configurations to persistent store
    func newConfigurations(dict: NSMutableDictionary) {
        var array = [NSDictionary]()
        // Get existing configurations from memory
        let configs: [Configuration] = self.configurations!.getConfigurations()
        // copy existing backups before adding
        for i in 0 ..< configs.count {
            array.append(self.dictionaryFromconfig(index: i))
        }
        // backup part
        dict.setObject(self.maxhiddenID + 1, forKey: "hiddenID" as NSCopying)
        dict.removeObject(forKey: "singleFile")
        array.append(dict)
        self.configurations!.appendconfigurationstomemory(dict: array[array.count - 1])
    }

    // Function for returning a NSMutabledictionary from a configuration record
    private func dictionaryFromconfig(index: Int) -> NSMutableDictionary {
        var config: Configuration = self.configurations!.getConfigurations()[index]
        let dict: NSMutableDictionary = [
            "task": config.task,
            "backupID": config.backupID,
            "localCatalog": config.localCatalog,
            "offsiteCatalog": config.offsiteCatalog,
            "batch": config.batch,
            "offsiteServer": config.offsiteServer,
            "offsiteUsername": config.offsiteUsername,
            "parameter1": config.parameter1,
            "parameter2": config.parameter2,
            "parameter3": config.parameter3,
            "parameter4": config.parameter4,
            "parameter5": config.parameter5,
            "parameter6": config.parameter6,
            "dryrun": config.dryrun,
            "dateRun": config.dateRun!,
            "hiddenID": config.hiddenID]
        // All parameters parameter8 - parameter14 are set
        config.parameter8 = self.checkparameter(param: config.parameter8)
        if config.parameter8 != nil {
            dict.setObject(config.parameter8!, forKey: "parameter8" as NSCopying)
        }
        config.parameter9 = self.checkparameter(param: config.parameter9)
        if config.parameter9 != nil {
            dict.setObject(config.parameter9!, forKey: "parameter9" as NSCopying)
        }
        config.parameter10 = self.checkparameter(param: config.parameter10)
        if config.parameter10 != nil {
            dict.setObject(config.parameter10!, forKey: "parameter10" as NSCopying)
        }
        config.parameter11 = self.checkparameter(param: config.parameter11)
        if config.parameter11 != nil {
            dict.setObject(config.parameter11!, forKey: "parameter11" as NSCopying)
        }
        config.parameter12 = self.checkparameter(param: config.parameter12)
        if config.parameter12 != nil {
            dict.setObject(config.parameter12!, forKey: "parameter12" as NSCopying)
        }
        config.parameter13 = self.checkparameter(param: config.parameter13)
        if config.parameter13 != nil {
            dict.setObject(config.parameter13!, forKey: "parameter13" as NSCopying)
        }
        config.parameter14 = self.checkparameter(param: config.parameter14)
        if config.parameter14 != nil {
            dict.setObject(config.parameter14!, forKey: "parameter14" as NSCopying)
        }
        if config.rsyncdaemon != nil {
            dict.setObject(config.rsyncdaemon!, forKey: "rsyncdaemon" as NSCopying)
        }
        if config.sshport != nil {
            dict.setObject(config.sshport!, forKey: "sshport" as NSCopying)
        }
        if config.snapshotnum != nil {
            dict.setObject(config.snapshotnum!, forKey: "snapshotnum" as NSCopying)
        }
        if config.rclonehiddenID != nil {
            dict.setObject(config.rclonehiddenID!, forKey: "rclonehiddenID" as NSCopying)
        }
        if config.rcloneprofile != nil {
            dict.setObject(config.rcloneprofile!, forKey: "rcloneprofile" as NSCopying)
        }
        return dict
    }

    private func checkparameter(param: String?) -> String? {
        if let parameter = param {
            guard parameter.isEmpty == false else { return nil }
            return parameter
        } else {
            return nil
        }
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        if self.writeNSDictionaryToPersistentStorage(array) {
            self.configurationsDelegate?.reloadconfigurationsobject()
        }
    }

    init (profile: String?) {
        super.init(whattoreadwrite: .configuration, profile: profile, configpath: ViewControllerReference.shared.configpath)
        if self.configurations == nil {
            self.configurationsasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }

    init (profile: String?, allprofiles: Bool) {
        super.init(whattoreadwrite: .configuration, profile: profile, configpath: ViewControllerReference.shared.configpath)
        self.configurationsasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}
