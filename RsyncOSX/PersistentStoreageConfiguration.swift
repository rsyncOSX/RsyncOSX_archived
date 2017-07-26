//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//
// Interface between Configuration in memory and
// presistent store. Class is a interface
// for Configuration.
//  swiftlint:disable syntactic_sugar line_length cyclomatic_complexity function_body_length

import Foundation

final class PersistentStoreageConfiguration: Readwritefiles {

    /// Variable computes max hiddenID used
    /// MaxhiddenID is used when new configurations
    /// are added.
    private var maxhiddenID: Int {
        // Reading Configurations from memory
        let store: [Configuration] = Configurations.shared.getConfigurations()
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
        let configurations: [Configuration] = Configurations.shared.getConfigurations()
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
            let configurations: [Configuration] = Configurations.shared.getConfigurations()

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
                Configurations.shared.addConfigurationtoMemory(dict: array[array.count - 2])
                Configurations.shared.addConfigurationtoMemory(dict: array[array.count - 1])
            } else {
                // Singlefile Configuration - only adds the copy part
                Configurations.shared.addConfigurationtoMemory(dict: array[array.count - 1])
            }
            // Method is only used from Adding New Configurations
        }
    }

    // Function for returning a NSMutabledictionary from a configuration record
    private func dictionaryFromconfig (index: Int) -> NSMutableDictionary {

        var config: Configuration = Configurations.shared.getConfigurations()[index]
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
            "rsync": config.rsync,
            "dateRun": config.dateRun!,
            "hiddenID": config.hiddenID]
        // All parameters parameter8 - parameter14 are set = nil if isEmpty
        if config.parameter8 != nil {
            if config.parameter8!.isEmpty {
                config.parameter8 = nil
            } else {
                dict.setObject(config.parameter8!, forKey: "parameter8" as NSCopying)
            }
        }
        if config.parameter9 != nil {
            if config.parameter9!.isEmpty {
                config.parameter9 = nil
            } else {
                dict.setObject(config.parameter9!, forKey: "parameter9" as NSCopying)
            }
        }
        if config.parameter10 != nil {
            if config.parameter10!.isEmpty {
                config.parameter10 = nil
            } else {
                dict.setObject(config.parameter10!, forKey: "parameter10" as NSCopying)
            }
        }
        if config.parameter11 != nil {
            if config.parameter11!.isEmpty {
                config.parameter11 = nil
            } else {
                dict.setObject(config.parameter11!, forKey: "parameter11" as NSCopying)
            }
        }
        if config.parameter12 != nil {
            if config.parameter12!.isEmpty {
                config.parameter12 = nil
            } else {
                dict.setObject(config.parameter12!, forKey: "parameter12" as NSCopying)
            }
        }
        if config.parameter13 != nil {
            if config.parameter13!.isEmpty {
                config.parameter13 = nil
            } else {
                dict.setObject(config.parameter13!, forKey: "parameter13" as NSCopying)
            }
        }
        if config.parameter14 != nil {
            if config.parameter14!.isEmpty {
                config.parameter14 = nil
            } else {
                dict.setObject(config.parameter14!, forKey: "parameter14" as NSCopying)
            }
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
            "rsync": dict.value(forKey: "rsync")!,
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
        // Getting the object just for the write method, no read from persistent store
        _ = self.writeDictionarytofile(array, task: .configuration)
    }

    init () {
        // Create the readwritefiles object
        super.init(task: .configuration)
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
