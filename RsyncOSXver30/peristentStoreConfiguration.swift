//
//  persistentBackupStore.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

// Interface between Configuration in memory and
// presistent store. Class is a interface
// for Configuration.

class persistentStoreConfiguration {
    
    // Get max hiddenID already used
    private var maxhiddenID : Int {
        get {
            // Reading Configurations from memory
            let store:[configuration] = SharingManagerConfiguration.sharedInstance.getConfigurations()
            if (store.count > 0) {
                _ = store.sorted { (config1, config2) -> Bool in
                    if (config1.hiddenID > config2.hiddenID) {
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
    }
    
    
    // Holding all configuration data
    private var configurationFromStore : [NSDictionary]?
    // Getting the configurations
    func getconfigurationFromStore() ->  [NSDictionary]? {
        return self.configurationFromStore
    }
    
    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        let array = NSMutableArray()
        // Reading Configurations from memory
        let Configurations:[configuration] = SharingManagerConfiguration.sharedInstance.getConfigurations()
        for i in 0 ..< Configurations.count {
            var config = Configurations[i]
            
            let dict:NSMutableDictionary = [
                "task" : config.task,
                "backupID":config.backupID,
                "localCatalog":config.localCatalog,
                "offsiteCatalog":config.offsiteCatalog,
                "batch":config.batch,
                "offsiteServer":config.offsiteServer,
                "offsiteUsername":config.offsiteUsername,
                "parameter1":config.parameter1,
                "parameter2":config.parameter2,
                "parameter3":config.parameter3,
                "parameter4":config.parameter4,
                "parameter5":config.parameter5,
                "parameter6":config.parameter6,
                "dryrun":config.dryrun,
                "rsync":config.rsync,
                "dateRun":config.dateRun!,
                "hiddenID":config.hiddenID]
            // All parameters parameter8 - parameter14 are set = nil if isEmpty
            if (config.parameter8 != nil) {
                if (config.parameter8!.isEmpty) {
                    config.parameter8 = nil
                } else {
                    dict.setObject(config.parameter8!, forKey: "parameter8" as NSCopying)
                }
            }
            if (config.parameter9 != nil) {
                if (config.parameter9!.isEmpty) {
                    config.parameter9 = nil
                } else {
                    dict.setObject(config.parameter9!, forKey: "parameter9" as NSCopying)
                }
            }
            if (config.parameter10 != nil) {
                if (config.parameter10!.isEmpty) {
                    config.parameter10 = nil
                } else {
                    dict.setObject(config.parameter10!, forKey: "parameter10" as NSCopying)
                }
            }
            if (config.parameter11 != nil) {
                if (config.parameter11!.isEmpty) {
                    config.parameter11 = nil
                } else {
                    dict.setObject(config.parameter11!, forKey: "parameter11" as NSCopying)
                }
            }
            if (config.parameter12 != nil) {
                if (config.parameter12!.isEmpty) {
                    config.parameter12 = nil
                } else {
                    dict.setObject(config.parameter12!, forKey: "parameter12" as NSCopying)
                }
            }
            if (config.parameter13 != nil) {
                if (config.parameter13!.isEmpty) {
                    config.parameter13 = nil
                } else {
                    dict.setObject(config.parameter13!, forKey: "parameter13" as NSCopying)
                }
            }
            if (config.parameter14 != nil) {
                if (config.parameter14!.isEmpty) {
                    config.parameter14 = nil
                } else {
                    dict.setObject(config.parameter14!, forKey: "parameter14" as NSCopying)
                }
            }
            if (config.rsyncdaemon != nil) {
                dict.setObject(config.rsyncdaemon!, forKey: "rsyncdaemon" as NSCopying)
            }
            if (config.sshport != nil) {
                dict.setObject(config.sshport!, forKey: "sshport" as NSCopying)
            }
            array[i] = dict
        }
        // Write array to persistent store
        self.writeToStore(array)
    }

    
    // Saving added configuration to memory store
    // NB : Function does NOT store Configurations to persistent store
    // Must call saveconfigToPersistentStore method
    func addConfigurationsToMemory (_ dict1 : NSMutableDictionary) {
        
        let localCatalog = dict1.value(forKey: "localCatalog") as? String
        let offsiteCatalog = dict1.value(forKey: "offsiteCatalog") as? String
        
        // If localCatalog == offsiteCataog do NOT append
        if (localCatalog != offsiteCatalog) {
            
            let array = NSMutableArray()
            // Get existing configurations from memory
            let Configurations:[configuration] = SharingManagerConfiguration.sharedInstance.getConfigurations()
            let j = Configurations.count
        
            // copy existing backups before adding
            for i in 0 ..< Configurations.count {
                var config = Configurations[i]
                let dict:NSMutableDictionary = [
                    "task" : config.task,
                    "backupID":config.backupID,
                    "localCatalog":config.localCatalog,
                    "offsiteCatalog":config.offsiteCatalog,
                    "batch":config.batch,
                    "offsiteServer":config.offsiteServer,
                    "offsiteUsername":config.offsiteUsername,
                    "parameter1":config.parameter1,
                    "parameter2":config.parameter2,
                    "parameter3":config.parameter3,
                    "parameter4":config.parameter4,
                    "parameter5":config.parameter5,
                    "parameter6":config.parameter6,
                    "dryrun":config.dryrun,
                    "rsync":config.rsync,
                    "dateRun":config.dateRun!,
                    "hiddenID":config.hiddenID]
                // All parameters parameter8 - parameter14 are set = nil if isEmpty
                if (config.parameter8 != nil) {
                    if (config.parameter8!.isEmpty) {
                        config.parameter8 = nil
                    } else {
                        dict.setObject(config.parameter8!, forKey: "parameter8" as NSCopying)
                    }
                }
                if (config.parameter9 != nil) {
                    if (config.parameter9!.isEmpty) {
                        config.parameter9 = nil
                    } else {
                        dict.setObject(config.parameter9!, forKey: "parameter9" as NSCopying)
                    }
                }
                if (config.parameter10 != nil) {
                    if (config.parameter10!.isEmpty) {
                        config.parameter10 = nil
                    } else {
                        dict.setObject(config.parameter10!, forKey: "parameter10" as NSCopying)
                    }
                }
                if (config.parameter11 != nil) {
                    if (config.parameter11!.isEmpty) {
                        config.parameter11 = nil
                    } else {
                        dict.setObject(config.parameter11!, forKey: "parameter11" as NSCopying)
                    }
                }
                if (config.parameter12 != nil) {
                    if (config.parameter12!.isEmpty) {
                        config.parameter12 = nil
                    } else {
                        dict.setObject(config.parameter12!, forKey: "parameter12" as NSCopying)
                    }
                }
                if (config.parameter13 != nil) {
                    if (config.parameter13!.isEmpty) {
                        config.parameter13 = nil
                    } else {
                        dict.setObject(config.parameter13!, forKey: "parameter13" as NSCopying)
                    }
                }
                if (config.parameter14 != nil) {
                    if (config.parameter14!.isEmpty) {
                        config.parameter14 = nil
                    } else {
                        dict.setObject(config.parameter14!, forKey: "parameter14" as NSCopying)
                    }
                }
                // All Ints are set
                if (config.rsyncdaemon != nil) {
                    dict.setObject(config.rsyncdaemon!, forKey: "rsyncdaemon" as NSCopying)
                }
                if (config.sshport != nil) {
                    dict.setObject(config.sshport!, forKey: "sshport" as NSCopying)
                }
                array[i] = dict
            }
            // backup part
            dict1.setObject(self.maxhiddenID + 1, forKey: "hiddenID" as NSCopying)
            array[j] = dict1
            //restore part
            let dict2:NSMutableDictionary = [
                "task" : "restore",
                "backupID":dict1.value(forKey: "backupID")!,
                "localCatalog":dict1.value(forKey: "localCatalog")!,
                "offsiteCatalog":dict1.value(forKey: "offsiteCatalog")!,
                "batch":dict1.value(forKey: "batch")!,
                "offsiteServer":dict1.value(forKey: "offsiteServer")!,
                "offsiteUsername":dict1.value(forKey: "offsiteUsername")!,
                "parameter1":dict1.value(forKey: "parameter1")!,
                "parameter2":dict1.value(forKey: "parameter2")!,
                "parameter3":dict1.value(forKey: "parameter3")!,
                "parameter4":dict1.value(forKey: "parameter4")!,
                "parameter5":dict1.value(forKey: "parameter5")!,
                "parameter6":dict1.value(forKey: "parameter6")!,
                "dryrun":dict1.value(forKey: "dryrun")!,
                "rsync":dict1.value(forKey: "rsync")!,
                "dateRun":"",
                "hiddenID":self.maxhiddenID + 2]
            if (dict1.value(forKey: "parameter8") != nil) {
                dict2.setObject(dict1.value(forKey: "parameter8")!, forKey: "parameter8" as NSCopying)
            }
            if (dict1.value(forKey: "parameter9") != nil) {
                dict2.setObject(dict1.value(forKey: "parameter9")!, forKey: "parameter9" as NSCopying)
            }
            if (dict1.value(forKey: "parameter10") != nil) {
                dict2.setObject(dict1.value(forKey: "parameter10")!, forKey: "parameter10" as NSCopying)
            }
            if (dict1.value(forKey: "parameter11") != nil) {
                dict2.setObject(dict1.value(forKey: "parameter11")!, forKey: "parameter11" as NSCopying)
            }
            if (dict1.value(forKey: "parameter12") != nil) {
                dict2.setObject(dict1.value(forKey: "parameter12")!, forKey: "parameter12" as NSCopying)
            }
            if (dict1.value(forKey: "parameter13") != nil) {
                dict2.setObject(dict1.value(forKey: "parameter13")!, forKey: "parameter13" as NSCopying)
            }
            if (dict1.value(forKey: "parameter14") != nil) {
                dict2.setObject(dict1.value(forKey: "parameter14")!, forKey: "parameter14" as NSCopying)
            }
            if (dict1.value(forKey: "rsyncdaemon") != nil) {
                dict2.setObject(dict1.value(forKey: "rsyncdaemon")!, forKey: "rsyncdaemon" as NSCopying)
            }
            if (dict1.value(forKey: "sshport") != nil) {
                dict2.setObject(dict1.value(forKey: "sshport")!, forKey: "sshport" as NSCopying)
            }
            array[j+1] = dict2
            // Append the two records to Configuration i memory
            // Important to save Confirguration from memory after this method
            SharingManagerConfiguration.sharedInstance.addConfigurationtoMemory(dict: dict1)
            SharingManagerConfiguration.sharedInstance.addConfigurationtoMemory(dict: dict2)
            // Method is only used from Adding New Configurations
        }
    }
    
    // Writing configuration to persistent store
    private func writeToStore (_ array: NSMutableArray) {
        // Getting the object just for the write method, no read from persistent store
        let save = readwritefiles(whattoread: enumtask.none)
        _ = save.writeDatatofile(array, task: enumtask.configuration)
    }
    
    
    init () {
        // Reading Configurations from memory or disk, if dirty read from disk
        // if not dirty set self.configurationFromStore to nil to tell
        // anyone to read Configurations from memory
        let read = readwritefiles(whattoread: enumtask.configuration)
        if let configurationFromstore = read.datafromStore {
            self.configurationFromStore = configurationFromstore
        } else {
            self.configurationFromStore = nil
        }
    }
}
