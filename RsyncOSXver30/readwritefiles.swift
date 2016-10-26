//
//  readwritefiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// let str = "/Rsync/" + serialNumber + profile? + "/scheduleRsync.plist"
// let str = "/Rsync/" + serialNumber + profile? + "/configRsync.plist"
// let str = "/Rsync/" + serialNumber + "/config.plist"


import Foundation

enum readwrite {
    case schedule
    case configuration
    case userconfig
    case rsyncarguments
    case none
}

class readwritefiles {
    
    // Name set for schedule, configuration or config
    private var name:String?
    // key in objectForKey, e.g key for reading what
    private var key:String?
    // Default reading from disk
    // The class either reads data from persistent store or
    // returns nil if data is NOT dirty
    private var readdisk:Bool = true
    // Which profile to read
    private var profile:String?
    // If to use profile, only configurations and schedules to read from profile
    private var useProfile:Bool = false
    
    // Set which file to read
    private var fileName : String? {
        get {
            let str:String?
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let docuDir = paths.firstObject as! String
            let profilePath = profiles(path: docuDir + "/Rsync/" + SharingManagerConfiguration.sharedInstance.getMacSerialNumber())
            profilePath.createDirectory()
            if (self.useProfile) {
                // Use profile
                if let profile = self.profile {
                    let profilePath = profiles(path: (docuDir + "/Rsync/" + SharingManagerConfiguration.sharedInstance.getMacSerialNumber()) + "/" + profile)
                    profilePath.createDirectory()
                    str = "/Rsync/" + SharingManagerConfiguration.sharedInstance.getMacSerialNumber() + "/" + profile + self.name!
                } else {
                    // If profile not set use no profile
                    str = "/Rsync/" + SharingManagerConfiguration.sharedInstance.getMacSerialNumber() + self.name!
                }
            } else {
                // no profile
                str = "/Rsync/" + SharingManagerConfiguration.sharedInstance.getMacSerialNumber() + self.name!
            }
            return (docuDir + str!)
        }
    }
    
    // Function for reading data from persistent store
    func getDatafromfile (task:readwrite) -> [NSDictionary]? {
        
        self.setPreferences(task)
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
        case .userconfig:
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
            
            var list = Array<NSDictionary>()
            
            guard (self.fileName != nil && self.key != nil) else {
                return nil
            }
            
            let dictionary = NSDictionary(contentsOfFile: self.fileName!)
            let items : Any? = dictionary?.object(forKey: self.key!)
            if let arrayitems = items as? NSArray {
                for i in 0 ..< arrayitems.count {
                    if let item = arrayitems[i] as? NSDictionary {
                        _ = dictionary!.object(forKey: "ItemCode") as? String
                        list.append(item)
                    }
                }
            }
            return list
        } else {
            return nil
        }
    }
    
    // Function for write data to persistent store
    func writeDictionarytofile (_ array: Array<NSDictionary>, task:readwrite) -> Bool {

        self.setPreferences(task)
        switch (task) {
        case .schedule:
            SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        case .configuration:
            SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        default:
            SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: false)
        }
        self.setPreferences(task)
        let dictionary = NSDictionary(object: array, forKey: self.key! as NSCopying)
        guard (self.fileName != nil) else {
            return false
        }
            return  dictionary.write(toFile: self.fileName!, atomically: true)
    }
    
    
    // Set preferences for which data to read or write
    private func setPreferences (_ what:readwrite) {
        self.useProfile = false
        switch (what) {
        case .schedule:
            self.name = "/scheduleRsync.plist"
            self.key = "Schedule"
            if let profile = SharingManagerConfiguration.sharedInstance.getProfile() {
                self.profile = profile
                self.useProfile = true
            }
        case .configuration:
            self.name = "/configRsync.plist"
            self.key = "Catalogs"
            if let profile = SharingManagerConfiguration.sharedInstance.getProfile() {
                self.profile = profile
                self.useProfile = true
            }
        case .userconfig:
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
    
}
