//
//  PersistentStoreageUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//  
//  swiftlint:disable syntactic_sugar

import Foundation

final class PersistentStorageUserconfiguration: Readwritefiles, SetConfigurations {

    /// Variable holds all configuration data
    private var userconfiguration: Array<NSDictionary>?

    /// Function reads configurations from permanent store
    /// - returns : array of NSDictonarys, return might be nil
    func readUserconfigurationsFromPermanentStore() -> Array<NSDictionary>? {
        return self.userconfiguration
    }

    // Saving user configuration
    func saveUserconfiguration () {
        var version3Rsync: Int?
        var detailedlogging: Int?
        var rsyncPath: String?
        var restorePath: String?

        if ViewControllerReference.shared.rsyncVer3 {
            version3Rsync = 1
        } else {
            version3Rsync = 0
        }
        if ViewControllerReference.shared.detailedlogging {
            detailedlogging = 1
        } else {
            detailedlogging = 0
        }
        if ViewControllerReference.shared.rsyncPath != nil {
            rsyncPath = ViewControllerReference.shared.rsyncPath!
        }
        if ViewControllerReference.shared.restorePath != nil {
            restorePath = ViewControllerReference.shared.restorePath!
        }

        var array = Array<NSDictionary>()
        let dict: NSMutableDictionary = [
            "version3Rsync": version3Rsync! as Int,
            "detailedlogging": detailedlogging! as Int]

        if rsyncPath != nil {
            dict.setObject(rsyncPath!, forKey: "rsyncPath" as NSCopying)
        }
        if restorePath != nil {
            dict.setObject(restorePath!, forKey: "restorePath" as NSCopying)
        }

        switch self.configurations!.operation {
        case .dispatch:
            dict.setObject("dispatch", forKey: "operation" as NSCopying)
        case .timer:
            dict.setObject("timer", forKey: "operation" as NSCopying)
        }
        array.append(dict)
        self.writeToStore(array)
    }

    // Writing configuration to persistent store
    // Configuration is Array<NSDictionary>
    private func writeToStore (_ array: Array<NSDictionary>) {
        // Getting the object just for the write method, no read from persistent store
        _ = self.writeDatatoPersistentStorage(array, task: .userconfig)
    }

    init (readfromstorage: Bool) {
        super.init(task: .userconfig, profile: nil)
        if readfromstorage {
            self.userconfiguration = self.getDatafromfile()
        }
    }
}
