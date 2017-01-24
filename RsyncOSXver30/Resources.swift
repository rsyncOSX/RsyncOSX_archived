//
//  Resources.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/12/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Enumtype type of resource
enum resourceType {
    case changelog
    case documents
    case urlPlist
}

struct Resources {
    
    // Resource strings
    private var changelog:String = "https://github.com/rsyncOSX/Documentation/blob/master/docs/Changelog.md"
    private var documents: String = "https://github.com/rsyncOSX/Documentation"
    private var urlPlist: String = "https://raw.githubusercontent.com/rsyncOSX/Version3.x/master/versionRsyncOSX/versionRsyncOSX.plist"
    
    // Get the resource.
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
