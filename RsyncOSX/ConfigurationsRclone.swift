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
    private var configurationsDataSource: [NSMutableDictionary]?

    func gethiddenID (index: Int) -> Int {
        return self.configurations![index].hiddenID
    }

    func configurationsDataSourcecount() -> Int {
        if self.configurationsDataSource == nil {
            return 0
        } else {
            return self.configurationsDataSource!.count
        }
    }

    func getConfigurationsDataSource() -> [NSMutableDictionary]? {
        return self.configurationsDataSource
    }

    func arguments4rclone (index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = (self.argumentAllConfigurations![index] as? RcloneArgumentsOneConfiguration)!
        switch argtype {
        case .arg:
            return allarguments.arg!
        case .argdryRun:
            return allarguments.argdryRun!
        }
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
        var data = [NSMutableDictionary]()
        self.configurationsDataSource = nil
        var batch: Int = 0
        for i in 0 ..< self.configurations!.count {
            if self.configurations![i].batch == "yes" {
                batch = 1
            } else {
                batch = 0
            }
            let row: NSMutableDictionary = [
                "taskCellID": self.configurations![i].task,
                "batchCellID": batch,
                "localCatalogCellID": self.configurations![i].localCatalog,
                "offsiteCatalogCellID": self.configurations![i].offsiteCatalog,
                "offsiteServerCellID": self.configurations![i].offsiteServer,
                "backupIDCellID": self.configurations![i].backupID,
                "runDateCellID": self.configurations![i].dateRun!,
                "daysID": self.configurations![i].dayssincelastbackup ?? ""
            ]
            data.append(row)
        }
        self.configurationsDataSource = data
    }

    init(profile: String?) {
        self.profile = profile
        self.storageapi = RclonePersistentStorageAPI(profile: self.profile)
        self.readconfigurations()
    }
}
