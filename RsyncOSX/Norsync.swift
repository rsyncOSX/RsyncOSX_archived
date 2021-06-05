//
//  Norsync.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Norsync {
    init() {
        if let path = SharedReference.shared.localrsyncpath {
            let error: String = NSLocalizedString("ERROR: no rsync in", comment: "Error rsync") + " " + path
            Alerts.showInfo(info: error)
        } else {
            let error: String = NSLocalizedString("ERROR: no rsync in /usr/local/bin", comment: "Error rsync")
            Alerts.showInfo(info: error)
        }
    }
}
