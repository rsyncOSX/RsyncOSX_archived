//
//  ViewControllerHelp.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 15.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable cyclomatic_complexity function_body_length

import Foundation
import Cocoa

class ViewControllerHelp: NSViewController {

    private var showwhat: Helpdocs?

    @IBOutlet weak var documents: NSButton!
    @IBOutlet weak var singletask: NSButton!
    @IBOutlet weak var batchtask: NSButton!
    @IBOutlet weak var configuration: NSButton!
    @IBOutlet weak var rsyncStdParameters: NSButton!
    @IBOutlet weak var changelog: NSButton!
    @IBOutlet weak var add: NSButton!
    @IBOutlet weak var schedule: NSButton!
    @IBOutlet weak var copyfiles: NSButton!
    @IBOutlet weak var logging: NSButton!
    @IBOutlet weak var diynas: NSButton!
    @IBOutlet weak var idea: NSButton!
    @IBOutlet weak var passwordless: NSButton!
    @IBOutlet weak var rsyncParameters: NSButton!
    @IBOutlet weak var source: NSButton!
    @IBOutlet weak var ssh: NSButton!
    @IBOutlet weak var intro: NSButton!

    @IBAction func help(_ sender: NSButton) {
        if self.batchtask.state == .on {
            self.showwhat = .batchtask
            self.batchtask.state = .off
        } else if self.changelog.state == .on {
            self.showwhat = .changelog
            self.changelog.state = .off
        } else if self.rsyncStdParameters.state  == .on {
            self.showwhat = .rsyncparameters
            self.rsyncStdParameters.state = .off
        } else if self.singletask.state == .on {
            self.showwhat = .singletask
            self.singletask.state = .off
        } else if self.configuration.state == .on {
            self.showwhat = .configuration
            self.configuration.state = .off
        } else if self.documents.state == .on {
            self.showwhat = .documents
            self.documents.state = .off
        } else if self.add.state == .on {
            self.showwhat = .add
            self.add.state = .off
        } else if self.schedule.state == .on {
            self.showwhat = .schedule
            self.schedule.state = .off
        } else if self.copyfiles.state == .on {
            self.showwhat = .copyfiles
            self.copyfiles.state = .off
        } else if self.logging.state == .on {
            self.showwhat = .logging
            self.logging.state = .off
        } else if self.diynas.state == .on {
            self.showwhat = .diynas
            self.diynas.state = .off
        } else if self.idea.state == .on {
            self.showwhat = .idea
            self.idea.state = .off
        } else if self.passwordless.state == .on {
            self.showwhat = .passwordless
            self.passwordless.state = .off
        } else if self.rsyncStdParameters.state == .on {
            self.showwhat = .rsyncstdparameters
            self.rsyncStdParameters.state = .off
        } else if self.source.state == .on {
            self.showwhat = .source
            self.source.state = .off
        } else if self.ssh.state == .on {
            self.showwhat = .ssh
            self.ssh.state = .off
        } else if self.intro.state == .on {
            self.showwhat = .intro
            self.intro.state = .off
        }
        self.show()
    }

    private func show() {
        let help = Help()
        guard self.showwhat != nil else {
            return
        }
        help.help(what: self.showwhat!)
    }

}
