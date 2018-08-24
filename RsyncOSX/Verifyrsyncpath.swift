//
//  Verifyrsyncpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.07.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

var globalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

var globalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: .background)
}
var globalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInitiated)
}
var globalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: .utility)
}
var globalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInteractive)
}
var globalDefaultQueue: DispatchQueue {
    return DispatchQueue.global(qos: .default)
}

protocol Setinfoaboutrsync: class {
    func setinfoaboutrsync()
}

enum RsynccommandDisplay {
    case synchronize
    case restore
    case verify
}

final class Verifyrsyncpath: SetConfigurations {

    weak var setinfoaboutsyncDelegate: Setinfoaboutrsync?

    // Function to verify full rsyncpath
    func verifyrsyncpath() {
        let fileManager = FileManager.default
        let path: String?
        // If not in /usr/bin or /usr/local/bin
        // rsyncPath is set if none of the above
        if let rsyncPath = ViewControllerReference.shared.rsyncPath {
            path = rsyncPath + ViewControllerReference.shared.rsync
        } else if ViewControllerReference.shared.rsyncVer3 {
            path = "/usr/local/bin/" + ViewControllerReference.shared.rsync
        } else {
            path = "/usr/bin/" + ViewControllerReference.shared.rsync
        }
        guard ViewControllerReference.shared.rsyncVer3 == true else {
            ViewControllerReference.shared.norsync = false
            self.setinfoaboutsyncDelegate?.setinfoaboutrsync()
            return
        }
        if fileManager.fileExists(atPath: path!) == false {
            ViewControllerReference.shared.norsync = true
        } else {
            ViewControllerReference.shared.norsync = false
        }
        self.setinfoaboutsyncDelegate?.setinfoaboutrsync()
    }

    func displayrsynccommand(index: Int, display: RsynccommandDisplay) -> String {
        var str: String?
        let config = self.configurations!.getargumentAllConfigurations()[index]
        str = self.rsyncpath() + " "
        switch display {
        case .synchronize:
            if let count = config.argdryRunDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.argdryRunDisplay![i]
                }
            }
        case .restore:
            if let count = config.restoredryRunDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.restoredryRunDisplay![i]
                }
            }
        case .verify:
            if let count = config.verifyDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.verifyDisplay![i]
                }
            }
        }
        return str ?? ""
    }

    /// Function returns the correct path for rsync
    /// according to configuration set by user or
    /// default value.
    /// - returns : full path of rsync command
    func rsyncpath() -> String {
        if ViewControllerReference.shared.rsyncVer3 {
            if ViewControllerReference.shared.rsyncPath == nil {
                return ViewControllerReference.shared.usrlocalbinrsync
            } else {
                return ViewControllerReference.shared.rsyncPath! + ViewControllerReference.shared.rsync
            }
        } else {
            return ViewControllerReference.shared.usrbinrsync
        }
    }

    func noRsync() {
        if let rsync = ViewControllerReference.shared.rsyncPath {
            Alerts.showInfo("ERROR: no rsync in " + rsync)
        } else {
            Alerts.showInfo("ERROR: no rsync in /usr/local/bin")
        }
    }

    init() {
        self.setinfoaboutsyncDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}
