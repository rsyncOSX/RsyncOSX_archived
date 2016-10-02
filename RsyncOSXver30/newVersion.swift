//
//  newVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class newVersion {
    
    private var runningVersion : String?
    private var urlPlist : String?
    private var urlNewVersion : String?
    
    private func setURLnewVersion () {
        GlobalBackgroundQueue.async(execute: { () -> Void in
            if let url = URL(string: self.urlPlist!) {
                do {
                    let contents = NSDictionary (contentsOf: url)
                    if (self.runningVersion != nil) {
                        if let url = contents?.object(forKey: self.runningVersion!) {
                            self.urlNewVersion = url as? String
                            SharingManagerConfiguration.sharedInstance.URLnewVersion = self.urlNewVersion
                        }
                    }
                }
            } 
        })
    }

    
    init () {
        let infoPlist = Bundle.main.infoDictionary
        let version = infoPlist?["CFBundleShortVersionString"]
        if version != nil {
            self.runningVersion = version as? String
        }
        // read data from dropbox
        self.urlPlist = "https://dl.dropboxusercontent.com/u/52503631/versionRsyncOSX.plist?raw=1"
        self.setURLnewVersion()
    }
    
}

