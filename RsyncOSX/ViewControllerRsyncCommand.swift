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
        if let index = self.index() {
            guard index <= (self.configurations?.getConfigurations()?.count ?? 0) else { return }
            if self.synchronizedryrun.state == .on {
                self.rsynccommand.stringValue = Displayrsyncpath(index: index, display: .synchronize).displayrsyncpath ?? ""
            } else if self.restoredryrun.state == .on {
                self.rsynccommand.stringValue = Displayrsyncpath(index: index, display: .restore).displayrsyncpath ?? ""
            } else {
                self.rsynccommand.stringValue = Displayrsyncpath(index: index, display: .verify).displayrsyncpath ?? ""
            }
        } else {
            self.rsynccommand.stringValue = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcrsynccommand, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }
}
