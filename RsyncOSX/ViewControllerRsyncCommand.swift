//
//  ViewControllerRsyncCommand.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 30/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerRsyncCommand: NSViewController, SetConfigurations, Index {
    @IBOutlet var rsynccommand: NSTextField!
    @IBOutlet var synchronizedryrun: NSButton!
    @IBOutlet var restoredryrun: NSButton!
    @IBOutlet var verifydryrun: NSButton!

    @IBAction func showrsynccommand(_: NSButton) {
        if let index = self.index(),
           let config = configurations?.getConfigurations()?[index]
        {
            if synchronizedryrun.state == .on {
                rsynccommand.stringValue = RsyncCommandtoDisplay(.synchronize, config).getrsyncommand() ?? ""
            } else if restoredryrun.state == .on {
                rsynccommand.stringValue = RsyncCommandtoDisplay(.restore, config).getrsyncommand() ?? ""
            } else {
                rsynccommand.stringValue = RsyncCommandtoDisplay(.verify, config).getrsyncommand() ?? ""
            }
        } else {
            rsynccommand.stringValue = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SharedReference.shared.setvcref(viewcontroller: .vcrsynccommand, nsviewcontroller: self)
        if let index = self.index(),
           let config = configurations?.getConfigurations()?[index]
        {
            rsynccommand.stringValue = RsyncCommandtoDisplay(.synchronize, config).getrsyncommand() ?? ""
        }
    }
}
