//
//  userconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class userconfiguration {
    
    // Default values
    // Use version 3 og rsync
    var version3rsync:Bool = false
    // optional path rsync
    var rsyncPath:String?
    // Use RsyncOSX in testmodus or not
    var testRun:Bool = false
    // Detailed logging
    var detailedlogging:Bool = true
    // Disable Execute/Batch button
    var scheduledTaskdisableExecute:Double?
    
    init (configRsyncOSX : [NSDictionary]?) {
        
        // Setting any configurations read from config file
        
        if let userconfiguration = configRsyncOSX {
            // Read config dictionary as NSDictonary
            if (userconfiguration.count > 0) {
                
                let dict : NSDictionary = userconfiguration[0]
                
                // Another version of rsync
                if let version3rsync = dict.value(forKey: "version3Rsync") as? Int {
                    if version3rsync == 1 {
                        SharingManagerConfiguration.sharedInstance.rsyncVer3 = true
                        config.sharedInstance.version3rsync = 1
                    } else {
                        SharingManagerConfiguration.sharedInstance.rsyncVer3 = false
                        config.sharedInstance.version3rsync = 0
                    }
                }
                // Detailed logging
                if let detailedlogging = dict.value(forKey: "detailedlogging") as? Int {
                    if detailedlogging == 1 {
                        SharingManagerConfiguration.sharedInstance.detailedlogging = true
                        config.sharedInstance.detailedlogging = 1
                    } else {
                        SharingManagerConfiguration.sharedInstance.detailedlogging = false
                        config.sharedInstance.detailedlogging = 0
                    }
                }
                
                // Optional path for rsync
                if let rsyncPath = dict.value(forKey: "rsyncPath") as? String {
                    SharingManagerConfiguration.sharedInstance.rsyncPath = rsyncPath
                    config.sharedInstance.rsyncPath = rsyncPath
                }
                
                // Disable Excute/taskbutton before scheduled task is commencing
                if let minutes = dict.value(forKey: "scheduledTaskdisableExecute") as? Double {
                    SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute = minutes
                    config.sharedInstance.scheduledTaskdisableExecute = minutes
                }

                
            }
            
        } else {
            // If no config file default settings
            // Default value of version3rsync == false
            self.version3rsync = SharingManagerConfiguration.sharedInstance.rsyncVer3
            self.detailedlogging = SharingManagerConfiguration.sharedInstance.detailedlogging
            self.rsyncPath = nil
            SharingManagerConfiguration.sharedInstance.rsyncPath = nil
            self.scheduledTaskdisableExecute = SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute
        }
        // Default temporary setting
        self.testRun = SharingManagerConfiguration.sharedInstance.testRun
    }
}
