//
//  ViewControllerAbout.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/11/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerAbout: NSViewController {

    // Dismisser
    weak var dismissDelegate: DismissViewController?
    // RsyncOSX version
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var downloadbutton: NSButton!
    @IBOutlet weak var thereisanewversion: NSTextField!

    // new version
    var checkfornewversion: Checkfornewversion?
    // External resources as documents, download
    private var resource: Resources?

    @IBAction func dismiss(_ sender: NSButton) {
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func changelog(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .changelog))!)
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func documentation(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .documents))!)
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func download(_ sender: NSButton) {
        guard Configurations.shared.URLnewVersion != nil else {
            self.dismissDelegate?.dismiss_view(viewcontroller: self)
            return
        }
        NSWorkspace.shared.open(URL(string: Configurations.shared.URLnewVersion!)!)
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let pvc = self.presenting as? ViewControllertabMain {
            self.dismissDelegate = pvc
        }
        // Reference to About
        Configurations.shared.viewControllerAbout = self
        self.resource = Resources()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.downloadbutton.isEnabled = false
        // Check for new version
        self.checkfornewversion = Checkfornewversion(inMain: false)
        if let version = self.checkfornewversion!.rsyncOSXversion() {
            self.version.stringValue = "RsyncOSX ver: " + version
        }
        self.thereisanewversion.stringValue = "Latest version is installed: "
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
