//
//  Info.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

class Info {
    var info: String?
    
    // Execute
    func info(num: Int) {
        switch num {
        case 1:
            self.info = "Select a task...."
        case 2:
            self.info = "Possible error logging..."
        case 3:
            self.info = "No rsync in path..."
        case 4:
            self.info = "⌘A to abort or wait..."
        case 5:
            self.info = "Menu app is running..."
        case 6:
            self.info = "This is a combined task, execute by ⌘R..."
        case 7:
            self.info = "Only valid for backup, snapshot and combined tasks..."
        case 8:
            self.info = "No rclone config found..."
        default:
            self.info = ""
        }
    }

    // Loggdata
     func info2(num: Int) {
        switch num {
        case 1:
            self.info = "Got index from Execute and listing logs for one configuration..."
        default:
            self.info = ""
        }
    }

    // Copy files

    func info3(num: Int) {
        switch num {
        case 1:
            self.info = "No such local catalog for restore or set it in user config..."
        case 2:
            self.info = "Not a remote task, use Finder to copy files..."
        case 3:
            self.info = "Local or remote catalog cannot be empty..."
        case 4:
            self.info = "Seems not to be connected..."
        default:
            self.info = ""
        }
    }
    
    // Schedules
    func info4(num: Int) {
        switch num {
        case 1:
            self.info = "Select a task..."
        case 2:
            self.info = "Scheduled tasks in menu app..."
        case 3:
            self.info = "Got index from Execute..."
        default:
            self.info = ""
        }
    }

    // snapshots
    func info5(num: Int) {
        switch num {
        case 1:
            self.info = "Not a snapshot task..."
        case 2:
            self.info = "Aborting delete operation..."
        case 3:
            self.info = "Delete operation completed..."
        case 4:
            self.info = "Seriously, enter a real number..."
        case 5:
            // let num = String((self.snapshotsloggdata?.snapshotslogs?.count ?? 1 - 1) - 1)
            self.info = "You cannot delete that many, max is " + "num" + "..."
        case 6:
            self.info = "Seems not to be connected..."
        default:
            self.info = ""
        }
    }
    
}
