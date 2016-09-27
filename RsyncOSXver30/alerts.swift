//
//  alerts.swift
//  Rsync
//
//  Created by Thomas Evensen on 01/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa

public struct Alerts {
    
    public static func showInfo(_ info: String) {
        let alert = NSAlert()
        alert.messageText = info
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    
    public static func dialogOKCancel(_ question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "OK")
        myPopup.addButton(withTitle: "Cancel")
        let res = myPopup.runModal()
        if res == NSAlertFirstButtonReturn {
            return true
        }
        return false
    }
    
    public static func dialogOK(_ question: String, text: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.informational
        myPopup.addButton(withTitle: "OK")
        _ = myPopup.runModal()
    }
    
}


