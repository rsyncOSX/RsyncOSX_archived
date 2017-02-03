//
//  userconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Reading userconfiguration from file into RsyncOSX
final class userconfiguration {
    
    weak var rsyncchanged_delegate:RsyncChanged?
    
    private func readUserconfiguration(dict : NSDictionary) {
        // Another version of rsync
        if let version3rsync = dict.value(forKey: "version3Rsync") as? Int {
            if version3rsync == 1 {
                SharingManagerConfiguration.sharedInstance.rsyncVer3 = true
            } else {
                SharingManagerConfiguration.sharedInstance.rsyncVer3 = false
            }
        }
        // Detailed logging
        if let detailedlogging = dict.value(forKey: "detailedlogging") as? Int {
            if detailedlogging == 1 {
                SharingManagerConfiguration.sharedInstance.detailedlogging = true
            } else {
                SharingManagerConfiguration.sharedInstance.detailedlogging = false
            }
        }
        // Optional path for rsync
        if let rsyncPath = dict.value(forKey: "rsyncPath") as? String {
            SharingManagerConfiguration.sharedInstance.rsyncPath = rsyncPath
        }
        // Disable Excute/taskbutton before scheduled task is commencing
        if let minutes = dict.value(forKey: "scheduledTaskdisableExecute") as? Double {
            SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute = minutes
        }
        // Allow double click to execute single tasks
        if let allowDoubleclick = dict.value(forKey: "allowDoubleclick") as? Int {
            if allowDoubleclick == 1 {
                SharingManagerConfiguration.sharedInstance.allowDoubleclick = true
            } else {
                SharingManagerConfiguration.sharedInstance.allowDoubleclick = false
            }
        }
        // Allow rsync errors to reset work Queueu
        if let errors = dict.value(forKey: "rsyncerror") as? Int {
            if errors == 1 {
                SharingManagerConfiguration.sharedInstance.rsyncerror = true
            } else {
                SharingManagerConfiguration.sharedInstance.rsyncerror = false
            }
            
        }
    }
    
    init (configRsyncOSX : [NSDictionary]?) {
        
        // Setting configurations read from config file
        if let userconfiguration = configRsyncOSX {
            if (userconfiguration.count > 0) {
                self.readUserconfiguration(dict: userconfiguration[0])
            }
            // If userconfiguration is read from disk update info in main view
            if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                self.rsyncchanged_delegate = pvc
                self.rsyncchanged_delegate?.rsyncchanged()
                self.rsyncchanged_delegate?.displayAllowDoubleclick()
            }
        }
    }
}
