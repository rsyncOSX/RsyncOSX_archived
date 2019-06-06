//
//  Verifyrsyncpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.07.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

protocol Setinfoaboutrsync: class {
    func setinfoaboutrsync()
}

enum RsynccommandDisplay {
    case synchronize
    case restore
    case verify
}

struct Displayrsyncpath: SetConfigurations {

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

    // Function returns the correct path for rsync according to configuration set by user or
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
            let error: String = NSLocalizedString("ERROR: no rsync in", comment: "Error rsync") + " " + rsync
            Alerts.showInfo(info: error)
        } else {
            let error: String = NSLocalizedString("ERROR: no rsync in /usr/local/bin", comment: "Error rsync")
            Alerts.showInfo(info: error)
        }
    }

    init() {

    }
}
