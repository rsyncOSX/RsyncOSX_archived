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
//  swiftlint:disable line_length cyclomatic_complexity file_length function_body_length type_body_length trailing_comma

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

    // Variable computes max hiddenID used
    // MaxhiddenID is used when new configurations are added.
    var maxhiddenID: Int {
        // Reading Configurations from memory
        if let configurations = self.configurations {
            if configurations.count > 0 {
                _ = configurations.sorted { (config1, config2) -> Bool in
                    if config1.hiddenID > config2.hiddenID {
                        return true
                    } else {
                        return false
                    }
                }
                let index = configurations.count - 1
                return configurations[index].hiddenID
            }
        } else {
            return 0
        }
        return 0
    }

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
    func getConfigurations() -> [Configuration] {
        return self.configurations ?? []
    }

    // Function for getting arguments for all Configurations read into memory
    func getargumentAllConfigurations() -> [ArgumentsOneConfiguration] {
        return self.argumentAllConfigurations ?? []
    }

    // Function for getting Configurations read into memory
    // as datasource for tableViews
    func getConfigurationsDataSource() -> [NSDictionary]? {
        return self.configurationsDataSource
    }

    // Function for getting all Configurations
    func getConfigurationsDataSourceSynchronize() -> [NSMutableDictionary]? {
        guard self.configurations != nil else { return nil }
        var configurations = self.configurations!.filter {
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
        guard self.configurations != nil else { return nil }
        var configurations = self.configurations!.filter {
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

    // Function return arguments for rsync, either arguments for
    // real runn or arguments for --dry-run for Configuration at selected index
    func arguments4rsync(index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfigurations?[index]
        switch argtype {
        case .arg:
            return allarguments?.arg ?? []
        case .argdryRun:
            return allarguments?.argdryRun ?? []
        case .argdryRunlocalcataloginfo:
            return allarguments?.argdryRunLocalcatalogInfo ?? []
        }
    }

    // Function return arguments for rsync, either arguments for
    // real runn or arguments for --dry-run for Configuration at selected index
    func arguments4restore(index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfigurations?[index]
        switch argtype {
        case .arg:
            return allarguments?.restore ?? []
        case .argdryRun:
            return allarguments?.restoredryRun ?? []
        default:
            return []
        }
    }

    func arguments4tmprestore(index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfigurations?[index]
        switch argtype {
        case .arg:
            return allarguments?.tmprestore ?? []
        case .argdryRun:
            return allarguments?.tmprestoredryRun ?? []
        default:
            return []
        }
    }

    func arguments4verify(index: Int) -> [String] {
        let allarguments = self.argumentAllConfigurations?[index]
        return allarguments?.verify ?? []
    }

    // Function is adding new Configurations to existing in memory.
    func appendconfigurationstomemory(dict: NSDictionary) {
        let config = Configuration(dictionary: dict)
        self.configurations?.append(config)
    }

    func setCurrentDateonConfiguration(index: Int, outputprocess: OutputProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        let hiddenID = self.gethiddenID(index: index)
        let numbers = number.stats()
        self.schedules?.addlogpermanentstore(hiddenID: hiddenID, result: numbers)
        if self.configurations?[index].task == ViewControllerReference.shared.snapshot {
            self.increasesnapshotnum(index: index)
        }
        let currendate = Date()
        self.configurations?[index].dateRun = currendate.en_us_string_from_date()
        // Saving updated configuration in memory to persistent store
        if ViewControllerReference.shared.json {
            PersistentStorageConfigurationJSON(profile: self.profile).saveconfigInMemoryToPersistentStore()
        } else {
            PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
        }
        // Call the view and do a refresh of tableView
        self.reloadtable(vcontroller: .vctabmain)
        _ = Logging(outputprocess: outputprocess)
    }

    // Function is updating Configurations in memory (by record) and
    // then saves updated Configurations from memory to persistent store
    func updateConfigurations(_ config: Configuration, index: Int) {
        self.configurations?[index] = config
        if ViewControllerReference.shared.json {
            PersistentStorageConfigurationJSON(profile: self.profile).saveconfigInMemoryToPersistentStore()
        } else {
            PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
        }
    }

    // Function deletes Configuration in memory at hiddenID and
    // then saves updated Configurations from memory to persistent store.
    // Function computes index by hiddenID.
    func deleteConfigurationsByhiddenID(hiddenID: Int) {
        let index = self.configurations?.firstIndex(where: { $0.hiddenID == hiddenID }) ?? -1
        guard index > -1 else { return }
        self.configurations?.remove(at: index)
        if ViewControllerReference.shared.json {
            PersistentStorageConfigurationJSON(profile: self.profile).saveconfigInMemoryToPersistentStore()
        } else {
            PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
        }
    }

    // Add new configurations
    func addNewConfigurations(dict: NSMutableDictionary) {
        var config = Configuration(dictionary: dict)
        config.hiddenID = self.maxhiddenID + 1
        self.configurations?.append(config)
        if ViewControllerReference.shared.json {
            let store = PersistentStorageConfigurationJSON(profile: self.profile)
            store.saveconfigInMemoryToPersistentStore()
        } else {
            let store = PersistentStorageConfiguration(profile: self.profile)
            store.saveconfigInMemoryToPersistentStore()
        }
    }

    func getResourceConfiguration(_ hiddenID: Int, resource: ResourceInConfiguration) -> String {
        if let result = self.configurations?.filter({ ($0.hiddenID == hiddenID) }) {
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
        } else {
            return ""
        }
    }

    func getIndex(_ hiddenID: Int) -> Int {
        return self.configurations?.firstIndex(where: { $0.hiddenID == hiddenID }) ?? -1
    }

    func gethiddenID(index: Int) -> Int {
        guard index != -1, index < (self.configurations?.count ?? -1) else { return -1 }
        return self.configurations?[index].hiddenID ?? -1
    }

    func removecompressparameter(index: Int, delete: Bool) {
        guard index < (self.configurations?.count ?? -1) else { return }
        if delete {
            self.configurations?[index].parameter3 = ""
        } else {
            self.configurations?[index].parameter3 = "--compress"
        }
    }

    func removeedeleteparameter(index: Int, delete: Bool) {
        guard index < (self.configurations?.count ?? -1) else { return }
        if delete {
            self.configurations?[index].parameter4 = ""
        } else {
            self.configurations?[index].parameter4 = "--delete"
        }
    }

    func removeesshparameter(index: Int, delete: Bool) {
        guard index < (self.configurations?.count ?? -1) else { return }
        if delete {
            self.configurations?[index].parameter5 = ""
        } else {
            self.configurations?[index].parameter5 = "-e"
        }
    }

    func increasesnapshotnum(index: Int) {
        let num = self.configurations?[index].snapshotnum ?? 0
        self.configurations![index].snapshotnum = num + 1
    }

    func readconfigurationsplist() {
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        let store = PersistentStorageConfiguration(profile: self.profile).configurationsasdictionary
        for i in 0 ..< (store?.count ?? 0) {
            if let dict = store?[i] {
                let config = Configuration(dictionary: dict)
                if ViewControllerReference.shared.synctasks.contains(config.task) {
                    self.configurations?.append(config)
                    let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: config)
                    self.argumentAllConfigurations?.append(rsyncArgumentsOneConfig)
                }
            }
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var data = [NSMutableDictionary]()
        for i in 0 ..< (self.configurations?.count ?? 0) {
            let task = self.configurations?[i].task
            if ViewControllerReference.shared.synctasks.contains(task ?? "") {
                if let config = self.configurations?[i] {
                    data.append(ConvertOneConfig(config: config).dict)
                }
            }
        }
        self.configurationsDataSource = data
    }

    func readconfigurationsjson() {
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        let store = PersistentStorageConfigurationJSON(profile: self.profile).decodedjson
        for i in 0 ..< (store?.count ?? 0) {
            if let configitem = store?[i] as? DecodeConfigJSON {
                let transformed = transform(object: configitem)
                if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                    self.configurations?.append(transformed)
                    let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: transformed)
                    self.argumentAllConfigurations?.append(rsyncArgumentsOneConfig)
                }
            }
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var data = [NSMutableDictionary]()
        for i in 0 ..< (self.configurations?.count ?? 0) {
            let task = self.configurations?[i].task
            if ViewControllerReference.shared.synctasks.contains(task ?? "") {
                if let config = self.configurations?[i] {
                    data.append(ConvertOneConfig(config: config).dict)
                }
            }
        }
        self.configurationsDataSource = data
    }

    init(profile: String?) {
        self.configurations = [Configuration]()
        self.argumentAllConfigurations = nil
        self.configurationsDataSource = nil
        self.profile = profile
        if ViewControllerReference.shared.json {
            self.readconfigurationsjson()
        } else {
            self.readconfigurationsplist()
        }
        ViewControllerReference.shared.process = nil
    }
}

extension Configurations {
    func transform(object: DecodeConfigJSON) -> Configuration {
        var dayssincelastbackup: String?
        var markdays: Bool = false
        var lastruninseconds: Double? {
            if let date = object.dateRun {
                let lastbackup = date.en_us_date_from_string()
                let seconds: TimeInterval = lastbackup.timeIntervalSinceNow
                return seconds * (-1)
            } else {
                return nil
            }
        }
        // Last run of task
        if object.dateRun != nil {
            if let secondssince = lastruninseconds {
                dayssincelastbackup = String(format: "%.2f", secondssince / (60 * 60 * 24))
                if secondssince / (60 * 60 * 24) > ViewControllerReference.shared.marknumberofdayssince {
                    markdays = true
                }
            }
        }
        let dict: NSMutableDictionary = [
            "localCatalog": object.localCatalog ?? "",
            "offsiteCatalog": object.offsiteCatalog ?? "",
            "parameter1": object.parameter1 ?? "",
            "parameter2": object.parameter2 ?? "",
            "parameter3": object.parameter3 ?? "",
            "parameter4": object.parameter4 ?? "",
            "parameter5": object.parameter5 ?? "",
            "parameter6": object.parameter6 ?? "",
            "task": object.task ?? "",
            "hiddenID": object.hiddenID ?? 0,
            "lastruninseconds": lastruninseconds ?? 0,
            "dayssincelastbackup": dayssincelastbackup ?? "",
            "markdays": markdays,
        ]
        if object.parameter8?.isEmpty == false {
            dict.setObject(object.parameter8 ?? "", forKey: "parameter8" as NSCopying)
        }
        if object.parameter9?.isEmpty == false {
            dict.setObject(object.parameter9 ?? "", forKey: "parameter9" as NSCopying)
        }
        if object.parameter10?.isEmpty == false {
            dict.setObject(object.parameter10 ?? "", forKey: "parameter10" as NSCopying)
        }
        if object.parameter11?.isEmpty == false {
            dict.setObject(object.parameter11 ?? "", forKey: "parameter11" as NSCopying)
        }
        if object.parameter12?.isEmpty == false {
            dict.setObject(object.parameter12 ?? "", forKey: "parameter12" as NSCopying)
        }
        if object.parameter13?.isEmpty == false {
            dict.setObject(object.parameter13 ?? "", forKey: "parameter13" as NSCopying)
        }
        if object.parameter14?.isEmpty == false {
            dict.setObject(object.parameter14 ?? "", forKey: "parameter14" as NSCopying)
        }
        if object.sshkeypathandidentityfile?.isEmpty == false {
            dict.setObject(object.sshkeypathandidentityfile ?? "", forKey: "sshkeypathandidentityfile" as NSCopying)
        }
        if object.pretask?.isEmpty == false {
            dict.setObject(object.pretask ?? "", forKey: "pretask" as NSCopying)
        }
        if object.posttask?.isEmpty == false {
            dict.setObject(object.posttask ?? "", forKey: "posttask" as NSCopying)
        }
        if object.executepretask != nil {
            dict.setObject(object.executepretask ?? 0, forKey: "executepretask" as NSCopying)
        }
        if object.executeposttask != nil {
            dict.setObject(object.executeposttask ?? 0, forKey: "executeposttask" as NSCopying)
        }
        if object.sshport != nil {
            dict.setObject(object.sshport ?? 22, forKey: "sshport" as NSCopying)
        }
        if object.rsyncdaemon != nil {
            dict.setObject(object.rsyncdaemon ?? 0, forKey: "rsyncdaemon" as NSCopying)
        }
        if object.haltshelltasksonerror != nil {
            dict.setObject(object.haltshelltasksonerror ?? 0, forKey: "haltshelltasksonerror" as NSCopying)
        }
        if object.dateRun?.isEmpty == false {
            dict.setObject(object.dateRun ?? "", forKey: "dateRun" as NSCopying)
        }
        if object.snapdayoffweek?.isEmpty == false {
            dict.setObject(object.snapdayoffweek ?? "", forKey: "snapdayoffweek" as NSCopying)
        }
        if object.snaplast != nil {
            dict.setObject(object.snaplast ?? 0, forKey: "snaplast" as NSCopying)
        }
        if object.snapshotnum != nil {
            dict.setObject(object.snapshotnum ?? 0, forKey: "snapshotnum" as NSCopying)
        }
        if object.backupID?.isEmpty == false {
            dict.setObject(object.backupID ?? "", forKey: "backupID" as NSCopying)
        }
        if object.offsiteServer?.isEmpty == false {
            dict.setObject(object.offsiteServer ?? "", forKey: "offsiteServer" as NSCopying)
        }
        if object.offsiteUsername?.isEmpty == false {
            dict.setObject(object.offsiteUsername ?? "", forKey: "offsiteUsername" as NSCopying)
        }
        return Configuration(dictionary: dict as NSDictionary)
    }
}
