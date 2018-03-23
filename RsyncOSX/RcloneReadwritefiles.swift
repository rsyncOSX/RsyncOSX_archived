//
//  Readwritefiles.swift
//  RsyncOSX
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

class RcloneReadwritefiles {

    // Name set for schedule, configuration or config
    private var name: String?
    // key in objectForKey, e.g key for reading what
    private var key: String?
    // Which profile to read
    var profile: String?
    // If to use profile, only configurations and schedules to read from profile
    private var useProfile: Bool = false
    // task to do
    private var task: WhatToReadWrite?
    // Path for configuration files
    private var filepath: String?
    // Set which file to read
    private var filename: String?

    private func setnameandpath() {
        let docupath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let docuDir = docupath.firstObject as? String ?? ""
        let profilePath = Profiles()
        profilePath.createDirectory()
        if self.useProfile {
            // Use profile
            if let profile = self.profile {
                let profilePath = Profiles()
                profilePath.createDirectory()
                self.filepath = RcloneReference.shared.configpath + Tools().getMacSerialNumber()! + "/" + profile + "/"
                self.filename = docuDir + RcloneReference.shared.configpath + Tools().getMacSerialNumber()! + "/" + profile + self.name!
            } else {
                // If profile not set use no profile
                self.filename = docuDir +  RcloneReference.shared.configpath + Tools().getMacSerialNumber()! + self.name!
            }
        } else {
            // no profile
            self.filename = docuDir + RcloneReference.shared.configpath + Tools().getMacSerialNumber()! + self.name!
            self.filepath = RcloneReference.shared.configpath + Tools().getMacSerialNumber()! + "/"
        }
    }

    // Function for reading data from persistent store
    func getDatafromfile () -> [NSDictionary]? {
        var data = [NSDictionary]()
        guard self.filename != nil && self.key != nil else { return nil }
        let dictionary = NSDictionary(contentsOfFile: self.filename!)
        let items: Any? = dictionary?.object(forKey: self.key!)
        guard items != nil else { return nil }
        if let arrayofitems = items as? NSArray {
            for i in 0 ..< arrayofitems.count {
                if let item = arrayofitems[i] as? NSDictionary {
                    data.append(item)
                }
            }
        }
        return data
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
        }
    }

    init(task: WhatToReadWrite, profile: String?) {
        if profile != nil {
            self.profile = profile
            self.useProfile = true
        }
        self.setpreferences(task)
        self.setnameandpath()
    }

}
