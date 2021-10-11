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
//  swiftlint:disable cyclomatic_complexity

import Foundation

class Configurations: ReloadTable {
    var profile: String?
    // The main structure storing all Configurations for tasks
    var configurations: [Configuration]?
    // Reference to check TCP-connections
    var tcpconnections: TCPconnections?
    // valid hiddenIDs
    var validhiddenID: Set<Int>?

    // Variable computes max hiddenID used
    // MaxhiddenID is used when new configurations are added.
    var maxhiddenID: Int {
        // Reading Configurations from memory
        if let configs = configurations {
            var setofhiddenIDs = Set<Int>()
            // Fill set with existing hiddenIDS
            for i in 0 ..< configs.count {
                setofhiddenIDs.insert(configs[i].hiddenID)
            }
            return setofhiddenIDs.max() ?? 0
        }
        return 0
    }

    // Function for getting the profile
    func getProfile() -> String? {
        return profile
    }

    // Function for getting Configurations read into memory
    func getConfigurations() -> [Configuration]? {
        return configurations
    }

    // Function return arguments for rsync, either arguments for
    // real runn or arguments for --dry-run for Configuration at selected index
    func arguments4rsync(hiddenID: Int, argtype: ArgumentsRsync) -> [String] {
        if let config = configurations?.filter({ $0.hiddenID == hiddenID }) {
            guard config.count == 1 else { return [] }
            switch argtype {
            case .arg:
                return ArgumentsSynchronize(config: config[0]).argumentssynchronize(dryRun: false,
                                                                                    forDisplay: false) ?? []
            case .argdryRun:
                return ArgumentsSynchronize(config: config[0]).argumentssynchronize(dryRun: true,
                                                                                    forDisplay: false) ?? []
            case .argdryRunlocalcataloginfo:
                guard config[0].task != SharedReference.shared.syncremote else { return [] }
                return ArgumentsLocalcatalogInfo(config: config[0]).argumentslocalcataloginfo(dryRun: true,
                                                                                              forDisplay: false) ?? []
            }
        }
        return []
    }

    // Function return arguments for rsync, either arguments for
    // real runn or arguments for --dry-run for Configuration at selected index
    func arguments4restore(hiddenID: Int, argtype: ArgumentsRsync) -> [String] {
        if let config = configurations?.filter({ $0.hiddenID == hiddenID }) {
            guard config.count == 1 else { return [] }
            switch argtype {
            case .arg:
                return ArgumentsRestore(config: config[0]).argumentsrestore(dryRun: false,
                                                                            forDisplay: false, tmprestore: false) ?? []
            case .argdryRun:
                return ArgumentsRestore(config: config[0]).argumentsrestore(dryRun: true,
                                                                            forDisplay: false, tmprestore: false) ?? []
            default:
                return []
            }
        }
        return []
    }

    func arguments4tmprestore(hiddenID: Int, argtype: ArgumentsRsync) -> [String] {
        if let config = configurations?.filter({ $0.hiddenID == hiddenID }) {
            guard config.count == 1 else { return [] }
            switch argtype {
            case .arg:
                return ArgumentsRestore(config: config[0]).argumentsrestore(dryRun: false,
                                                                            forDisplay: false, tmprestore: true) ?? []
            case .argdryRun:
                return ArgumentsRestore(config: config[0]).argumentsrestore(dryRun: true,
                                                                            forDisplay: false, tmprestore: true) ?? []
            default:
                return []
            }
        }
        return []
    }

    func arguments4verify(hiddenID: Int) -> [String] {
        if let config = configurations?.filter({ $0.hiddenID == hiddenID }) {
            guard config.count == 1 else { return [] }
            return ArgumentsVerify(config: config[0]).argumentsverify(forDisplay: false) ?? []
        }
        return []
    }

    // TODO: fix
    func setCurrentDateonConfiguration(index: Int, outputprocess: OutputfromProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        if let hiddenID = gethiddenID(index: index) {
            let numbers = number.stats()
            // schedules?.addlogpermanentstore(hiddenID: hiddenID, result: numbers)
            if configurations?[index].task == SharedReference.shared.snapshot {
                increasesnapshotnum(index: index)
            }
            let currendate = Date()
            configurations?[index].dateRun = currendate.en_us_string_from_date()
            // Saving updated configuration in memory to persistent store
            WriteConfigurationJSON(profile, configurations)
            // Call the view and do a refresh of tableView
            reloadtable(vcontroller: .vctabmain)
            _ = Logfile(TrimTwo(outputprocess?.getOutput() ?? []).trimmeddata, error: false)
        }
    }

    // Function is updating Configurations in memory (by record) and
    // then saves updated Configurations from memory to persistent store
    func updateConfigurations(_ config: Configuration?, index: Int) {
        if let config = config {
            configurations?[index] = config
            WriteConfigurationJSON(profile, configurations)
        }
    }

    // Function deletes Configuration in memory at hiddenID and
    // then saves updated Configurations from memory to persistent store.
    // Function computes index by hiddenID.
    func deleteConfigurationsByhiddenID(hiddenID: Int) {
        let index = configurations?.firstIndex(where: { $0.hiddenID == hiddenID }) ?? -1
        guard index > -1 else { return }
        configurations?.remove(at: index)
        WriteConfigurationJSON(profile, configurations)
    }

    // Add new configurations
    func addNewConfigurations(_ newconfig: Configuration) {
        var config = newconfig
        config.hiddenID = maxhiddenID + 1
        if configurations == nil {
            configurations = [Configuration]()
        }
        configurations?.append(config)
        WriteConfigurationJSON(profile, configurations)
    }

    func getResourceConfiguration(_ hiddenID: Int, resource: ResourceInConfiguration) -> String? {
        if let result = configurations?.filter({ $0.hiddenID == hiddenID }) {
            guard result.count > 0 else { return nil }
            switch resource {
            case .localCatalog:
                return result[0].localCatalog
            case .remoteCatalog:
                return result[0].offsiteCatalog
            case .offsiteServer:
                if result[0].offsiteServer.isEmpty {
                    return DictionaryStrings.localhost.rawValue
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
                    return String(result[0].sshport ?? 22)
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
    }

    func getIndex(_ hiddenID: Int) -> Int {
        return configurations?.firstIndex(where: { $0.hiddenID == hiddenID }) ?? -1
    }

    func gethiddenID(index: Int) -> Int? {
        guard index < (configurations?.count ?? 0) else { return nil }
        return configurations?[index].hiddenID
    }

    func removecompressparameter(index: Int, delete: Bool) {
        guard index < (configurations?.count ?? 0) else { return }
        if delete {
            configurations?[index].parameter3 = ""
        } else {
            configurations?[index].parameter3 = "--compress"
        }
    }

    func removeedeleteparameter(index: Int, delete: Bool) {
        guard index < (configurations?.count ?? 0) else { return }
        if delete {
            configurations?[index].parameter4 = ""
        } else {
            configurations?[index].parameter4 = "--delete"
        }
    }

    func removeesshparameter(index: Int, delete: Bool) {
        guard index < (configurations?.count ?? 0) else { return }
        if delete {
            configurations?[index].parameter5 = ""
        } else {
            configurations?[index].parameter5 = "-e"
        }
    }

    func increasesnapshotnum(index: Int) {
        if let num = configurations?[index].snapshotnum {
            configurations?[index].snapshotnum = num + 1
        }
    }

    init(profile: String?) {
        self.profile = profile
        configurations = nil
        let readconfigrations = ReadConfigurationJSON(profile)
        configurations = readconfigrations.configurations
        validhiddenID = readconfigrations.validhiddenIDs
        SharedReference.shared.process = nil
    }
}
