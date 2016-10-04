//
//  readwritefiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/06/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation


// let str = "/Rsync/" + serialNumber + "/scheduleRsync.plist"
// let str = "/Rsync/" + serialNumber + "/configRsync.plist"
// let str = "/Rsync/" + serialNumber + "/config.plist"
// let str = "/Rsync/" + serialNumber + "/rsyncarguments.plist"

enum enumtask {
    case schedule
    case configuration
    case config
    case rsyncarguments
    case none
}

class readwritefiles {
    
    // What is read from file is read into this variable
    var datafromStore : [NSDictionary]?
    // Name set for schedule, configuration or config
    private var name:String?
    // key in objectForKey, e.g key for reading what
    private var key:String?
    // Default reading from disk
    // The class either reads data from persistent store or
    // returns nil if data is NOT dirty
    private var readdisk:Bool = true
    
    // Set which file to read
    private var fileName : String? {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let docuDir = paths.firstObject as! String
            self.createDirectory((docuDir + "/Rsync/" + SharingManagerConfiguration.sharedInstance.getMacSerialNumber()))
            let str = "/Rsync/" + SharingManagerConfiguration.sharedInstance.getMacSerialNumber() + self.name!
            return docuDir + str
        }
    }

    // Function for reading data from persistent store
    private func readDatafromfile (task:enumtask) -> [NSDictionary]? {
        switch (task) {
        case .schedule:
            if (SharingManagerConfiguration.sharedInstance.isDataDirty()) {
                self.readdisk = true
                SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: false)
            } else {
                self.readdisk = false
            }
        case .configuration:
            if (SharingManagerConfiguration.sharedInstance.isDataDirty()) {
                self.readdisk = true
                SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: false)
            } else {
                self.readdisk = false
            }
        case .config:
            self.readdisk = true
        case .none:
            self.readdisk = false
        case .rsyncarguments:
            if (SharingManagerConfiguration.sharedInstance.isDataDirty()) {
                self.readdisk = true
                SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: false)
            } else {
                self.readdisk = false
            }
        }
        if (self.readdisk == true) {
            var itemsList = Array<NSDictionary>()
            let dict = NSDictionary(contentsOfFile: self.fileName!)
            let dictitems : Any? = dict?.object(forKey: self.key!)
            if let arrayitems = dictitems as? NSArray {
                for i in 0 ..< arrayitems.count {
                    if let item = arrayitems[i] as? NSDictionary {
                        _ = item.object(forKey: "ItemCode") as? String
                        itemsList.append(item)
                    }
                }
            }
            // Returning Dictionary read from disk
            return itemsList
        } else {
            // Returning nil all already in memory
            return nil
        }
    }

    // Function for write data to persistent store
    func writeDatatofile (_ array: NSMutableArray, task:enumtask) -> Bool {
        switch (task) {
        case .schedule:
            SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        case .configuration:
            SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        default:
            SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: false)
        }
        self.setPreferences(task)
        let favoritesDictionary = NSDictionary(object: array, forKey: self.key! as NSCopying)
        let succeeded = favoritesDictionary.write(toFile: self.fileName!, atomically: true)
        return succeeded
    }
    
    // Func that creates directory if not created
    private func createDirectory (_ path:String) {
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: path)) {
            // Nothing, directory exist
        } else {
            do { try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)}
            catch _ as NSError { }
        }
    }
    
    // Set preferences for which data to read or write
    private func setPreferences (_ task:enumtask) {
        switch (task) {
        case .schedule:
            self.key = "Schedule"
            if (SharingManagerConfiguration.sharedInstance.testRun == true) {
                self.name = "/scheduleRsynctest.plist"
            } else {
                self.name = "/scheduleRsync.plist"
            }
        case .configuration:
            self.key = "Catalogs"
            if (SharingManagerConfiguration.sharedInstance.testRun == true) {
                self.name = "/configRsynctest.plist"
            } else {
                self.name = "/configRsync.plist"
            }
        case .config:
            self.key = "config"
            self.name = "/config.plist"
        case .rsyncarguments:
            self.key = "rsyncarguments"
            self.name = "/rsyncarguments.plist"
         case .none:
            self.name = nil
            self.readdisk = false
        }
        
    }
    
    init (whattoread:enumtask) {
        self.setPreferences(whattoread)
        self.datafromStore = self.readDatafromfile(task: whattoread)
    }

}
