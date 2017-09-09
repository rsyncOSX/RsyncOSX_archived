//
//  AppDelegate.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 18/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        var storage: PersistentStorageAPI?
        // Insert code here to initialize your application
        // Check for new version
        _ = Checkfornewversion(inMain: true)
        // Read user configuration
        storage = PersistentStorageAPI(profile: nil)
        if let userConfiguration =  storage?.getUserconfiguration(readfromstorage: true) {
            _ = Userconfiguration(userconfigRsyncOSX: userConfiguration)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
