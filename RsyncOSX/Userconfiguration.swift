//
//  userconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity function_body_length

import Foundation

// Reading userconfiguration from file into RsyncOSX
final class Userconfiguration {

    weak var rsyncchangedDelegate: RsyncIsChanged?

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
            if restorePath.count > 0 {
                ViewControllerReference.shared.restorePath = restorePath
            } else {
                ViewControllerReference.shared.restorePath = nil
            }
        }
        if let executeinmenuapp = dict.value(forKey: "executeinmenuapp") as? Int {
            if executeinmenuapp == 1 {
                ViewControllerReference.shared.executescheduledtasksmenuapp = true
            } else {
                ViewControllerReference.shared.executescheduledtasksmenuapp = false
            }
        }
        // Mark tasks
        if let marknumberofdayssince = dict.value(forKey: "marknumberofdayssince") as? String {
            if Double(marknumberofdayssince)! > 0 {
                let oldmarknumberofdayssince = ViewControllerReference.shared.marknumberofdayssince
                ViewControllerReference.shared.marknumberofdayssince = Double(marknumberofdayssince)!
                if oldmarknumberofdayssince != ViewControllerReference.shared.marknumberofdayssince {
                    weak var reloadconfigurationsDelegate: Createandreloadconfigurations?
                    reloadconfigurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
                    reloadconfigurationsDelegate?.createandreloadconfigurations()
                }
            }
        }
        // Paths rsyncOSX and RsyncOSXsched
        if let pathrsyncosx = dict.value(forKey: "pathrsyncosx") as? String {
            ViewControllerReference.shared.pathrsyncosx = pathrsyncosx
        }
        if let pathrsyncosxsched = dict.value(forKey: "pathrsyncosxsched") as? String {
            ViewControllerReference.shared.pathrsyncosxsched = pathrsyncosxsched
        }
        // No logging, minimum logging or full logging
        if let minimumlogging = dict.value(forKey: "minimumlogging") as? Int {
            if minimumlogging == 1 {
                ViewControllerReference.shared.minimumlogging = true
            } else {
                ViewControllerReference.shared.minimumlogging = false
            }
        }
        if let fulllogging = dict.value(forKey: "fulllogging") as? Int {
            if fulllogging == 1 {
                ViewControllerReference.shared.fulllogging = true
            } else {
                ViewControllerReference.shared.fulllogging = false
            }
        }
        // Day of week snapshots
        if let dayofweeksnaphot = dict.value(forKey: "dayofweeksnaphot") as? String {
            switch dayofweeksnaphot {
            case StringDayofweek.Monday.rawValue:
                ViewControllerReference.shared.dayofweeksnapshots = .Monday
            case StringDayofweek.Tuesday.rawValue:
                ViewControllerReference.shared.dayofweeksnapshots = .Tuesday
            case StringDayofweek.Wednesday.rawValue:
                ViewControllerReference.shared.dayofweeksnapshots = .Wednesday
            case StringDayofweek.Thursday.rawValue:
                ViewControllerReference.shared.dayofweeksnapshots = .Thursday
            case StringDayofweek.Friday.rawValue:
                ViewControllerReference.shared.dayofweeksnapshots = .Friday
            case StringDayofweek.Saturday.rawValue:
                ViewControllerReference.shared.dayofweeksnapshots = .Saturday
            case StringDayofweek.Sunday.rawValue:
                ViewControllerReference.shared.dayofweeksnapshots = .Sunday
            default:
                ViewControllerReference.shared.dayofweeksnapshots = .Sunday
            }
        }
    }

    init (userconfigRsyncOSX: [NSDictionary]) {
        if userconfigRsyncOSX.count > 0 {
            self.readUserconfiguration(dict: userconfigRsyncOSX[0])
        }
        // If userconfiguration is read from disk update info in main view
        self.rsyncchangedDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.rsyncchangedDelegate?.rsyncischanged()
        // Check for rsync and set rsync version string in main view
        Verifyrsyncpath().verifyrsyncpath()
        _ = RsyncVersionString()
    }
}
