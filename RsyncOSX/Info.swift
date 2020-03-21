//
//  Info.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

struct Infoexecute {
    // Execute
    let info11: String = NSLocalizedString("Select a task....", comment: "Execute")
    let info12: String = NSLocalizedString("Possible error logging...", comment: "Execute")
    let info13: String = NSLocalizedString("No rsync in path...", comment: "Execute")
    let info14: String = NSLocalizedString("⌘A to abort or wait...", comment: "Execute")
    let info15: String = NSLocalizedString("Menu app is running...", comment: "Execute")
    let info16: String = NSLocalizedString("Select one or more tasks...", comment: "Execute")
    let info19: String = NSLocalizedString("New version is available - see About", comment: "Execute")

    // Execute
    func info(num: Int) -> String {
        switch num {
        case 1:
            return self.info11
        case 2:
            return self.info12
        case 3:
            return self.info13
        case 4:
            return self.info14
        case 5:
            return self.info15
        case 6:
            return self.info16
        case 9:
            return self.info19
        default:
            return ""
        }
    }
}

struct Infologgdata {
    // Loggdata
    let info21: String = NSLocalizedString("Got index from Synchronize and listing logs for one configuration...", comment: "Loggdata")
    let info22: String = NSLocalizedString("Got index from Snapshots and listing logs for one configuration...", comment: "Loggdata")

    func info(num: Int) -> String {
        switch num {
        case 1:
            return self.info21
        case 2:
            return self.info22
        default:
            return ""
        }
    }
}

struct Inforestore {
    // Restore
    let info31: String = NSLocalizedString("No such temporay catalog for restore, set it in user config.", comment: "Restore")
    let info32: String = NSLocalizedString("Not a remote task, use Finder to copy files...", comment: "Restore")
    let info33: String = NSLocalizedString("Local or remote catalog cannot be empty...", comment: "Restore")
    let info34: String = NSLocalizedString("Seems not to be connected...", comment: "Copy files")
    let info35: String = NSLocalizedString("Cannot copy from a syncremote task...", comment: "Restore")

    func info(num: Int) -> String {
        switch num {
        case 1:
            return self.info31
        case 2:
            return self.info32
        case 3:
            return self.info33
        case 4:
            return self.info34
        case 5:
            return self.info35
        default:
            return ""
        }
    }
}

struct Infoschedule {
    // Schedules
    let info11: String = NSLocalizedString("Select a task....", comment: "Execute")
    let info42: String = NSLocalizedString("Scheduled tasks in menu app...", comment: "Schedules")
    let info43: String = NSLocalizedString("Got index from Synchronize...", comment: "Schedules")

    func info(num: Int) -> String {
        switch num {
        case 1:
            return self.info11
        case 2:
            return self.info42
        case 3:
            return self.info43
        default:
            return ""
        }
    }
}

struct Infosnapshots {
    // Snapshots
    let info51: String = NSLocalizedString("Not a snapshot task...", comment: "Snapshots")
    let info52: String = NSLocalizedString("Aborting delete operation...", comment: "Snapshots")
    let info53: String = NSLocalizedString("Delete operation completed...", comment: "Snapshots")
    let info54: String = NSLocalizedString("Seriously, enter a real number...", comment: "Snapshots")
    let info55: String = NSLocalizedString("You cannot delete that many, max are", comment: "Snapshots")
    let info34: String = NSLocalizedString("Seems not to be connected...", comment: "Copy files")

    // snapshots
    func info(num: Int) -> String {
        switch num {
        case 1:
            return self.info51
        case 2:
            return self.info52
        case 3:
            return self.info53
        case 4:
            return self.info54
        case 5:
            return self.info55
        case 6:
            return self.info34
        default:
            return ""
        }
    }
}
