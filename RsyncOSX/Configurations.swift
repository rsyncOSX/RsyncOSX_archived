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
//  swiftlint:disable line_length

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
        PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
        // Call the view and do a refresh of tableView
        self.reloadtable(vcontroller: .vctabmain)
        _ = Logging(outputprocess: outputprocess)
    }

    // Function is updating Configurations in memory (by record) and
    // then saves updated Configurations from memory to persistent store
    func updateConfigurations(_ config: Configuration, index: Int) {
        self.configurations?[index] = config
        PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
    }

    // Function deletes Configuration in memory at hiddenID and
    // then saves updated Configurations from memory to persistent store.
    // Function computes index by hiddenID.
    func deleteConfigurationsByhiddenID(hiddenID: Int) {
        let index = self.configurations?.firstIndex(where: { $0.hiddenID == hiddenID }) ?? -1
        guard index > -1 else { return }
        self.configurations?.remove(at: index)
        PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
    }

    // Add new configurations
    func addNewConfigurations(_ dict: NSMutableDictionary) {
        PersistentStorageConfiguration(profile: self.profile).newConfigurations(dict: dict)
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

    private func increasesnapshotnum(index: Int) {
        let num = self.configurations?[index].snapshotnum ?? 0
        self.configurations![index].snapshotnum = num + 1
    }

    private func transform(object: ConfigurationsJson) -> Configuration {
        let dict = NSDictionary()
        dict.setValue(object.backupID ?? "", forKey: "backupID")
        dict.setValue(object.dateRun ?? "", forKey: "dateRun")
        dict.setValue(object.dayssincelastbackup ?? "", forKey: "dayssincelastbackup")
        dict.setValue(object.haltshelltasksonerror ?? "", forKey: "haltshelltasksonerror")
        dict.setValue(object.localCatalog ?? "", forKey: "localCatalog")
        dict.setValue(object.markdays ?? false, forKey: "markdays")
        dict.setValue(object.offsiteCatalog ?? "", forKey: "offsiteCatalog")
        dict.setValue(object.offsiteServer ?? "", forKey: "offsiteServer")
        dict.setValue(object.offsiteUsername ?? "", forKey: "offsiteUsername")
        dict.setValue(object.parameter1 ?? "", forKey: "parameter1")
        dict.setValue(object.parameter2 ?? "", forKey: "parameter2")
        dict.setValue(object.parameter3 ?? "", forKey: "parameter3")
        dict.setValue(object.parameter4 ?? "", forKey: "parameter4")
        dict.setValue(object.parameter5 ?? "", forKey: "parameter5")
        dict.setValue(object.parameter6 ?? "", forKey: "parameter6")
        dict.setValue(object.parameter8 ?? "", forKey: "parameter8")
        dict.setValue(object.parameter9 ?? "", forKey: "parameter9")
        dict.setValue(object.parameter10 ?? "", forKey: "parameter10")
        dict.setValue(object.parameter11 ?? "", forKey: "parameter11")
        dict.setValue(object.parameter12 ?? "", forKey: "parameter12")
        dict.setValue(object.parameter13 ?? "", forKey: "parameter13")
        dict.setValue(object.parameter14 ?? "", forKey: "parameter14")
        dict.setValue(object.rsyncdaemon ?? "", forKey: "rsyncdaemon")
        dict.setValue(object.sshkeypathandidentityfile ?? "", forKey: "sshkeypathandidentityfile")
        dict.setValue(object.sshport ?? "", forKey: "sshport")
        dict.setValue(object.task ?? "", forKey: "task")
        dict.setValue(object.hiddenID ?? 0, forKey: "hiddenID")
        dict.setValue(object.snapdayoffweek ?? 0, forKey: "snapdayoffweek")
        dict.setValue(object.snaplast ?? 0, forKey: "snaplast")
        dict.setValue(object.snapshotnum ?? 0, forKey: "snapshotnum")
        dict.setValue(object.pretask ?? "", forKey: "pretask")
        dict.setValue(object.executepretask ?? 0, forKey: "executepretask")
        dict.setValue(object.posttask ?? "", forKey: "posttask")
        dict.setValue(object.executeposttask ?? 0, forKey: "executeposttask")
        return Configuration(dictionary: dict)
    }

    func readconfigurations() {
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        // let store: [Configuration]? = PersistentStorageConfiguration(profile: self.profile).readconfigurations()
        let store = ReadWriteConfigurationsJSON(profile: self.profile).decodejson
        for i in 0 ..< (store?.count ?? 0) {
            let transformed = transform(object: (store?[i] as? ConfigurationsJson)!)
            if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                self.configurations?.append(transformed)
                let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: transformed)
                self.argumentAllConfigurations?.append(rsyncArgumentsOneConfig)
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
        self.readconfigurations()
        ViewControllerReference.shared.process = nil
    }
}
