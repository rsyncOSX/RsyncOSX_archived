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
