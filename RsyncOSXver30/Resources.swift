//
//  Resources.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/12/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

enum resourceType {
    case changelog
    case documents
    case urlPlist
}

struct Resources {
    
    private var changelog:String = "https://github.com/rsyncOSX/Documentation/blob/master/docs/Changelog.md"
    private var documents: String = "https://github.com/rsyncOSX/Documentation"
    private var urlPlist: String = "https://dl.dropboxusercontent.com/u/52503631/versionRsyncOSX.plist?raw=1"
    
    func getResource (resource: resourceType) -> String {
        switch resource {
        case .changelog:
            return self.changelog
        case .documents:
            return self.documents
        case .urlPlist:
            return self.urlPlist
        }
    
    }
    
}
