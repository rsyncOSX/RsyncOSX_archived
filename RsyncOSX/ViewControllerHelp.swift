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
    
    @IBAction func help(_ sender: NSButton) {
        if self.Batchtask.state == NSOnState {
            self.showwhat = .batchtask
            self.Batchtask.state = NSOffState
        } else if self.Changelog.state == NSOnState {
            self.showwhat = .changelog
            self.Changelog.state = NSOffState
        } else if self.RsyncStdParameters.state  == NSOnState {
            self.showwhat = .rsyncparameters
            self.RsyncStdParameters.state = NSOffState
        } else if self.Singeltask.state == NSOnState {
            self.showwhat = .singletask
            self.Singeltask.state = NSOffState
        } else if self.Configuration.state == NSOnState {
            self.showwhat = .configuration
            self.Configuration.state = NSOffState
        } else if self.Documents.state == NSOnState {
            self.showwhat = .documents
            self.Documents.state = NSOffState
        } else if self.Add.state == NSOnState {
            self.showwhat = .add
            self.Add.state = NSOffState
        } else if self.Schedule.state == NSOnState {
            self.showwhat = .schedule
            self.Schedule.state = NSOffState
        } else if self.Copyfiles.state == NSOnState {
            self.showwhat = .copyfiles
            self.Copyfiles.state = NSOffState
        } else if self.Logging.state == NSOnState {
            self.showwhat = .logging
            self.Logging.state = NSOffState
        } else if self.DIYNAS.state == NSOnState {
            self.showwhat = .diynas
            self.DIYNAS.state = NSOffState
        } else if self.Idea.state == NSOnState {
            self.showwhat = .idea
            self.Idea.state = NSOffState
        } else if self.passwordless.state == NSOnState {
            self.showwhat = .passwordless
            self.passwordless.state = NSOffState
        } else if self.RsyncStdParameters.state == NSOnState {
            self.showwhat = .rsyncstdparameters
            self.RsyncStdParameters.state = NSOffState
        } else if self.source.state == NSOnState {
            self.showwhat = .source
            self.source.state = NSOffState
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        SharingManagerConfiguration.sharedInstance.HelpObject = self
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        SharingManagerConfiguration.sharedInstance.HelpObject = nil
    }
    
}
