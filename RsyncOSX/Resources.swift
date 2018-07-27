//
//  Resources.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/12/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

// Enumtype type of resource
enum ResourceType {
    case changelog
    case documents
    case urlPlist
    case introduction
}

struct Resources {
    // Resource strings
    private var changelog: String = "https://rsyncosx.github.io/Changelog"
    private var documents: String = "https://rsyncosx.github.io/AboutRsyncOSX"
    private var urlPlist: String = "https://raw.githubusercontent.com/rsyncOSX/RsyncOSX/master/versionRsyncOSX/versionRsyncOSX.plist"
    private var introduction: String = "https://rsyncosx.github.io/Intro"
    // Get the resource.
    func getResource (resource: ResourceType) -> String {
        switch resource {
        case .changelog:
            return self.changelog
        case .documents:
            return self.documents
        case .urlPlist:
            return self.urlPlist
        case .introduction:
            return self.introduction
        }
    }
}
