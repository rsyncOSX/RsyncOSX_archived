//
//  Help.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable cyclomatic_complexity

import Foundation
import Cocoa

enum Helpdocs {
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
    case rsyncstdparameters
    case diynas
    case idea
    case passwordless
    case source
    case ssh
    case intro
}

final class Help {

    private var changelog: String = "https://rsyncosx.github.io/Documentation/docs/Changelog.html"
    private var documentstart: String = "https://rsyncosx.github.io/Documentation/"
    private var singletask: String = "https://rsyncosx.github.io/Documentation/docs/SingleTask.html"
    private var batchtask: String = "https://rsyncosx.github.io/Documentation/docs/BatchTask.html"
    private var rsyncparameters: String = "https://rsyncosx.github.io/Documentation/docs/RsyncParameters.html"
    private var rsyncstdparameters: String = "https://rsyncosx.github.io/Documentation/docs/Parameters.html"
    private var configuration: String = "https://rsyncosx.github.io/Documentation/docs/UserConfiguration.html"
    private var add: String = "https://rsyncosx.github.io/Documentation/docs/AddConfigurations.html"
    private var schedule: String = "https://rsyncosx.github.io/Documentation/docs/ScheduleTasks.html"
    private var copyfiles: String = "https://rsyncosx.github.io/Documentation/docs/CopySingleFiles.html"
    private var logging: String = "https://rsyncosx.github.io/Documentation/docs/Logging.html"
    private var diynas: String = "https://rsyncosx.github.io/Documentation/docs/DIYNAS.html"
    private var idea: String = "https://rsyncosx.github.io/Documentation/docs/Idea.html"
    private var passwordless: String = "https://rsyncosx.github.io/Documentation/docs/PasswordlessLogin.html"
    private var source: String = "https://github.com/rsyncOSX/RsyncOSX"
    private var ssh: String = "https://rsyncosx.github.io/Documentation/docs/ssh.html"
    private var intro: String = "https://rsyncosx.github.io/Documentation/docs/Intro.html"

    private var htmltoshow: String?

    private func show() {
        if let resource = self.htmltoshow {
            NSWorkspace.shared.open(URL(string: resource)!)
        }
    }

    func help(what: Helpdocs) {
        switch what {
        case .changelog:
            self.htmltoshow = self.changelog
        case .documents:
            self.htmltoshow = self.documentstart
        case .singletask:
            self.htmltoshow = self.singletask
        case .batchtask:
            self.htmltoshow = self.batchtask
        case .rsyncparameters:
            self.htmltoshow = self.rsyncparameters
        case .configuration:
            self.htmltoshow = self.configuration
        case .add:
            self.htmltoshow = self.add
        case .schedule:
            self.htmltoshow = self.schedule
        case .copyfiles:
            self.htmltoshow = self.copyfiles
        case .logging:
            self.htmltoshow = self.logging
        case .rsyncstdparameters:
            self.htmltoshow = self.rsyncstdparameters
        case .diynas:
            self.htmltoshow = self.diynas
        case .idea:
            self.htmltoshow = self.idea
        case .passwordless:
            self.htmltoshow = self.passwordless
        case .source:
            self.htmltoshow = self.source
        case .ssh:
            self.htmltoshow = self.ssh
        case .intro:
            self.htmltoshow = self.intro
        }
        self.show()
    }

}
