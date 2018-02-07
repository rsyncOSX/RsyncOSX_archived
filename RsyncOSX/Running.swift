//
//  Running.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 07.02.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation
import AppKit

class Running {

    let rsyncOSX = "no.blogspot.RsyncOSX"
    let rsyncOSXsched = "no.blogspot.RsyncOSXsched"
    var rsyncOSXisrunning: Bool = false
    var rsyncOSXschedisrunning: Bool = false

    func checkforrunningapps() {
        // Get all running applications
        let workspace = NSWorkspace.shared
        let applications = workspace.runningApplications
        let rsyncosx = applications.filter({return ($0.bundleIdentifier == self.rsyncOSX)})
        let rsyncosxschde = applications.filter({return ($0.bundleIdentifier == self.rsyncOSXsched)})
        if rsyncosx.count > 0 {
            self.rsyncOSXisrunning = true
        } else {
            self.rsyncOSXisrunning = false
        }
        if rsyncosxschde.count > 0 {
            self.rsyncOSXschedisrunning = true
        } else {
            self.rsyncOSXschedisrunning = false
        }
    }
    init() {
        self.checkforrunningapps()
    }
}
