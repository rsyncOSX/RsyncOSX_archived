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
    case add
    case schedule
    case copyfiles
    case logging
}

final class Help {
    
    private var changelog: String = "https://rsyncosx.github.io/Documentation/docs/Changelog.html"
    private var documentstart: String = "https://rsyncosx.github.io/Documentation/"
    private var singletask: String = "https://rsyncosx.github.io/Documentation/docs/SingleTask.html"
    private var batchtask: String = "https://rsyncosx.github.io/Documentation/docs/BatchTask.html"
    private var rsyncparameters: String = "https://rsyncosx.github.io/Documentation/docs/Parameters.html"
    private var configuration: String = "https://rsyncosx.github.io/Documentation/docs/UserConfiguration.html"
    private var add: String = "https://rsyncosx.github.io/Documentation/docs/AddConfigurations.html"
    private var schedule: String = "https://rsyncosx.github.io/Documentation/docs/ScheduleTasks.html"
    private var copyfiles:String = "https://rsyncosx.github.io/Documentation/docs/CopySingleFiles.html"
    private var logging: String = "https://rsyncosx.github.io/Documentation/docs/Logging.html"
    
    
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
        case .add:
            self.resource = self.add
        case .schedule:
            self.resource = self.schedule
        case .copyfiles:
            self.resource = self.copyfiles
        case .logging:
            self.resource = self.logging
            
        }
        self.show()
    }
    
    
}
