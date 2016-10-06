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
            }
        }
    }
}
