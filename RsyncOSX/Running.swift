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
    private var rsyncOSXisrunning: Bool = false
    private var rsyncOSXschedisrunning: Bool = false
    var menuappnoconfig: Bool = true

    var enablemenuappbutton: Bool {
        // Check the flags
        guard ViewControllerReference.shared.pathrsyncosxsched != nil else {
            self.menuappnoconfig = true
            return false
        }
        guard ViewControllerReference.shared.pathrsyncosxsched!.isEmpty == false else {
            self.menuappnoconfig = true
            return false
        }
        self.menuappnoconfig = false
        guard  ViewControllerReference.shared.executescheduledtasksmenuapp == true else { return false }
        if self.rsyncOSXschedisrunning == true {
            return false
        } else {
            return true
        }
    }

    init() {
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
            ViewControllerReference.shared.menuappisrunning = true
        } else {
            self.rsyncOSXschedisrunning = false
            ViewControllerReference.shared.menuappisrunning = false
        }
    }
}
