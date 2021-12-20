//
//  Resources.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/12/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import CoreVideo
import Foundation

// Enumtype type of resource
enum ResourceType {
    case changelog
    case documents
    case urlPLIST
    case urlJSON
    case firsttimeuse
}

struct Resources {
    // Resource strings
    private var changelog: String = "https://rsyncosx.netlify.app/post/changelog/"
    private var documents: String = "https://rsyncosx.netlify.app/post/rsyncosxdocs/"
    private var urlPlist: String = "https://raw.githubusercontent.com/rsyncOSX/RsyncOSX/master/versionRsyncOSX/versionRsyncOSX.plist"
    private var urlJSON: String = "https://raw.githubusercontent.com/rsyncOSX/RsyncUI/master/versionRsyncUI/versionRsyncUI.json"
    private var firsttimeuse: String = "https://rsyncosx.netlify.app/post/important/"

    // Get the resource.
    func getResource(resource: ResourceType) -> String {
        switch resource {
        case .changelog:
            return changelog
        case .documents:
            return documents
        case .urlPLIST:
            return urlPlist
        case .urlJSON:
            return urlJSON
        case .firsttimeuse:
            return firsttimeuse
        }
    }
}
