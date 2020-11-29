//
//  ViewControllerSideBar.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerSideBar: NSViewController, SetConfigurations {
    @IBOutlet var jsonbutton: NSButton!
    @IBOutlet var jsonlabel: NSTextField!

    @IBAction func delete(_: NSButton) {}

    @IBAction func verifyjson(_: NSButton) {
        self.verify()
    }

    @IBAction func enableconvertjsonbutton(_: NSButton) {
        if ViewControllerReference.shared.convertjsonbutton {
            ViewControllerReference.shared.convertjsonbutton = false
        } else {
            ViewControllerReference.shared.convertjsonbutton = true
        }
        // JSON button
        if ViewControllerReference.shared.json == true {
            self.jsonbutton.title = "PLIST"
        } else {
            self.jsonbutton.title = "JSON"
        }
        self.jsonbutton.isHidden = !ViewControllerReference.shared.convertjsonbutton
    }

    @IBAction func Json(_: NSButton) {
        if let profile = self.configurations?.getProfile() {
            PersistentStorage().convert(profile: profile)
        } else {
            PersistentStorage().convert(profile: nil)
        }
        self.jsonbutton.isHidden = true
        ViewControllerReference.shared.convertjsonbutton = false
        self.verify()
    }

    func verify() {
        let verify: VerifyJSON?
        if let profile = self.configurations?.getProfile() {
            verify = VerifyJSON(profile: profile)
        } else {
            verify = VerifyJSON(profile: nil)
        }
        if verify?.verifyconf ?? false, verify?.verifysched ?? false == true {
            // self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            // self.info.stringValue = NSLocalizedString("Verify OK...", comment: "Verify")
        } else {
            // self.info.textColor = setcolor(nsviewcontroller: self, color: .red)
            // self.info.stringValue = NSLocalizedString("Verify not OK, see logfile (⌘O)...", comment: "Verify")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // JSON
        self.jsonbutton.isHidden = !ViewControllerReference.shared.convertjsonbutton
        self.jsonlabel.isHidden = !ViewControllerReference.shared.json
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }
}
