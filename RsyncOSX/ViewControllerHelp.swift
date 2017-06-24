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
        if self.Batchtask.state == NSControl.StateValue.onState {
            self.showwhat = .batchtask
            self.Batchtask.state = NSControl.StateValue.offState
        } else if self.Changelog.state == NSControl.StateValue.onState {
            self.showwhat = .changelog
            self.Changelog.state = NSControl.StateValue.offState
        } else if self.RsyncStdParameters.state  == NSControl.StateValue.onState {
            self.showwhat = .rsyncparameters
            self.RsyncStdParameters.state = NSControl.StateValue.offState
        } else if self.Singeltask.state == NSControl.StateValue.onState {
            self.showwhat = .singletask
            self.Singeltask.state = NSControl.StateValue.offState
        } else if self.Configuration.state == NSControl.StateValue.onState {
            self.showwhat = .configuration
            self.Configuration.state = NSControl.StateValue.offState
        } else if self.Documents.state == NSControl.StateValue.onState {
            self.showwhat = .documents
            self.Documents.state = NSControl.StateValue.offState
        } else if self.Add.state == NSControl.StateValue.onState {
            self.showwhat = .add
            self.Add.state = NSControl.StateValue.offState
        } else if self.Schedule.state == NSControl.StateValue.onState {
            self.showwhat = .schedule
            self.Schedule.state = NSControl.StateValue.offState
        } else if self.Copyfiles.state == NSControl.StateValue.onState {
            self.showwhat = .copyfiles
            self.Copyfiles.state = NSControl.StateValue.offState
        } else if self.Logging.state == NSControl.StateValue.onState {
            self.showwhat = .logging
            self.Logging.state = NSControl.StateValue.offState
        } else if self.DIYNAS.state == NSControl.StateValue.onState {
            self.showwhat = .diynas
            self.DIYNAS.state = NSControl.StateValue.offState
        } else if self.Idea.state == NSControl.StateValue.onState {
            self.showwhat = .idea
            self.Idea.state = NSControl.StateValue.offState
        } else if self.passwordless.state == NSControl.StateValue.onState {
            self.showwhat = .passwordless
            self.passwordless.state = NSControl.StateValue.offState
        } else if self.RsyncStdParameters.state == NSControl.StateValue.onState {
            self.showwhat = .rsyncstdparameters
            self.RsyncStdParameters.state = NSControl.StateValue.offState
        } else if self.source.state == NSControl.StateValue.onState {
            self.showwhat = .source
            self.source.state = NSControl.StateValue.offState
        } else if self.Ssh.state == NSControl.StateValue.onState {
            self.showwhat = .ssh
            self.Ssh.state = NSControl.StateValue.offState
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
