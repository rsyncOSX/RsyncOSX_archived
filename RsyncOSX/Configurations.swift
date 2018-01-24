//
//  Configurations.swift
//
//  This object stays in memory runtime and holds key data and operations on Configurations.
//  The obect is the model for the Configurations but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  The object also holds various configurations for RsyncOSX and references to
//  some of the ViewControllers used in calls to delegate functions.
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar line_length file_length

import Foundation
import Cocoa

// Protocol for returning object Configurations
protocol GetConfigurationsObject: class {
    func getconfigurationsobject() -> Configurations?
    func createconfigurationsobject(profile: String?) -> Configurations?
    func reloadconfigurationsobject()
}

protocol SetConfigurations {
    weak var configurationsDelegate: GetConfigurationsObject? { get }
    var configurations: Configurations? { get }
}

extension SetConfigurations {
    weak var configurationsDelegate: GetConfigurationsObject? {
       return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
    var configurations: Configurations? {
        return self.configurationsDelegate?.getconfigurationsobject()
    }
}

// Protocol for doing a refresh of tabledata
protocol Reloadandrefresh: class {
    func reloadtabledata()
}

protocol ReloadTable {
    weak var reloadDelegateMain: Reloadandrefresh? { get }
    weak var reloadDelegateSchedule: Reloadandrefresh? { get }
    weak var reloadDelegateBatch: Reloadandrefresh? { get }
    weak var reloadDelegateLogData: Reloadandrefresh? { get }
    func reloadtable(vcontroller: ViewController)
}

extension ReloadTable {
    weak var reloadDelegateMain: Reloadandrefresh? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
    weak var reloadDelegateSchedule: Reloadandrefresh? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
    }
    weak var reloadDelegateBatch: Reloadandrefresh? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
    }
    weak var reloadDelegateLogData: Reloadandrefresh? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
    }

    func reloadtable(vcontroller: ViewController) {
        if vcontroller == .vctabmain {
            self.reloadDelegateMain?.reloadtabledata()
        } else if vcontroller == .vctabschedule {
            self.reloadDelegateSchedule?.reloadtabledata()
        } else if vcontroller == .vcbatch {
            self.reloadDelegateBatch?.reloadtabledata()
        } else {
            self.reloadDelegateLogData?.reloadtabledata()
        }
    }
}

// Used to select argument
enum ArgumentsRsync {
    case arg
    case argdryRun
}

// Enum which resource to return
enum ResourceInConfiguration {
    case remoteCatalog
    case localCatalog
    case offsiteServer
    case task
}

class Configurations: ReloadTable {

    // Storage API
    var storageapi: PersistentStorageAPI?
    // reference to Process, used for kill in executing task
    var process: Process?
    // Kind of Operation method. eiher Timer or DispatchWork
    var operation: OperationObject = .dispatch
    private var profile: String?
    // Notify about scheduled process
    // Only allowed to notity by modal window when in main view
    var allowNotifyinMain: Bool = true
    // Reference to singletask object
    var singleTask: SingleTask?
    // The main structure storing all Configurations for tasks
    private var configurations: Array<Configuration>?
    // Array to store argumenst for all tasks.
    // Initialized during startup
    private var argumentAllConfigurations: NSMutableArray?
    // Datasource for NSTableViews
    private var configurationsDataSource: Array<NSMutableDictionary>?
    // Object for batchQueue data and operations
    private var batchQueue: BatchTaskWorkQueu?
    // backup list from remote info view
    var quickbackuplist: Array<Int>?
    // Estimated backup list, all backups
    var estimatedlist: Array<NSMutableDictionary>?

    /// Function for getting the profile
    func getProfile() -> String? {
        return self.profile
    }

    /// Function for getting Configurations read into memory
    /// - parameter none: none
    /// - returns : Array of configurations
    func getConfigurations() -> Array<Configuration> {
        return self.configurations ?? []
    }

    /// Function for getting arguments for all Configurations read into memory
    /// - parameter none: none
    /// - returns : Array of arguments
    func getargumentAllConfigurations() -> NSMutableArray {
        guard self.argumentAllConfigurations != nil else {
            return []
        }
        return self.argumentAllConfigurations!
    }

    /// Function for getting the number of configurations used in NSTableViews
    /// - parameter none: none
    /// - returns : Int
    func configurationsDataSourcecount() -> Int {
        if self.configurationsDataSource == nil {
            return 0
        } else {
            return self.configurationsDataSource!.count
        }
    }

    /// Function for getting Configurations read into memory
    /// as datasource for tableViews
    /// - parameter none: none
    /// - returns : Array of Configurations
    func getConfigurationsDataSource() -> [NSMutableDictionary]? {
        return self.configurationsDataSource
    }

    /// Function for getting all Configurations marked as backup (not restore)
    /// - parameter none: none
    /// - returns : Array of NSDictionary
    func getConfigurationsDataSourcecountBackup() -> [NSMutableDictionary]? {
        let configurations: [Configuration] = self.configurations!.filter({return ($0.task == "backup" || $0.task == "snapshot")})
        var row =  NSMutableDictionary()
        var data = Array<NSMutableDictionary>()
        for i in 0 ..< configurations.count {
            row = [
                "taskCellID": configurations[i].task,
                "hiddenID": configurations[i].hiddenID,
                "localCatalogCellID": configurations[i].localCatalog,
                "offsiteCatalogCellID": configurations[i].offsiteCatalog,
                "offsiteServerCellID": configurations[i].offsiteServer,
                "backupIDCellID": configurations[i].backupID,
                "runDateCellID": configurations[i].dateRun!,
                "daysID": configurations[i].dayssincelastbackup ?? "",
                "markdays": configurations[i].markdays,
                "selectCellID": 0
            ]
            if (row.value(forKey: "offsiteServerCellID") as? String)?.isEmpty == true {
                row.setValue("localhost", forKey: "offsiteServerCellID")
            }
            if self.quickbackuplist != nil {
                let quickbackup = self.quickbackuplist!.filter({$0 == configurations[i].hiddenID})
                if quickbackup.count > 0 {
                    row.setValue(1, forKey: "selectCellID")
                }
            }
            data.append(row)
        }
        return data
    }

    func getConfigurationsDataSourcecountBackupSnapshot() -> [NSDictionary]? {
        var configurations: [Configuration] = self.configurations!.filter({return ($0.task == "backup" || $0.task == "snapshot" )})
        var data = Array<NSDictionary>()
        for i in 0 ..< configurations.count {
            if configurations[i].offsiteServer.isEmpty == true {
                configurations[i].offsiteServer = "localhost"
            }
            let row: NSDictionary = [
                "taskCellID": configurations[i].task,
                "hiddenID": configurations[i].hiddenID,
                "localCatalogCellID": configurations[i].localCatalog,
                "offsiteCatalogCellID": configurations[i].offsiteCatalog,
                "offsiteServerCellID": configurations[i].offsiteServer,
                "backupIDCellID": configurations[i].backupID,
                "runDateCellID": configurations[i].dateRun!,
                "daysID": configurations[i].dayssincelastbackup ?? "",
                "markdays": configurations[i].markdays,
                "selectCellID": 0
            ]
            data.append(row)
        }
        return data
    }

    /// Function returns all Configurations marked for backup.
    /// - returns : array of Configurations
    func getConfigurationsBatch() -> [Configuration] {
        return self.configurations!.filter({return ($0.task == "backup" || $0.task == "snapshot" ) && ($0.batch == "yes")})
    }

    /// Function computes arguments for rsync, either arguments for
    /// real runn or arguments for --dry-run for Configuration at selected index
    /// - parameter index: index of Configuration
    /// - parameter argtype : either .arg or .argdryRun (of enumtype argumentsRsync)
    /// - returns : array of Strings holding all computed arguments
    func arguments4rsync (index: Int, argtype: ArgumentsRsync) -> Array<String> {
        let allarguments = (self.argumentAllConfigurations![index] as? ArgumentsOneConfiguration)!
        switch argtype {
        case .arg:
            return allarguments.arg!
        case .argdryRun:
            return allarguments.argdryRun!
        }
    }

    /// Function is adding new Configurations to existing in memory.
    /// - parameter dict : new record configuration
    func appendconfigurationstomemory (dict: NSDictionary) {
        let config = Configuration(dictionary: dict)
        self.configurations!.append(config)
    }

    /// Function sets currentDate on Configuration when executed on task
    /// stored in memory and then saves updated configuration from memory to persistent store.
    /// Function also notifies Execute view to refresh data
    /// in tableView.
    /// - parameter index: index of Configuration to update
    func setCurrentDateonConfiguration (_ index: Int) {
        let currendate = Date()
        let dateformatter = Tools().setDateformat()
        self.configurations![index].dateRun = dateformatter.string(from: currendate)
        // Saving updated configuration in memory to persistent store
        self.storageapi!.saveConfigFromMemory()
        // Call the view and do a refresh of tableView
        self.reloadtable(vcontroller: .vctabmain)
    }

    /// Function destroys reference to object holding data and
    /// methods for executing batch work
    func deleteBatchData() {
        self.batchQueue = nil
    }

    /// Function is updating Configurations in memory (by record) and
    /// then saves updated Configurations from memory to persistent store
    /// - parameter config: updated configuration
    /// - parameter index: index to Configuration to replace by config
    func updateConfigurations (_ config: Configuration, index: Int) {
        self.configurations![index] = config
        self.storageapi!.saveConfigFromMemory()
    }

    /// Function deletes Configuration in memory at hiddenID and
    /// then saves updated Configurations from memory to persistent store.
    /// Function computes index by hiddenID.
    /// - parameter hiddenID: hiddenID which is unique for every Configuration
    func deleteConfigurationsByhiddenID (hiddenID: Int) {
        let index = self.getIndex(hiddenID)
        self.configurations!.remove(at: index)
        self.storageapi!.saveConfigFromMemory()
    }

    /// Function toggles Configurations for batch or no
    /// batch. Function updates Configuration in memory
    /// and stores Configuration i memory to
    /// persisten store
    /// - parameter index: index of Configuration to toogle batch on/off
    func setBatchYesNo (_ index: Int) {
        if self.configurations![index].batch == "yes" {
            self.configurations![index].batch = "no"
        } else {
            self.configurations![index].batch = "yes"
        }
        self.storageapi!.saveConfigFromMemory()
        self.reloadtable(vcontroller: .vctabmain)
    }

    // Create batchQueue
    func createbatchQueue() {
        self.batchQueue = BatchTaskWorkQueu(configurations: self)
    }

    /// Function return the reference to object holding data and methods
    /// for batch execution of Configurations.
    /// - returns : reference to to object holding data and methods
    func getbatchQueue() -> BatchTaskWorkQueu? {
        return self.batchQueue
    }

    /// Function is getting the number of rows batchDataQueue
    /// - returns : the number of rows
    func batchQueuecount() -> Int {
        return self.batchQueue?.getbatchDataQueuecount() ?? 0
    }

    /// Function is getting the updated batch data queue
    /// - returns : reference to the batch data queue
    func getupdatedbatchQueue() -> Array<NSMutableDictionary>? {
        return self.batchQueue?.getupdatedBatchdata()
    }

    // Add new configurations
    func addNewConfigurations(_ dict: NSMutableDictionary) {
        self.storageapi!.addandsaveNewConfigurations(dict: dict)
    }

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

    func removecompressparameter(index: Int, delete: Bool) {
        guard self.configurations != nil else { return }
        guard index < self.configurations!.count  else { return }
        if delete {
            self.configurations![index].parameter3 = ""
        } else {
            self.configurations![index].parameter3 = "--compress"
        }
    }

    func increasesnapshotnum(index: Int, outputprocess: OutputProcess?) {
        guard self.configurations != nil else { return }
        let num = self.configurations![index].snapshotnum ?? 0
        self.configurations![index].snapshotnum  = num + 1
        // self.updatelinkcurrent(index: index, outputprocess: outputprocess)
    }

    private func updatelinkcurrent(index: Int, outputprocess: OutputProcess?) {
        let config = self.configurations![index]
        var args: SnapshotCurrentArguments?
        if config.offsiteServer.isEmpty == false {
            args = SnapshotCurrentArguments(config: config, remote: true)
        } else {
            args = SnapshotCurrentArguments(config: config, remote: false)
        }
        let updatecurrent = SnapshotCurrent(command: args!.getCommand(), arguments: args!.getArguments())
        updatecurrent.executeProcess(outputprocess: outputprocess)
    }

    /// Function is reading all Configurations into memory from permanent store and
    /// prepare all arguments for rsync. All configurations are stored in the private
    /// variable within object.
    /// Function is destroying any previous Configurations before loading new and computing new arguments.
    /// - parameter none: none
    private func readconfigurations() {
        self.configurations = Array<Configuration>()
        self.argumentAllConfigurations = NSMutableArray()
        var store: Array<Configuration>? = self.storageapi!.getConfigurations()
        guard store != nil else { return }
        for i in 0 ..< store!.count {
            self.configurations!.append(store![i])
            let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: store![i])
            self.argumentAllConfigurations!.add(rsyncArgumentsOneConfig)
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var row =  NSMutableDictionary()
        var data = Array<NSMutableDictionary>()
        self.configurationsDataSource = nil
        var batch: Int = 0
        for i in 0 ..< self.configurations!.count {
            if self.configurations![i].batch == "yes" {
                batch = 1
            } else {
                batch = 0
            }
            row = [
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

    init(profile: String?, viewcontroller: NSViewController) {
        self.configurations = nil
        self.argumentAllConfigurations = nil
        self.configurationsDataSource = nil
        self.profile = profile
        self.storageapi = PersistentStorageAPI(profile: self.profile)
        self.readconfigurations()
    }
}
