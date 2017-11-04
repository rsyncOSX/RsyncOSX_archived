//
//  userconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

// Reading userconfiguration from file into RsyncOSX
final class Userconfiguration {

    weak var rsyncchangedDelegate: RsyncChanged?

    private func readUserconfiguration(dict: NSDictionary) {
        // Another version of rsync
        if let version3rsync = dict.value(forKey: "version3Rsync") as? Int {
            if version3rsync == 1 {
                ViewControllerReference.shared.rsyncVer3 = true
            } else {
                ViewControllerReference.shared.rsyncVer3 = false
            }
        }
        // Detailed logging
        if let detailedlogging = dict.value(forKey: "detailedlogging") as? Int {
            if detailedlogging == 1 {
                ViewControllerReference.shared.detailedlogging = true
            } else {
                ViewControllerReference.shared.detailedlogging = false
            }
        }
        // Optional path for rsync
        if let rsyncPath = dict.value(forKey: "rsyncPath") as? String {
            ViewControllerReference.shared.rsyncPath = rsyncPath
        }
        // Temporary path for restores single files or directory
        if let restorePath = dict.value(forKey: "restorePath") as? String {
            ViewControllerReference.shared.restorePath = restorePath
        } else {
            ViewControllerReference.shared.restorePath = NSHomeDirectory() + "/tmp/"
        }
        // Operation object
        // Default is dispatch
        if let operation = dict.value(forKey: "operation") as? String {
            switch operation {
            case "dispatch":
                ViewControllerReference.shared.operation = .dispatch
            case "timer":
                ViewControllerReference.shared.operation = .timer
            default:
                ViewControllerReference.shared.operation = .dispatch
            }
        }
    }

    init (userconfigRsyncOSX: [NSDictionary]) {
        if userconfigRsyncOSX.count > 0 {
            self.readUserconfiguration(dict: userconfigRsyncOSX[0])
        }
        // If userconfiguration is read from disk update info in main view
        self.rsyncchangedDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.rsyncchangedDelegate?.rsyncchanged()
        // Check for rsync
        Tools().verifyrsyncpath()
    }
}
