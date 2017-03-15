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
    
    @IBOutlet weak var Documents: NSButton!
    @IBOutlet weak var Singeltask: NSButton!
    @IBOutlet weak var Batchtask: NSButton!
    @IBOutlet weak var Configuration: NSButton!
    @IBOutlet weak var Rsyncparameters: NSButton!
    @IBOutlet weak var Changelog: NSButton!
    
    @IBAction func help(_ sender: NSButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
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
            
        }
    }
}
