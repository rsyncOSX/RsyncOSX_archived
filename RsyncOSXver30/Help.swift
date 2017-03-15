//
//  Help.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

enum helpdocs {
    case changelog
    case documents
    case singletask
    case batchtask
    case rsyncparameters
    case configuration
}

final class Help {
    
    private var changelog: String = "https://rsyncosx.github.io/Documentation/docs/Changelog.html"
    private var documentstart: String = "https://rsyncosx.github.io/Documentation/"
    private var singletask: String = "https://rsyncosx.github.io/Documentation/docs/SingleTask.html"
    private var batchtask: String = "https://rsyncosx.github.io/Documentation/docs/BatchTask.html"
    private var rsyncparameters: String = "https://rsyncosx.github.io/Documentation/docs/Parameters.html"
    private var configuration: String = "https://rsyncosx.github.io/Documentation/docs/UserConfiguration.html"
    
    
    private var resource:String?
    
    
    private func show() {
        if let resource = self.resource {
            NSWorkspace.shared().open(URL(string: resource)!)
        }
    }
    
    func help(what:helpdocs) {
        switch what {
        case .changelog:
            self.resource = self.changelog
        case .documents:
            self.resource = self.documentstart
        case .singletask:
            self.resource = self.singletask
        case .batchtask:
            self.resource = self.batchtask
        case .rsyncparameters:
            self.resource = self.rsyncparameters
        case .configuration:
            self.resource = self.configuration
            
        }
        self.show()
    }
    
    
}
