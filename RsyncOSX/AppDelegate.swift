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
    func applicationDidFinishLaunching(_: Notification) {
        // Read user configuration
        if let userconfiguration = PersistentStorageUserconfiguration().readuserconfiguration() {
            _ = Userconfiguration(userconfigRsyncOSX: userconfiguration)
        } else {
            _ = RsyncVersionString()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
}
