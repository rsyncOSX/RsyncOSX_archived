//
//  ViewControllerAbout.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/11/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerAbout: NSViewController, SetDismisser {

    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var downloadbutton: NSButton!
    @IBOutlet weak var thereisanewversion: NSTextField!

    var checkfornewversion: Checkfornewversion?
    // External resources as documents, download
    private var resource: Resources?

    @IBAction func dismiss(_ sender: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func changelog(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .changelog))!)
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func documentation(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .documents))!)
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func download(_ sender: NSButton) {
        guard ViewControllerReference.shared.URLnewVersion != nil else {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
            return
        }
        NSWorkspace.shared.open(URL(string: ViewControllerReference.shared.URLnewVersion!)!)
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcabout, nsviewcontroller: self)
        self.resource = Resources()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.downloadbutton.isEnabled = false
        self.checkfornewversion = Checkfornewversion(inMain: false)
        if let version = self.checkfornewversion!.rsyncOSXversion() {
            self.version.stringValue = "RsyncOSX ver: " + version
        }
        self.thereisanewversion.stringValue = "No new version: "
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.downloadbutton.isEnabled = false
    }

}

extension ViewControllerAbout: NewVersionDiscovered {
    // Notifies if new version is discovered
    func notifyNewVersion() {
        globalMainQueue.async(execute: { () -> Void in
            self.downloadbutton.isEnabled = true
            self.thereisanewversion.stringValue = "New version available: "
        })
    }
}
