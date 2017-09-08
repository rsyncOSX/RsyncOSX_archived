//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar function_body_length

import Foundation

protocol Readupdatedconfigurations: class {
    func readAllConfigurationsAndArguments()
}

final class PersistentStorageConfiguration: Readwritefiles {

    /// Variable computes max hiddenID used
    /// MaxhiddenID is used when new configurations are added.
    private var maxhiddenID: Int {
        // Reading Configurations from memory
        let store: [Configuration] = self.configurationsNoS!.getConfigurations()
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

    /// Variable holds all configuration data
    private var configurations: [NSDictionary]?

    /// Function reads configurations from permanent store
    /// - returns : array of NSDictonarys, return might be nil if configuration is already in memory
    func readConfigurationsFromPermanentStore() -> [NSDictionary]? {
        return self.configurations
    }

    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        var array = Array<NSDictionary>()
        // Reading Configurations from memory
        let configurations: [Configuration] = self.configurationsNoS!.getConfigurations()
        for i in 0 ..< configurations.count {
            array.append(self.dictionaryFromconfig(index: i))
        }
        // Write array to persistent store
        self.writeToStore(array)
    }

    // Saving added configuration to memory store
    // NB : Function does NOT store Configurations to persistent store
    // Must call saveconfigToPersistentStore method
    func addConfigurationsToMemory (_ backup: NSMutableDictionary) {
        let localCatalog = backup.value(forKey: "localCatalog") as? String
        let offsiteCatalog = backup.value(forKey: "offsiteCatalog") as? String
        let singleFile = backup.value(forKey: "singleFile") as? Int
        // If localCatalog == offsiteCataog do NOT append
        if localCatalog != offsiteCatalog {
            var array = Array<NSDictionary>()
            // Get existing configurations from memory
            let configurations: [Configuration] = self.configurationsNoS!.getConfigurations()
            // copy existing backups before adding
            for i in 0 ..< configurations.count {
                array.append(self.dictionaryFromconfig(index: i))
            }
            // backup part
            backup.setObject(self.maxhiddenID + 1, forKey: "hiddenID" as NSCopying)
            backup.removeObject(forKey: "singleFile")
            array.append(backup)
            if singleFile == 0 {
                array.append(self.setRestorePart(dict: backup))
                // Append the two records to Configuration i memory
                // Important to save Configuration from memory after this method
                self.configurationsNoS!.addConfigurationtoMemory(dict: array[array.count - 2])
                self.configurationsNoS!.addConfigurationtoMemory(dict: array[array.count - 1])
            } else {
                // Singlefile Configuration - only adds the copy part
                self.configurationsNoS!.addConfigurationtoMemory(dict: array[array.count - 1])
            }
            // Method is only used from Adding New Configurations
        }
    }

    // Function for returning a NSMutabledictionary from a configuration record
    private func dictionaryFromconfig (index: Int) -> NSMutableDictionary {
        var config: Configuration = self.configurationsNoS!.getConfigurations()[index]
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
            dict.setObject(config.parameter8!, forKey: "parameter9" as NSCopying)
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
        // All Ints are set
        if config.rsyncdaemon != nil {
            dict.setObject(config.rsyncdaemon!, forKey: "rsyncdaemon" as NSCopying)
        }
        if config.sshport != nil {
            dict.setObject(config.sshport!, forKey: "sshport" as NSCopying)
        }
        return dict
    }

    private func checkparameter (param: String?) -> String? {
        if let parameter = param {
            guard parameter.isEmpty == false else {
                return nil
            }
            return parameter
        } else {
            return nil
        }
    }

    // Function for setting the restore part of newly created added configuration
    // based on dictionary for backup part.
    private func setRestorePart (dict: NSMutableDictionary) -> NSMutableDictionary {
        let restore: NSMutableDictionary = [
            "task": "restore",
            "backupID": dict.value(forKey: "backupID")!,
            "localCatalog": dict.value(forKey: "localCatalog")!,
            "offsiteCatalog": dict.value(forKey: "offsiteCatalog")!,
            "batch": dict.value(forKey: "batch")!,
            "offsiteServer": dict.value(forKey: "offsiteServer")!,
            "offsiteUsername": dict.value(forKey: "offsiteUsername")!,
            "parameter1": dict.value(forKey: "parameter1")!,
            "parameter2": dict.value(forKey: "parameter2")!,
            "parameter3": dict.value(forKey: "parameter3")!,
            "parameter4": dict.value(forKey: "parameter4")!,
            "parameter5": dict.value(forKey: "parameter5")!,
            "parameter6": dict.value(forKey: "parameter6")!,
            "dryrun": dict.value(forKey: "dryrun")!,
            "dateRun": "",
            "hiddenID": self.maxhiddenID + 2]
        if dict.value(forKey: "parameter8") != nil {
            restore.setObject(dict.value(forKey: "parameter8")!, forKey: "parameter8" as NSCopying)
        }
        if dict.value(forKey: "parameter9") != nil {
            restore.setObject(dict.value(forKey: "parameter9")!, forKey: "parameter9" as NSCopying)
        }
        if dict.value(forKey: "parameter10") != nil {
            restore.setObject(dict.value(forKey: "parameter10")!, forKey: "parameter10" as NSCopying)
        }
        if dict.value(forKey: "parameter11") != nil {
            restore.setObject(dict.value(forKey: "parameter11")!, forKey: "parameter11" as NSCopying)
        }
        if dict.value(forKey: "parameter12") != nil {
            restore.setObject(dict.value(forKey: "parameter12")!, forKey: "parameter12" as NSCopying)
        }
        if dict.value(forKey: "parameter13") != nil {
            restore.setObject(dict.value(forKey: "parameter13")!, forKey: "parameter13" as NSCopying)
        }
        if dict.value(forKey: "parameter14") != nil {
            restore.setObject(dict.value(forKey: "parameter14")!, forKey: "parameter14" as NSCopying)
        }
        if dict.value(forKey: "rsyncdaemon") != nil {
            restore.setObject(dict.value(forKey: "rsyncdaemon")!, forKey: "rsyncdaemon" as NSCopying)
        }
        if dict.value(forKey: "sshport") != nil {
            restore.setObject(dict.value(forKey: "sshport")!, forKey: "sshport" as NSCopying)
        }
        return restore
    }

    // Writing configuration to persistent store
    // Configuration is Array<NSDictionary>
    private func writeToStore (_ array: Array<NSDictionary>) {
        if (self.writeDatatoPersistentStorage(array, task: .configuration)) {
            // self.configurationsDelegate?.createconfigurationsobject(profile: nil)
        }
    }

    init (profile: String?) {

        super.init(task: .configuration, profile: profile)
        // Reading Configurations from memory or disk, if dirty read from disk
        // if not dirty set self.configurationFromStore to nil to tell
        // anyone to read Configurations from memory
        if let configurationFromPersistentstore = self.getDatafromfile() {
            self.configurations = configurationFromPersistentstore
        } else {
            self.configurations = nil
        }
    }
}
