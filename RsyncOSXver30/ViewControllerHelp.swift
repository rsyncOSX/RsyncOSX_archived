//
//  ViewControllerHelp.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 15.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

protocol selectHelp: class {
    func SelectHelp(help:helpdocs)
}

class ViewControllerHelp: NSViewController {
    
    fileprivate var showwhat:helpdocs?
    
    @IBOutlet weak var Documents: NSButton!
    @IBOutlet weak var Singeltask: NSButton!
    @IBOutlet weak var Batchtask: NSButton!
    @IBOutlet weak var Configuration: NSButton!
    @IBOutlet weak var Rsyncparameters: NSButton!
    @IBOutlet weak var Changelog: NSButton!
    @IBOutlet weak var Add: NSButton!
    @IBOutlet weak var Schedule: NSButton!
    @IBOutlet weak var Copyfiles: NSButton!
    @IBOutlet weak var Logging: NSButton!
    
    @IBAction func help(_ sender: NSButton) {
        if self.Batchtask.state == NSOnState {
            self.showwhat = .batchtask
        } else if self.Changelog.state == NSOnState {
            self.showwhat = .changelog
        } else if self.Rsyncparameters.state  == NSOnState {
            self.showwhat = .rsyncparameters
        } else if self.Singeltask.state == NSOnState {
            self.showwhat = .singletask
        } else if self.Configuration.state == NSOnState {
            self.showwhat = .configuration
        } else if self.Documents.state == NSOnState {
            self.showwhat = .documents
        } else if self.Add.state == NSOnState {
            self.showwhat = .add
        } else if self.Schedule.state == NSOnState {
            self.showwhat = .schedule
        } else if self.Copyfiles.state == NSOnState {
            self.showwhat = .copyfiles
        } else if self.Logging.state == NSOnState {
            self.showwhat = .logging
        }
    }
    
    @IBAction func Show(_ sender: NSButton) {
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

extension ViewControllerHelp: selectHelp {
    func SelectHelp(help: helpdocs) {
        
        switch (help) {
        case .batchtask:
            self.Batchtask.state = NSOnState
        case .changelog:
            self.Changelog.state = NSOnState
        case .rsyncparameters:
            self.Rsyncparameters.state = NSOnState
        case .singletask:
            self.Singeltask.state = NSOnState
        case .configuration:
            self.Configuration.state = NSOnState
        case .documents:
            self.Documents.state = NSOnState
        case .add:
            self.Add.state = NSOnState
        case .schedule:
            self.Schedule.state = NSOnState
        case .copyfiles:
            self.Copyfiles.state = NSOnState
        case .logging:
            self.Logging.state = NSOnState
        }
        self.showwhat = help
    }
}
