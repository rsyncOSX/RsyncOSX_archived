//
//  SharingManagerConfiguration.swift
//  Rsync
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

import Foundation
import Cocoa

// Used to select argument
enum argumentsRsync {
    case arg
    case argdryRun
}

// Protocol for doing a refresh of updated tableView
protocol RefreshtableView: class {
    // Declare function for refresh tableView
    func refresh()
}

class SharingManagerConfiguration {
    
    // Creates a singelton of this class
    class var  sharedInstance: SharingManagerConfiguration {
        struct Singleton {
            static let instance = SharingManagerConfiguration()
        }
        return Singleton.instance
    }
    
    // Variabl if Data is changed, saved to Store
    // and must be read into memory again
    private var dirtyData:Bool = true
    // Get value
    func isDataDirty() -> Bool {
        return self.dirtyData
    }
    // Set value
    func setDataDirty(dirty:Bool) {
        self.dirtyData = dirty
    }
    
    // Delegate functions
    weak var refresh_delegate:RefreshtableView?
 
    // NEW VERSION OF RSYNCOSX
    // Download URL if new version is avaliable
    var URLnewVersion : String?
    
    // CONFIGURATIONS RSYNCOSX
    
    // True if version 3.2.1 of rsync in /usr/local/bin
    // let rsyncVer3:Bool = true
    var rsyncVer3:Bool = false
    // Optional path to rsync
    var rsyncPath:String?
    // No valid rsyncPath - true if no valid rsync is found
    var noRysync:Bool = false
    // Detailed logging
    var detailedlogging:Bool = true
    // Minutes before scheduled task commence disable execute/batch buttons
    // Disabled by default
    var scheduledTaskdisableExecute:Double = 0
    // Allow double click to activate single tasks
    var allowDoubleclick:Bool = true
    
    // OTHER SETTINGS
    
    // reference to Process, used for kill in executing task
    var process:Process?
    // Variabl if arguments to Rsync is changed and must be read into memory again
    private var readRsyncArguments:Bool = true
    // Reference to manin View
    var ViewObjectMain: NSViewController?
    // Reference to Copy files
    var CopyObjectMain:NSViewController?
    // Reference to the Add tasks
    var AddObjectMain:NSViewController?
    // Reference to the  Schedule
    var ScheduleObjectMain:NSViewController?
    // Reference to the Operation object
    // Reference is set in when Scheduled task is executed
    var operation:completeScheduledOperation?
    // Which profile to use, if default nil
    var LogObjectMain:NSViewController?
    private var profile:String?
    // Notify about scheduled process
    // Only allowed to notity by modal window when in main view
    var allowNotifyinMain:Bool = false
    // If rsync error reset workqueue
    var rsyncerror:Bool = true
    // Reference to helper
    var help:Help?

    
    // DATA STRUCTURES
    
    // The main structure storing all Configurations for tasks
    private var Configurations = [configuration]()
    // Array to store argumenst for all tasks.
    // Initialized during startup
    private var argumentAllConfiguration =  NSMutableArray()
    // Datasource for NSTableViews
    private var ConfigurationsDataSource : [NSMutableDictionary]?
    // Object for batchQueue data and operations
    private var batchdata:batchOperations?
    // the MacSerialNumber
    private var MacSerialNumber:String?

    
    // READ and SET all Configurations and arguments for rsync in object
    
    
    /// Function is reading all Configurations into memory from permanent store and
    /// prepare all arguments for rsync. All configurations are stored in the private
    /// variable within object.
    /// Function is destroying any previous Configurations before loading new
    /// configurations and computing new arguments.
    /// - parameter none: none
    func readAllConfigurationsAndArguments() {
        let store:[configuration] = persistentStoreAPI.sharedInstance.getConfigurations()
        self.destroyConfigurations()
        // We read all stored configurations into memory
        for i in 0 ..< store.count {
            let config = argumentsOneConfig(backupID: store[i].backupID, task: store[i].task, config:store[i], index: i)
            // Appending one (of many?) Config read from store to memory
            self.Configurations.append(store[i])
            // Appending all arguments for rsync for One configuration to memory
            let rsyncArgumentsConfig = argumentsConfigurations(rsyncArguments: config)
            self.argumentAllConfiguration.add(rsyncArgumentsConfig.rsyncArguments!)
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var row =  NSMutableDictionary()
        var data = Array<NSMutableDictionary>()
        self.destroyConfigurationsDataSource()
        var batch:Int = 0
        for i in 0 ..< self.Configurations.count {
            if(self.Configurations[i].batch == "yes") {
                batch = 1
            } else {
                batch = 0
            }
            row = [
                "taskCellID": self.Configurations[i].task,
                "batchCellID":batch,
                "localCatalogCellID":self.Configurations[i].localCatalog,
                "offsiteCatalogCellID":self.Configurations[i].offsiteCatalog,
                "offsiteServerCellID":self.Configurations[i].offsiteServer,
                "backupIDCellID":self.Configurations[i].backupID,
                "runDateCellID":self.Configurations[i].dateRun!
            ]
            data.append(row)
        }
        self.ConfigurationsDataSource = data
    }
    
    // ALL THE GETTERS
    
    /// Function for getting the profile
    /// If not set profile is nil
    func getProfile() -> String? {
        return self.profile
    }
    
    /// Function for setting the profile
    func setProfile(profile:String?) {
        self.profile = profile
    }
    
    /// Function for returning the MacSerialNumber
    func getMacSerialNumber() -> String {
        guard (self.MacSerialNumber != nil) else {
            // Compute it, set it and return
            self.MacSerialNumber = self.macSerialNumber()
            return self.MacSerialNumber!
        }
        return self.MacSerialNumber!
    }
    
    /// Function for getting Configurations read into memory
    /// - parameter none: none
    /// - returns : Array of configurations
    func getConfigurations() -> [configuration] {
        return self.Configurations
    }
    
    /// Function for getting arguments for all Configurations read into memory
    /// - parameter none: none
    /// - returns : Array of arguments
    func getargumentAllConfigurations() -> NSMutableArray {
        return self.argumentAllConfiguration
    }
    
    /// Function for getting the number of configurations used in NSTableViews
    /// - parameter none: none
    /// - returns : Int
    func ConfigurationsDataSourcecount() -> Int {
        if (self.ConfigurationsDataSource == nil) {
            return 0
        } else {
            return self.ConfigurationsDataSource!.count
        }
    }

    /// Function for getting Configurations read into memory
    /// as datasource for tableViews
    /// - parameter none: none
    /// - returns : Array of Configurations
    func getConfigurationsDataSource() -> [NSMutableDictionary]? {
        return self.ConfigurationsDataSource
    }
    
    /// Function for getting all Configurations marked as backup (not restore)
    /// - parameter none: none
    /// - returns : Array of NSDictionary
    func getConfigurationsDataSourcecountBackupOnly() -> [NSDictionary]? {
        let configurations:[configuration] = self.Configurations.filter({return ($0.task == "backup")})
        var row =  NSDictionary()
        var data = Array<NSDictionary>()
        for i in 0 ..< configurations.count {
            row = [
                "taskCellID": configurations[i].task,
                "hiddenID":configurations[i].hiddenID,
                "localCatalogCellID":configurations[i].localCatalog,
                "offsiteCatalogCellID":configurations[i].offsiteCatalog,
                "offsiteServerCellID":configurations[i].offsiteServer,
                "backupIDCellID":configurations[i].backupID,
                "runDateCellID":configurations[i].dateRun!
            ]
            data.append(row)
        }
    return data
    }
    
    /// Function returns all Configurations marked for backup.
    /// - returns : array of Configurations
    func getConfigurationsBatch() -> [configuration] {
        return self.Configurations.filter({return ($0.task == "backup") && ($0.batch == "yes")})
    }

    /// Function for returning count of all Configurations marked as backup (not restore)
    /// - parameter none: none
    /// - returns : Int
    func ConfigurationsDataSourcecountBackupOnlyCount() -> Int {
        if let number = self.getConfigurationsDataSourcecountBackupOnly() {
            return number.count
        } else {
            return 0
        }
    }
    
    /// Function computes arguments for rsync, either arguments for
    /// real runn or arguments for --dry-run for Configuration at selected index
    /// - parameter index: index of Configuration
    /// - parameter argtype : either .arg or .argdryRun (of enumtype argumentsRsync)
    /// - returns : array of Strings holding all computed arguments
    func getRsyncArgumentOneConfig (index:Int, argtype : argumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfiguration[index] as! argumentsOneConfig
        switch argtype {
        case .arg:
            return allarguments.arg!
        case .argdryRun:
            return allarguments.argdryRun!
        }
    }

    /// Function is adding new Configurations to existing
    /// configurations in memory.
    /// - parameter dict : new record configuration
    func addConfigurationtoMemory (dict:NSDictionary) {
        let config = configuration(dictionary: dict)
        self.Configurations.append(config)
    }
    
    // DESTROY FUNCTIONS
    
    /// Function destroys records holding added configurations
    func destroyNewConfigurations() {
        self.newConfigurations = nil
    }

    
    /// Function destroys records holding added configurations as datasource 
    /// for presenting Configurations in tableviews
    private func destroyConfigurationsDataSource() {
        self.ConfigurationsDataSource = nil
    }
    
    /// Function destroys records holding data about all Configurations, all
    /// arguments for Configurations and configurations as datasource for
    /// presenting Configurations in tableviews.
    func destroyConfigurations() {
        self.Configurations.removeAll()
        self.argumentAllConfiguration.removeAllObjects()
        self.ConfigurationsDataSource = nil
    }

    /// Function sets currentDate on Configuration when executed on task 
    /// stored in memory and then saves updated configuration from memory to persistent store.
    /// Function also notifies Execute view to refresh data
    /// in tableView.
    /// - parameter index: index of Configuration to update
    func setCurrentDateonConfiguration (_ index:Int) {
        let currendate = Date()
        let dateformatter = Utils.sharedInstance.setDateformat()
        self.Configurations[index].dateRun = dateformatter.string(from: currendate)
        // Saving updated configuration in memory to persistent store
        persistentStoreAPI.sharedInstance.saveConfigFromMemory()
        // Reread Configuration and update datastructure for tableViews
        self.readAllConfigurationsAndArguments()
        // Call the view and do a refresh of tableView
        if let pvc = self.ViewObjectMain as? ViewControllertabMain {
            self.refresh_delegate = pvc
            self.refresh_delegate?.refresh()
        }
    }
    
    
    /// Function destroys reference to object holding data and 
    /// methods for executing batch work
    func deleteBatchData() {
        self.batchdata = nil
    }
    
    /// Function is updating Configurations in memory (by record) and
    /// then saves updated Configurations from memory to persistent store
    /// - parameter config: updated configuration
    /// - parameter index: index to Configuration to replace by config
    func updateConfigurations (_ config: configuration, index:Int) {
        self.Configurations[index] = config
        persistentStoreAPI.sharedInstance.saveConfigFromMemory()
    }
    
    /// Function deletes Configuration in memory at hiddenID and
    /// then saves updated Configurations from memory to persistent store.
    /// Function computes index by hiddenID.
    /// - parameter hiddenID: hiddenID which is unique for every Configuration
    func deleteConfigurationsByhiddenID (hiddenID:Int) {
        let index = self.getIndex(hiddenID)
        self.Configurations.remove(at: index)
        persistentStoreAPI.sharedInstance.saveConfigFromMemory()
    }
    
    /// Function toggles Configurations for batch or no
    /// batch. Function updates Configuration in memory
    /// and stores Configuration i memory to 
    /// persisten store
    /// - parameter index: index of Configuration to toogle batch on/off
    func setBatchYesNo (_ index:Int) {
        if (self.Configurations[index].batch == "yes") {
            self.Configurations[index].batch = "no"
        } else {
            self.Configurations[index].batch = "yes"
        }
        persistentStoreAPI.sharedInstance.saveConfigFromMemory()
        // Reread Configuration and update datastructure for tableViews
        self.readAllConfigurationsAndArguments()
        // Call the view and do a refresh of tableView
        if let pvc = self.ViewObjectMain as? ViewControllertabMain {
            self.refresh_delegate = pvc
            self.refresh_delegate?.refresh()
        }
    }
    
    /// Function sets reference to object holding data and methods
    /// for batch execution of Configurations
    /// - parameter batchdata: object holding data and methods for executing Configurations in batch
    func setbatchDataQueue (batchdata:batchOperations) {
        self.batchdata = batchdata
    }
    
    /// Function return the reference to object holding data and methods
    /// for batch execution of Configurations.
    /// - returns : reference to to object holding data and methods
    func getBatchdataObject() -> batchOperations? {
        return self.batchdata
    }

    /// Function is getting the number of rows batchDataQueue
    /// - returns : the number of rows
    func batchDataQueuecount() -> Int {
        guard (self.batchdata != nil) else {
            return 0
        }
        return self.batchdata!.getbatchDataQueuecount()
    }
    
    /// Function is getting the updated batch data queue
    /// - returns : reference to the batch data queue
    func getbatchDataQueue() -> [NSMutableDictionary]? {
        return self.batchdata?.getupdatedBatchdata()
    }
    
    // ADDING CONFIGURATUÌONS
    
    // Temporary structure to hold added Configurations before writing to permanent store
    private var newConfigurations :[NSMutableDictionary]?
    
    func addNewConfigurations(_ row: NSMutableDictionary) {
        guard (self.newConfigurations != nil) else {
            self.newConfigurations = [row]
            return
        }
        self.newConfigurations!.append(row)
    }
    
    func newConfigurationsCount() -> Int {
        guard (self.newConfigurations != nil) else {
            return 0
        }
        return self.newConfigurations!.count
    }
    
    /// Function is getting all added (new) configurations
    /// - returns : Array of Dictionary storing all new configurations
    func getnewConfigurations () -> [NSMutableDictionary]? {
        return self.newConfigurations
    }
    
    // Function for appending new Configurations to memory
    func appendNewConfigurations () {
        persistentStoreAPI.sharedInstance.saveNewConfigurations()
    }
    
    
    // GET VALUES BY HIDDENID
    
    // Enum which resource to return
    enum resourceInConfiguration {
        case remoteCatalog
        case localCatalog
        case offsiteServer
        case task
    }
    
    /// Function is getting the remote catalog in a spesific Configuration
    /// - parameter hiddenID: hiddenID for Configuration
    /// - parameter resource: which resource to get from configuration
    /// - returns : resource
    func getResourceConfiguration(_ hiddenID:Int, resource:resourceInConfiguration) -> String {
        
        var result = self.Configurations.filter({return ($0.hiddenID == hiddenID)})
        
        guard result.count > 0 else {
            return ""
        }
        
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
    
    /// Function is getting the index of a spesific Configuration
    /// - parameter hiddenID: hiddenID for Configuration
    /// - returns : index of Configuration
    func getIndex(_ hiddenID:Int) -> Int {
        var index:Int = -1
        loop: for i in 0 ..< self.Configurations.count {
            if (self.Configurations[i].hiddenID == hiddenID) {
                index = i
                break loop
            }
        }
        return index
    }
    
    /// Function is getting the hiddenID for a spesific Configuration
    /// - parameter index: index for Configuration
    /// - returns : hiddenID for Configuration
    func gethiddenID (index : Int) -> Int {
        return self.Configurations[index].hiddenID
    }

    /// Function returns the correct path for rsync
    /// according to configuration set by user or
    /// default value.
    /// - returns : full path of rsync command
    func setRsyncCommand() -> String {
        if (self.rsyncVer3) {
            if (self.rsyncPath == nil) {
                return "/usr/local/bin/rsync"
            } else {
                return self.rsyncPath! + "rsync"
            }
        } else {
            return "/usr/bin/rsync"
        }
    }
    
    /// Function for computing MacSerialNumber
    /// - returns : the MacSerialNumber
    private func macSerialNumber() -> String {
        // Get the platform expert
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        // Get the serial number as a CFString ( actually as Unmanaged<AnyObject>! )
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString!, kCFAllocatorDefault, 0)
        // Release the platform expert (we're responsible)
        IOObjectRelease(platformExpert)
        // Take the unretained value of the unmanaged-any-object
        // (so we're not responsible for releasing it)
        // and pass it back as a String or, if it fails, an empty string
        return (serialNumberAsCFString!.takeUnretainedValue() as? String) ?? ""
    }

    
}
