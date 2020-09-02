//
//  ViewControllerAbout.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/11/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerAbout: NSViewController, SetDismisser {
    @IBOutlet var version: NSTextField!
    @IBOutlet var downloadbutton: NSButton!
    @IBOutlet var thereisanewversion: NSTextField!
    @IBOutlet var rsyncversionstring: NSTextField!
    @IBOutlet var copyright: NSTextField!
    @IBOutlet var iconby: NSTextField!
    @IBOutlet var chinese: NSTextField!
    @IBOutlet var norwegian: NSTextField!
    @IBOutlet var german: NSTextField!
    @IBOutlet var italian: NSTextField!
    @IBOutlet var configpath: NSTextField!

    var copyrigthstring: String = NSLocalizedString("Copyright ©2020 Thomas Evensen", comment: "copyright")
    var iconbystring: String = NSLocalizedString("Icon by: Zsolt Sándor", comment: "icon")
    var chinesestring: String = NSLocalizedString("Chinese (Simplified) translation by: StringKe", comment: "chinese")
    var norwegianstring: String = NSLocalizedString("Norwegian translation by: Thomas Evensen", comment: "norwegian")
    var germanstring: String = NSLocalizedString("German translation by: Andre", comment: "german")
    var italianstring: String = NSLocalizedString("Italian translation by: Stefano Steve Cutelle'", comment: "italian")

    var resource: Resources?
    var outputprocess: OutputProcess?

    @IBAction func changelog(_: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .changelog))!)
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func documentation(_: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .documents))!)
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func introduction(_: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .introduction))!)
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func download(_: NSButton) {
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
        self.copyright.stringValue = self.copyrigthstring
        self.iconby.stringValue = self.iconbystring
        self.chinese.stringValue = self.chinesestring
        self.norwegian.stringValue = self.norwegianstring
        self.german.stringValue = self.germanstring
        self.italian.stringValue = self.italianstring
        self.resource = Resources()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.downloadbutton.isEnabled = false
        if let version = Checkfornewversion().rsyncOSXversion() {
            self.version.stringValue = "RsyncOSX ver: " + version
        }
        self.thereisanewversion.stringValue = NSLocalizedString("You have the latest ...", comment: "About")
        self.rsyncversionstring.stringValue = ViewControllerReference.shared.rsyncversionstring ?? ""
        self.configpath.stringValue = NamesandPaths(profileorsshrootpath: .profileroot).fullroot ?? ""
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.downloadbutton.isEnabled = false
    }
}

extension ViewControllerAbout: NewVersionDiscovered {
    // Notifies if new version is discovered
    func notifyNewVersion() {
        globalMainQueue.async { () -> Void in
            self.downloadbutton.isEnabled = true
            self.thereisanewversion.stringValue = NSLocalizedString("New version is available:", comment: "About")
        }
    }
}
