//
//  ViewControllerMove.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/09/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerMove: NSViewController {
    // Buttons for moving config files
    @IBOutlet var togglemovebutton: NSButton!
    @IBOutlet var preparebutton: NSButton!
    @IBOutlet var moveconfigfilesbutton: NSButton!

    var move: Copyconfigfilestonewhome?

    // Move configfiles start
    @IBAction func togglemove(_: NSButton) {
        guard self.move == nil else { return }
        self.move = Copyconfigfilestonewhome()
        // Verify that configfiles are not previously moved
        if let newcatalogs = self.move?.newprofilecatalogs,
            let oldcatalogs = self.move?.oldprofilecatalogs
        {
            if newcatalogs != oldcatalogs {
                self.preparebutton.isEnabled = true
                self.moveconfigfilesbutton.isHidden = false
            }
        } else {
            self.preparebutton.isEnabled = true
            self.moveconfigfilesbutton.isHidden = false
        }
    }

    @IBAction func preparemoveconfigfiles(_: NSButton) {
        self.move?.createnewprofilecatalogs()
        if self.move?.verifycatalogsnewprofiles() ?? false {
            self.moveconfigfilesbutton.isEnabled = true
        }
    }

    @IBAction func executemoveconfigfiles(_: NSButton) {
        self.view.window?.close()
        NSApp.terminate(self)
    }

    // Move configfiles end

    override func viewDidLoad() {
        super.viewDidLoad()
        // Move configfiles
        self.preparebutton.isEnabled = false
        self.moveconfigfilesbutton.isEnabled = false
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }
}
