//
//  ConfigurationsRclone.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class RcloneConfigurations {

    var storageapi: RclonePersistentStorageAPI?
    private var profile: String?
    private var configurations: [RcloneConfiguration]?
    private var argumentAllConfigurations: [RcloneArgumentsOneConfiguration]?
    private var configurationsDataSource: [NSMutableDictionary]?

    func getResourceConfiguration(_ hiddenID: Int, resource: ResourceInConfiguration) -> String {
        var result = self.configurations!.filter({return ($0.hiddenID == hiddenID)})
        guard result.count > 0 else { return "" }
        switch resource {
        case .localCatalog:
            return result[0].localCatalog
        case .remoteCatalog:
            return result[0].offsiteCatalog
        case .offsiteServer:
            if result[0].offsiteServer.isEmpty {
                return "localhost"
            } else {
                return result[0].offsiteServer
            }
        case .task:
            return result[0].task
        case .backupid:
            return result[0].backupID
        case .offsiteusername:
            return result[0].offsiteUsername
        }
    }

    func getIndex(_ hiddenID: Int) -> Int {
        var index: Int = -1
        loop: for i in 0 ..< self.configurations!.count where self.configurations![i].hiddenID == hiddenID {
            index = i
            break loop
        }
        return index
    }

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
        let allarguments = self.argumentAllConfigurations![index]
        switch argtype {
        case .arg:
            return allarguments.arg ?? []
        case .argdryRun:
            return allarguments.argdryRun ?? []
        default:
            return []
        }
    }

    func getConfigurations() -> [RcloneConfiguration] {
        return self.configurations ?? []
    }

    private func readconfigurations() {
        self.configurations = [RcloneConfiguration]()
        self.argumentAllConfigurations = [RcloneArgumentsOneConfiguration]()
        var store: [RcloneConfiguration]? = self.storageapi!.getConfigurations()
        guard store != nil else { return }
        for i in 0 ..< store!.count {
            self.configurations!.append(store![i])
            let rsyncArgumentsOneConfig = RcloneArgumentsOneConfiguration(config: store![i])
            self.argumentAllConfigurations!.append(rsyncArgumentsOneConfig)
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
