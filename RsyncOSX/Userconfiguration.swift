//
//  userconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

// Reading userconfiguration from file into RsyncOSX
final class Userconfiguration {

    weak var rsyncchangedDelegate: RsyncChanged?

    private func readUserconfiguration(dict: NSDictionary) {
        // Another version of rsync
        if let version3rsync = dict.value(forKey: "version3Rsync") as? Int {
            if version3rsync == 1 {
                Configurations.shared.rsyncVer3 = true
            } else {
                Configurations.shared.rsyncVer3 = false
            }
        }
        // Detailed logging
        if let detailedlogging = dict.value(forKey: "detailedlogging") as? Int {
            if detailedlogging == 1 {
                Configurations.shared.detailedlogging = true
            } else {
                Configurations.shared.detailedlogging = false
            }
        }
        // Optional path for rsync
        if let rsyncPath = dict.value(forKey: "rsyncPath") as? String {
            Configurations.shared.rsyncPath = rsyncPath
        }
        // Temporary path for restores single files or directory
        if let restorePath = dict.value(forKey: "restorePath") as? String {
            Configurations.shared.restorePath = restorePath
        } else {
            Configurations.shared.restorePath = NSHomeDirectory() + "/tmp/"
        }
        // Allow double click to execute single tasks
        if let allowDoubleclick = dict.value(forKey: "allowDoubleclick") as? Int {
            if allowDoubleclick == 1 {
                Configurations.shared.allowDoubleclick = true
            } else {
                Configurations.shared.allowDoubleclick = false
            }
        }
        // Allow rsync errors to reset work Queueu
        if let errors = dict.value(forKey: "rsyncerror") as? Int {
            if errors == 1 {
                Configurations.shared.rsyncerror = true
            } else {
                Configurations.shared.rsyncerror = false
            }
        }
    }

    init (userconfigRsyncOSX: [NSDictionary]) {
        if userconfigRsyncOSX.count > 0 {
            self.readUserconfiguration(dict: userconfigRsyncOSX[0])
        }
        // If userconfiguration is read from disk update info in main view
        if let pvc = Configurations.shared.viewControllertabMain as? ViewControllertabMain {
            self.rsyncchangedDelegate = pvc
            self.rsyncchangedDelegate?.rsyncchanged()
            self.rsyncchangedDelegate?.displayAllowDoubleclick()
        }
        // Check for rsync
        Tools.shared.verifyrsyncpath()
    }
}
