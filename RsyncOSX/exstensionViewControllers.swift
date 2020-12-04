//
//  exstensionViewControllers.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

extension ViewControllerSideBar {
    @IBAction func allprofiles(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerNewConfigurations {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerSchedule {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerSnapshots {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }

    // Toolbar -  abort Snapshots
    @IBAction func abort(_: NSButton) {
        self.info.stringValue = Infosnapshots().info(num: 2)
        self.snapshotlogsandcatalogs?.snapshotcatalogstodelete = nil
    }
}

extension ViewControllerRestore {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerLoggData {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerSsh {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }
}
