//
//  Readwritefiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  let str = "/Rsync/" + serialNumber + profile? + "/scheduleRsync.plist"
//  let str = "/Rsync/" + serialNumber + profile? + "/configRsync.plist"
//  let str = "/Rsync/" + serialNumber + "/config.plist"
//  swiftlint OK - 17 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation
import Cocoa

enum WhatToReadWrite {
    case schedule
    case configuration
    case userconfig
    case none
}

class Readwritefiles {

    // configurations
    weak var configurationsDelegate: GetConfigurationsObject?
    var configurations: Configurations?
    // configurations

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
    // Path for configuration files
    private var filepath: String?
    // Set which file to read
    private var filename: String?

    private func setnameandpath() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let docuDir = (paths.firstObject as? String)!
        let profilePath = Profiles()
        profilePath.createDirectory()
        if self.useProfile {
            // Use profile
            if let profile = self.profile {
                let profilePath = Profiles()
                profilePath.createDirectory()
                self.filepath = "/Rsync/" + Tools().getMacSerialNumber()! + "/" + profile + "/"
                self.filename = docuDir + "/Rsync/" + Tools().getMacSerialNumber()! + "/" + profile + self.name!
            } else {
                // If profile not set use no profile
                self.filename = docuDir +  "/Rsync/" + Tools().getMacSerialNumber()! + self.name!
            }
        } else {
            // no profile
            self.filename = docuDir + "/Rsync/" + Tools().getMacSerialNumber()! + self.name!
            self.filepath = "/Rsync/" + Tools().getMacSerialNumber()! + "/"
        }
    }

    func getfilenameandpath() -> String? {
        return self.filename
    }

    func getpath() -> String? {
        return self.filepath
    }

    // Function for reading data from persistent store
    func getDatafromfile () -> Array<NSDictionary>? {
        guard self.task != nil  else {
            return nil
        }
        switch self.task! {
        case .schedule:
            if self.configurationsDelegate!.isdatadirty() {
                self.readdisk = true
                self.configurationsDelegate!.setdatadirty(dirty: false)
            } else {
                self.readdisk = false
            }
        case .configuration:
            if self.configurationsDelegate!.isdatadirty() {
                self.readdisk = true
                self.configurationsDelegate!.setdatadirty(dirty: false)
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
        guard self.filename != nil && self.key != nil else {
            return nil
        }
        let dictionary = NSDictionary(contentsOfFile: self.filename!)
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
    func writeDatatoPersistentStorage (_ array: Array<NSDictionary>, task: WhatToReadWrite) -> Bool {
        self.setpreferences(task)
        guard self.task != nil  else {
            return false
        }
        switch self.task! {
        case .schedule:
            self.configurationsDelegate!.setdatadirty(dirty: true)
        case .configuration:
            self.configurationsDelegate!.setdatadirty(dirty: true)
        default:
            // Only set data dirty if either Configuration or Schedules are written to persistent store
            self.configurationsDelegate!.setdatadirty(dirty: false)
        }
        let dictionary = NSDictionary(object: array, forKey: self.key! as NSCopying)
        guard self.filename != nil else {
            return false
        }
        return  dictionary.write(toFile: self.filename!, atomically: true)
    }

    // Set preferences for which data to read or write
    private func setpreferences (_ task: WhatToReadWrite) {
        self.task = task
        switch self.task! {
        case .schedule:
            self.name = "/scheduleRsync.plist"
            self.key = "Schedule"
        case .configuration:
            self.name = "/configRsync.plist"
            self.key = "Catalogs"
        case .userconfig:
            self.name = "/config.plist"
            self.key = "config"
        case .none:
            self.name = nil
            self.readdisk = false
        }
    }

    init(task: WhatToReadWrite, profile: String?) {
        if profile != nil {
            self.profile = profile
            self.useProfile = true
        }
        // configurations
        self.configurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        self.configurations = self.configurationsDelegate?.getconfigurationsobject()
        // configurations
        self.setpreferences(task)
        self.setnameandpath()
    }

}
