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
protocol RefreshtableViewtabMain : class {
    func refreshInMain()
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
    weak var refresh_delegate:RefreshtableViewtabMain?
 
    // NEW VERSION OF RSYNCOSX
    
    // Download URL if new version is avaliable
    // Variable is set during startup of application
    var URLnewVersion : String?
    var remindernewVersion : Bool = false
    
    // CONFIGURATIONS RSYNCOSX
    
    // If testdata
    // let testRun:Bool = true›
    var testRun:Bool = false
    // True if version 3.2.1 of rsync in /usr/local/bin
    // let rsyncVer3:Bool = true
    var rsyncVer3:Bool = false
    // Optional path to rsync
    var rsyncPath:String?
    // Detailed logging
    var detailedlogging:Bool = false
    // Minutes before scheduled task commence disable execute/batch buttons
    // Disabled by default
    var scheduledTaskdisableExecute:Double = 0
    
    // OTHER SETTINGS
    
    // During loading of configuration into memory also
    // copy (by /usr/bin/scp and NSTask) history.plist file
    // from server to local directory
    private var getHistory:Bool = false
    // reference to Process, used for kill in executing task
    var process:Process?
    // Variabl if arguments to Rsync is changed and must be read into memory again
    private var readRsyncArguments:Bool = true
    // Reference to NSViewObjects requiered for protocol functions for kikcking of scheduled jobs
    var ViewObjectMain: NSViewController?
    // Reference to NSViewObject for protocol functions for CopyFiles
    var CopyObjectMain:NSViewController?
    // Reference to the New NSViewObject
    var AddObjectMain:NSViewController?
    // Reference to the Operation object
    // Scheduled tasks
    var operation:completeScheduledOperation?

    
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

    
    // ALL THE GETTERS
    
    /// Function for returning the MacSerialNumber
    func getMacSerialNumber() -> String {
        if (self.MacSerialNumber != nil) {
            return self.MacSerialNumber!
        } else {
            // Compute it, set it and return
            self.MacSerialNumber = self.macSerialNumber()
            return self.MacSerialNumber!
        }
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
    /// Function for getting Configurations read into memory
    /// as datasource for tableViews
    /// - parameter none: none
    /// - returns : Array of Configurations
    func getConfigurationsDataSource() -> [NSMutableDictionary]? {
        return self.ConfigurationsDataSource
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
    
    /// Function for getting all Configurations marked as backup (not restore)
    /// - parameter none: none
    /// - returns : Array of NSDictionary
    func getConfigurationsDataSourcecountBackupOnly() -> [NSDictionary]? {
        let configurations:[configuration] = self.Configurations.filter({return ($0.task == "backup")})
        var row: NSMutableDictionary
        var data : [NSMutableDictionary] = []
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

    /// Function for returning count of all Configurations marked as backup (not restore)
    /// - parameter none: none
    /// - returns : Int
    func ConfigurationsDataSourcecountBackupOnlyCount() -> Int {
        if let count = self.getConfigurationsDataSourcecountBackupOnly()?.count {
            return count
        } else {
            return 0
        }
    }
    
    /// Function is reading all Configurations into memory from permanent store and
    /// prepare all arguments for rsync. All configurations are stored in the private
    /// variable within object.
    /// Function is destroying any previous Configurations before loading new 
    /// configurations and computing new arguments.
    /// - parameter none: none
    func getAllConfigurationsandArguments() {
        let store:[configuration] = storeAPI.sharedInstance.getConfigurations()
        self.destroyConfigurations()
        for i in 0 ..< store.count {
            let config = argumentsOneConfig(backupID: store[i].backupID, task: store[i].task, config:store[i], index: i)
            // Appending one (of many?) Config read from store to memory
            self.Configurations.append(store[i])
            // Appending all arguments for rsync for One configuration to memory
            let rsyncArgumentsConfig = argumentsConfigurations(rsyncArguments: config)
            self.argumentAllConfiguration.add(rsyncArgumentsConfig.rsyncArguments)
        }
        // Then prepare the datasource for use in tableviews
        var row: NSMutableDictionary?
        var data = [NSMutableDictionary]()
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
            data.append(row!)
        }
        self.ConfigurationsDataSource = data

    }

    
    /// Function computes arguments for rsync, either arguments for
    /// real runn or arguments for --dry-run for Configuration at selected index
    /// - parameter index: index of Configuration
    /// - parameter argtype : either .arg or .argdryRun (of enumtype argumentsRsync)
    /// - returns : array of Strings holding all computed arguments
    func getrsyncArgumentOneConfiguration (index:Int, argtype : argumentsRsync) -> [String] {
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
    private func destroyConfigurations() {
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
        storeAPI.sharedInstance.saveConfigFromMemory()
        // Reread Configuration and update datastructure for tableViews
        self.getAllConfigurationsandArguments()
        // Call the view and do a refresh of tableView
        if let pvc = self.ViewObjectMain as? ViewControllertabMain {
            self.refresh_delegate = pvc
            self.refresh_delegate?.refreshInMain()
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
        storeAPI.sharedInstance.saveConfigFromMemory()
    }
    
    /// Function deletes Configuration in memory at hiddenID and
    /// then saves updated Configurations from memory to persistent store.
    /// Function computes index by hiddenID.
    /// - parameter hiddenID: hiddenID which is unique for every Configuration
    func deleteConfigurationsByhiddenID (hiddenID:Int) {
        let index = self.getIndex(hiddenID)
        self.Configurations.remove(at: index)
        storeAPI.sharedInstance.saveConfigFromMemory()
    }
    
    // Storing data from run and batchrun
    private var bachtresult = [NSMutableDictionary]()
    
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
        storeAPI.sharedInstance.saveConfigFromMemory()
        // Reread Configuration and update datastructure for tableViews
        self.getAllConfigurationsandArguments()
        // Call the view and do a refresh of tableView
        if let pvc = self.ViewObjectMain as? ViewControllertabMain {
            self.refresh_delegate = pvc
            self.refresh_delegate?.refreshInMain()
        }
    }
    
    /// Function returns all Configurations marked for backup.
    /// - returns : array of Configurations
    func getConfigurationsBatch() -> [configuration] {
        return self.Configurations.filter({return ($0.task == "backup") && ($0.batch == "yes")})
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
        if (self.batchdata != nil) {
            return (self.batchdata?.getbatchDataQueuecount())!
        } else {
            return 0
        }
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
        if let _ = self.newConfigurations {
            self.newConfigurations?.append(row)
        } else {
            self.newConfigurations = [row]
        }
    }
    
    func newConfigurationsCount() -> Int {
        if let _ = self.newConfigurations {
            return self.newConfigurations!.count
        } else {
            return 0
        }
    }
    
    func getnewConfigurations () -> [NSMutableDictionary]? {
        return self.newConfigurations
    }
    
    // Function for appending new Configurations to memory
    func appendNewConfigurations () {
        storeAPI.sharedInstance.saveNewConfigurations()
    }
    
    
    // GET VALUES BY HIDDENID

    /// Function is getting the remote catalog in a spesific Configuration
    /// - parameter hiddenID: hiddenID for Configuration
    /// - returns : remote catalog
    func getremoteCatalog(_ hiddenID:Int) -> String {
        var result = self.Configurations.filter({return ($0.hiddenID == hiddenID)})
        if result.count > 0 {
            let config = result.removeFirst()
            return config.offsiteCatalog
        } else {
            return ""
        }
    }
    
    /// Function is getting the local catalog in a spesific Configuration
    /// - parameter hiddenID: hiddenID for Configuration
    /// - returns : local catalog
    func getlocalCatalog (_ hiddenID:Int) -> String {
        var result = self.Configurations.filter({return ($0.hiddenID == hiddenID)})
        if result.count > 0 {
            let config = result.removeFirst()
            return config.localCatalog
        } else {
            return ""
        }
    }
    
    /// Function is getting the remote server in a spesific Configuration
    /// - parameter hiddenID: hiddenID for Configuration
    /// - returns : remote server or empty server
    func getoffSiteserver (_ hiddenID:Int) -> String {
        var result = self.Configurations.filter({return ($0.hiddenID == hiddenID)})
        if result.count > 0 {
            let config = result.removeFirst()
            if config.offsiteServer.isEmpty {
                return "localhost"
            } else {
                return config.offsiteServer
            }
        } else {
            return ""
        }
    }
    
    /// Function is getting the task for a spesific Configuration
    /// - parameter hiddenID: hiddenID for Configuration
    /// - returns : task (either backup or restore)
    func gettask (_ hiddenID:Int) -> String {
        var result = self.Configurations.filter({return ($0.hiddenID == hiddenID)})
        if result.count > 0 {
            let config = result.removeFirst()
            return config.task
        } else {
            return ""
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
        var command:String = ""
        if (self.rsyncVer3) {
            if (self.rsyncPath == nil) {
                command = "/usr/local/bin/rsync"
            } else {
                command = self.rsyncPath! + "rsync"
            }
        } else {
            command = "/usr/bin/rsync"
        }
        return command
    }
    
    /// Function for computing MacSerialNumber
    /// - returns : the MacSerialNumber
    private func macSerialNumber() -> String {
        // Get the platform expert
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
        // Get the serial number as a CFString ( actually as Unmanaged<AnyObject>! )
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString!, kCFAllocatorDefault, 0);
        // Release the platform expert (we're responsible)
        IOObjectRelease(platformExpert);
        // Take the unretained value of the unmanaged-any-object
        // (so we're not responsible for releasing it)
        // and pass it back as a String or, if it fails, an empty string
        return (serialNumberAsCFString!.takeUnretainedValue() as? String) ?? ""
    }

    
}
