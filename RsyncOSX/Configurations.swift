//
//  Configurations.swift
//
//  The obect is the model for the Configurations but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  The object also holds various configurations for RsyncOSX and references to
//  some of the ViewControllers used in calls to delegate functions.
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable cyclomatic_complexity line_length

import Cocoa
import Foundation

class Configurations: ReloadTable, SetSchedules {
    var profile: String?
    // The main structure storing all Configurations for tasks
    var configurations: [Configuration]?
    // Array to store argumenst for all tasks.
    // Initialized during startup
    var argumentAllConfigurations: [ArgumentsOneConfiguration]?
    // Datasource for NSTableViews
    var configurationsDataSource: [NSMutableDictionary]?
    // backup list from remote info view
    var quickbackuplist: [Int]?
    // Estimated backup list, all backups
    var estimatedlist: [NSMutableDictionary]?
    // remote and local info
    var localremote: [NSDictionary]?
    // remote info tasks
    var remoteinfoestimation: RemoteinfoEstimation?
    // Reference to check TCP-connections
    var tcpconnections: TCPconnections?

    func setestimatedlistnil() -> Bool {
        if (self.estimatedlist?.count ?? 0) == (self.configurations?.count ?? 0) {
            return false
        } else {
            return true
        }
    }

    // Function for getting the profile
    func getProfile() -> String? {
        return self.profile
    }

    // Function for getting Configurations read into memory
    // - parameter none: none
    // - returns : Array of configurations
    func getConfigurations() -> [Configuration] {
        return self.configurations ?? []
    }

    // Function for getting arguments for all Configurations read into memory
    // - parameter none: none
    // - returns : Array of arguments
    func getargumentAllConfigurations() -> [ArgumentsOneConfiguration] {
        return self.argumentAllConfigurations ?? []
    }

    // Function for getting the number of configurations used in NSTableViews
    // - parameter none: none
    // - returns : Int
    func configurationsDataSourcecount() -> Int {
        return self.configurationsDataSource?.count ?? 0
    }

    // Function for getting Configurations read into memory
    // as datasource for tableViews
    // - parameter none: none
    // - returns : Array of Configurations
    func getConfigurationsDataSource() -> [NSDictionary]? {
        return self.configurationsDataSource
    }

    // Function for getting all Configurations
    // - parameter none: none
    // - returns : Array of NSDictionary
    func getConfigurationsDataSourceSynchronize() -> [NSMutableDictionary]? {
        var configurations: [Configuration] = self.configurations!.filter {
            ViewControllerReference.shared.synctasks.contains($0.task)
        }
        var data = [NSMutableDictionary]()
        for i in 0 ..< configurations.count {
            if configurations[i].offsiteServer.isEmpty == true {
                configurations[i].offsiteServer = "localhost"
            }
            let row: NSMutableDictionary = ConvertOneConfig(config: self.configurations![i]).dict
            if self.quickbackuplist != nil {
                let quickbackup = self.quickbackuplist!.filter { $0 == configurations[i].hiddenID }
                if quickbackup.count > 0 {
                    row.setValue(1, forKey: "selectCellID")
                }
            }
            data.append(row)
        }
        return data
    }

    func uniqueserversandlogins() -> [NSDictionary]? {
        var configurations: [Configuration] = self.configurations!.filter {
            ViewControllerReference.shared.synctasks.contains($0.task)
        }
        var data = [NSDictionary]()
        for i in 0 ..< configurations.count {
            if configurations[i].offsiteServer.isEmpty == true {
                configurations[i].offsiteServer = "localhost"
            }
            let row: NSDictionary = ConvertOneConfig(config: self.configurations![i]).dict
            let server = configurations[i].offsiteServer
            let user = configurations[i].offsiteUsername
            if server != "localhost" {
                if data.filter({ $0.value(forKey: "offsiteServerCellID") as? String ?? "" == server && $0.value(forKey: "offsiteUsernameID") as? String ?? "" == user }).count == 0 {
                    data.append(row)
                }
            }
        }
        return data
    }

    // Function computes arguments for rsync, either arguments for
    // real runn or arguments for --dry-run for Configuration at selected index
    // - parameter index: index of Configuration
    // - parameter argtype : either .arg or .argdryRun (of enumtype argumentsRsync)
    // - returns : array of Strings holding all computed arguments
    func arguments4rsync(index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfigurations![index]
        switch argtype {
        case .arg:
            return allarguments.arg ?? []
        case .argdryRun:
            return allarguments.argdryRun ?? []
        case .argdryRunlocalcataloginfo:
            return allarguments.argdryRunLocalcatalogInfo ?? []
        }
    }

    // Function computes arguments for rsync, either arguments for
    // real runn or arguments for --dry-run for Configuration at selected index
    // - parameter index: index of Configuration
    // - parameter argtype : either .arg or .argdryRun (of enumtype argumentsRsync)
    // - returns : array of Strings holding all computed arguments
    func arguments4restore(index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfigurations![index]
        switch argtype {
        case .arg:
            return allarguments.restore ?? []
        case .argdryRun:
            return allarguments.restoredryRun ?? []
        default:
            return []
        }
    }

    func arguments4tmprestore(index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfigurations![index]
        switch argtype {
        case .arg:
            return allarguments.tmprestore ?? []
        case .argdryRun:
            return allarguments.tmprestoredryRun ?? []
        default:
            return []
        }
    }

    func arguments4verify(index: Int) -> [String] {
        let allarguments = self.argumentAllConfigurations![index]
        return allarguments.verify ?? []
    }

    // Function is adding new Configurations to existing in memory.
    // - parameter dict : new record configuration
    func appendconfigurationstomemory(dict: NSDictionary) {
        let config = Configuration(dictionary: dict)
        self.configurations!.append(config)
    }

    func setCurrentDateonConfiguration(index: Int, outputprocess: OutputProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        let hiddenID = self.gethiddenID(index: index)
        let numbers = number.stats()
        self.schedules!.addlog(hiddenID: hiddenID, result: numbers)
        if self.configurations![index].task == ViewControllerReference.shared.snapshot {
            self.increasesnapshotnum(index: index)
        }
        let currendate = Date()
        self.configurations![index].dateRun = currendate.en_us_string_from_date()
        // Saving updated configuration in memory to persistent store
        _ = PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
        // Call the view and do a refresh of tableView
        self.reloadtable(vcontroller: .vctabmain)
        _ = Logging(outputprocess: outputprocess)
    }

    // Function is updating Configurations in memory (by record) and
    // then saves updated Configurations from memory to persistent store
    // - parameter config: updated configuration
    // - parameter index: index to Configuration to replace by config
    func updateConfigurations(_ config: Configuration, index: Int) {
        self.configurations![index] = config
        _ = PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
    }

    // Function deletes Configuration in memory at hiddenID and
    // then saves updated Configurations from memory to persistent store.
    // Function computes index by hiddenID.
    // - parameter hiddenID: hiddenID which is unique for every Configuration
    func deleteConfigurationsByhiddenID(hiddenID: Int) {
        let index = self.getIndex(hiddenID)
        self.configurations!.remove(at: index)
        _ = PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
    }

    // Add new configurations
    func addNewConfigurations(_ dict: NSMutableDictionary) {
        _ = PersistentStorageConfiguration(profile: self.profile).newConfigurations(dict: dict)
    }

    func getResourceConfiguration(_ hiddenID: Int, resource: ResourceInConfiguration) -> String {
        guard hiddenID > -1 else { return "" }
        let result = self.configurations!.filter { ($0.hiddenID == hiddenID) }
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
        case .sshport:
            if result[0].sshport != nil {
                return String(result[0].sshport!)
            } else {
                return ""
            }
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

    func gethiddenID(index: Int) -> Int {
        guard index != -1, index < (self.configurations?.count ?? -1) else { return -1 }
        return self.configurations![index].hiddenID
    }

    func removecompressparameter(index: Int, delete: Bool) {
        guard self.configurations != nil else { return }
        guard index < self.configurations!.count else { return }
        if delete {
            self.configurations![index].parameter3 = ""
        } else {
            self.configurations![index].parameter3 = "--compress"
        }
    }

    func removeedeleteparameter(index: Int, delete: Bool) {
        guard self.configurations != nil else { return }
        guard index < self.configurations!.count else { return }
        if delete {
            self.configurations![index].parameter4 = ""
        } else {
            self.configurations![index].parameter4 = "--delete"
        }
    }

    func removeesshparameter(index: Int, delete: Bool) {
        guard self.configurations != nil else { return }
        guard index < self.configurations!.count else { return }
        if delete {
            self.configurations![index].parameter5 = ""
        } else {
            self.configurations![index].parameter5 = "-e"
        }
    }

    private func increasesnapshotnum(index: Int) {
        guard self.configurations != nil else { return }
        let num = self.configurations![index].snapshotnum ?? 0
        self.configurations![index].snapshotnum = num + 1
    }

    func readconfigurations() {
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        let store: [Configuration]? = PersistentStorageConfiguration(profile: self.profile).getConfigurations()
        for i in 0 ..< (store?.count ?? 0) {
            if ViewControllerReference.shared.synctasks.contains(store![i].task) {
                self.configurations?.append(store![i])
                let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: store![i])
                self.argumentAllConfigurations!.append(rsyncArgumentsOneConfig)
            }
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var data = [NSMutableDictionary]()
        for i in 0 ..< (self.configurations?.count ?? 0) {
            let task = self.configurations?[i].task
            if ViewControllerReference.shared.synctasks.contains(task ?? "") {
                data.append(ConvertOneConfig(config: self.configurations![i]).dict)
            }
        }
        self.configurationsDataSource = data
    }

    init(profile: String?) {
        self.configurations = [Configuration]()
        self.argumentAllConfigurations = nil
        self.configurationsDataSource = nil
        self.profile = profile
        self.readconfigurations()
        ViewControllerReference.shared.process = nil
    }
}
