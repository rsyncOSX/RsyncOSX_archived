//
//  path.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa

class WindowManager {
    
    var path:String?
    
    internal static var screen: NSScreen! = NSScreen.main()
    internal static var activationToken: dispatch_once_t = 0
    internal static func buildWindow() -> NSWindow {
        dispatch_once(&WindowManager.activationToken) {
            NSApplication.sharedApplication().setActivationPolicy(.Regular) // show icon in dock
        }
        let frame = WindowManager.screen.frame
        let center = CGPointMake(frame.midX, frame.midY)
        let window = NSWindow()
        window.setFrameOrigin(center)
        window.level = 7
        window.styleMask = NSBorderlessWindowMask
        window.makeKeyAndOrderFront(nil)
        window.alphaValue = 0.0
        return window
    }
    
    func selectCatalog () {
        let myFiledialog = NSOpenPanel()
        myFiledialog.prompt = "Select folder"
        myFiledialog.worksWhenModal = true
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = true
        myFiledialog.canChooseFiles = false
        myFiledialog.resolvesAliases = true
        myFiledialog.beginSheetModal(for: WindowManager.buildWindow()) {
            (response) -> Void in
            if (myFiledialog.url != nil) {
                self.path = String(myFiledialog.url!.path)
            }
        }

    }

}
