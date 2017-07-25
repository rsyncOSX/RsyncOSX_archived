//
//  readwritefiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  let str = "/Rsync/" + serialNumber + profile? + "/scheduleRsync.plist"
//  let str = "/Rsync/" + serialNumber + profile? + "/configRsync.plist"
//  let str = "/Rsync/" + serialNumber + "/config.plist"
//  swiftlint OK - 17 July 2017
//  swiftlint:disable syntactic_sugar line_length

import Foundation

enum WhatToReadWrite {
    case schedule
    case configuration
    case userconfig
    case none
}

class Readwritefiles {

    // Name set for schedule, configuration or config
    private var name: String?
    // key in objectForKey, e.g key for reading what
    private var key: String?
    // Default reading from disk
    // The class either reads data from persistent store or
    // returns nil if data is NOT dirty
    private var readdisk: Bool = true
    // Which profile to read
    private var profile: String?
    // If to use profile, only configurations and schedules to read from profile
    private var useProfile: Bool = false
    // task to do
    private var task: WhatToReadWrite?

    // Set which file to read
    private var fileName: String? {
        let str: String?
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let docuDir = (paths.firstObject as? String)!
        let profilePath = Profiles()
        profilePath.createDirectory()
        if self.useProfile {
            // Use profile
            if let profile = self.profile {
                let profilePath = Profiles()
                profilePath.createDirectory()
                str = "/Rsync/" + Configurations.shared.getMacSerialNumber() + "/" + profile + self.name!
            } else {
                // If profile not set use no profile
                str = "/Rsync/" + Configurations.shared.getMacSerialNumber() + self.name!
            }
        } else {
            // no profile
            str = "/Rsync/" + Configurations.shared.getMacSerialNumber() + self.name!
        }
        return (docuDir + str!)
    }

    // Function for reading data from persistent store
    func getDatafromfile () -> Array<NSDictionary>? {

        guard self.task != nil  else {
            return nil
        }

        switch self.task! {
        case .schedule:
            if Configurations.shared.isDataDirty() {
                self.readdisk = true
                Configurations.shared.setDataDirty(dirty: false)
            } else {
                self.readdisk = false
            }
        case .configuration:
            if Configurations.shared.isDataDirty() {
                self.readdisk = true
                Configurations.shared.setDataDirty(dirty: false)
            } else {
                self.readdisk = false
            }
        case .userconfig:
            self.readdisk = true
        case .none:
            self.readdisk = false
        }
        if self.readdisk == true {
            return self.readDatafromPersistentStorage()
        } else {
            return nil
        }
    }

    // Read data from persistent storage
    private func readDatafromPersistentStorage() -> Array<NSDictionary>? {
        var list = Array<NSDictionary>()
        guard self.fileName != nil && self.key != nil else {
            return nil
        }
        let dictionary = NSDictionary(contentsOfFile: self.fileName!)
        let items : Any? = dictionary?.object(forKey: self.key!)
        // If no items return nil
        guard items != nil else {
            return nil
        }
        if let arrayitems = items as? NSArray {
            for i in 0 ..< arrayitems.count {
                if let item = arrayitems[i] as? NSDictionary {
                    _ = dictionary!.object(forKey: "ItemCode") as? String
                    list.append(item)
                }
            }
        }
        return list
    }

    // Function for write data to persistent store
    func writeDictionarytofile (_ array: Array<NSDictionary>, task: WhatToReadWrite) -> Bool {
        self.setPreferences(task)
        guard self.task != nil  else {
            return false
        }
        switch self.task! {
        case .schedule:
            Configurations.shared.setDataDirty(dirty: true)
        case .configuration:
            Configurations.shared.setDataDirty(dirty: true)
        default:
            // Only set data dirty if either Configuration or Schedules are written to persistent store
            Configurations.shared.setDataDirty(dirty: false)
        }
        let dictionary = NSDictionary(object: array, forKey: self.key! as NSCopying)
        guard self.fileName != nil else {
            return false
        }
        return  dictionary.write(toFile: self.fileName!, atomically: true)
    }

    // Set preferences for which data to read or write
    private func setPreferences (_ task: WhatToReadWrite) {
        self.useProfile = false
        self.task = task
        switch self.task! {
        case .schedule:
            self.name = "/scheduleRsync.plist"
            self.key = "Schedule"
            if let profile = Configurations.shared.getProfile() {
                self.profile = profile
                self.useProfile = true
            }
        case .configuration:
            self.name = "/configRsync.plist"
            self.key = "Catalogs"
            if let profile = Configurations.shared.getProfile() {
                self.profile = profile
                self.useProfile = true
            }
        case .userconfig:
            self.name = "/config.plist"
            self.key = "config"
        case .none:
            self.name = nil
            self.readdisk = false
        }
    }

    init(task: WhatToReadWrite) {
        self.setPreferences(task)
    }

}
