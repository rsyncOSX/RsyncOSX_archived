//
//  ViewControllerHelp.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 15.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerHelp: NSViewController {
    
    fileprivate var showwhat:helpdocs?
    
    @IBOutlet weak var Documents: NSButton!
    @IBOutlet weak var Singeltask: NSButton!
    @IBOutlet weak var Batchtask: NSButton!
    @IBOutlet weak var Configuration: NSButton!
    @IBOutlet weak var RsyncStdParameters: NSButton!
    @IBOutlet weak var Changelog: NSButton!
    @IBOutlet weak var Add: NSButton!
    @IBOutlet weak var Schedule: NSButton!
    @IBOutlet weak var Copyfiles: NSButton!
    @IBOutlet weak var Logging: NSButton!
    @IBOutlet weak var DIYNAS: NSButton!
    @IBOutlet weak var Idea: NSButton!
    @IBOutlet weak var passwordless: NSButton!
    @IBOutlet weak var RsyncParameters: NSButton!
    @IBOutlet weak var source: NSButton!
    @IBOutlet weak var Ssh: NSButton!
    
    @IBAction func help(_ sender: NSButton) {
        if self.Batchtask.state == .on {
            self.showwhat = .batchtask
            self.Batchtask.state = .off
        } else if self.Changelog.state == .on {
            self.showwhat = .changelog
            self.Changelog.state = .off
        } else if self.RsyncStdParameters.state  == .on {
            self.showwhat = .rsyncparameters
            self.RsyncStdParameters.state = .off
        } else if self.Singeltask.state == .on {
            self.showwhat = .singletask
            self.Singeltask.state = .off
        } else if self.Configuration.state == .on {
            self.showwhat = .configuration
            self.Configuration.state = .off
        } else if self.Documents.state == .on {
            self.showwhat = .documents
            self.Documents.state = .off
        } else if self.Add.state == .on {
            self.showwhat = .add
            self.Add.state = .off
        } else if self.Schedule.state == .on {
            self.showwhat = .schedule
            self.Schedule.state = .off
        } else if self.Copyfiles.state == .on {
            self.showwhat = .copyfiles
            self.Copyfiles.state = .off
        } else if self.Logging.state == .on {
            self.showwhat = .logging
            self.Logging.state = .off
        } else if self.DIYNAS.state == .on {
            self.showwhat = .diynas
            self.DIYNAS.state = .off
        } else if self.Idea.state == .on {
            self.showwhat = .idea
            self.Idea.state = .off
        } else if self.passwordless.state == .on {
            self.showwhat = .passwordless
            self.passwordless.state = .off
        } else if self.RsyncStdParameters.state == .on {
            self.showwhat = .rsyncstdparameters
            self.RsyncStdParameters.state = .off
        } else if self.source.state == .on {
            self.showwhat = .source
            self.source.state = .off
        } else if self.Ssh.state == .on {
            self.showwhat = .ssh
            self.Ssh.state = .off
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
