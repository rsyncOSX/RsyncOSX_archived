//
//  ViewControllerAbout.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/11/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerAbout: NSViewController {
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
    @IBOutlet var dutch: NSTextField!

    var copyrigthstring: String = NSLocalizedString("Copyright ©2023 Thomas Evensen", comment: "copyright")
    var iconbystring: String = NSLocalizedString("Icon by: Zsolt Sándor", comment: "icon")
    var chinesestring: String = NSLocalizedString("Chinese (Simplified) translation by: StringKe (Chen)", comment: "chinese")
    var norwegianstring: String = NSLocalizedString("Norwegian translation by: Thomas Evensen", comment: "norwegian")
    var germanstring: String = NSLocalizedString("German translation by: Andre Voigtmann", comment: "german")
    var italianstring: String = NSLocalizedString("Italian translation by: Stefano Steve Cutelle'", comment: "italian")
    var dutchstring: String = NSLocalizedString("Dutch translation by: Marcellino Santoso", comment: "ducth")

    var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"
    }

    var appBuild: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "1.0"
    }

    var resource: Resources?

    @IBAction func changelog(_: NSButton) {
        if let resource = resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .changelog))!)
        }
        view.window?.close()
    }

    @IBAction func documentation(_: NSButton) {
        if let resource = resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .documents))!)
        }
        view.window?.close()
    }

    @IBAction func download(_: NSButton) {
        guard SharedReference.shared.URLnewVersion != nil else {
            view.window?.close()
            return
        }
        NSWorkspace.shared.open(URL(string: SharedReference.shared.URLnewVersion!)!)
        view.window?.close()
    }

    @IBAction func closeview(_: NSButton) {
        view.window?.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SharedReference.shared.setvcref(viewcontroller: .vcabout, nsviewcontroller: self)
        copyright.stringValue = copyrigthstring
        iconby.stringValue = iconbystring
        chinese.stringValue = chinesestring
        norwegian.stringValue = norwegianstring
        german.stringValue = germanstring
        italian.stringValue = italianstring
        dutch.stringValue = dutchstring
        resource = Resources()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        downloadbutton.isEnabled = false
        let version = appVersion + " build" + "(" + appBuild + ")"
        self.version.stringValue = "RsyncOSX ver: " + version
        thereisanewversion.stringValue = NSLocalizedString("You have the latest ...", comment: "About")
        rsyncversionstring.stringValue = SharedReference.shared.rsyncversionstring ?? ""
        configpath.stringValue = NamesandPaths(.configurations).fullpathmacserial ?? ""
        if SharedReference.shared.newversionofrsyncosx {
            globalMainQueue.async { () in
                self.downloadbutton.isEnabled = true
                self.thereisanewversion.stringValue = NSLocalizedString("New version is available:", comment: "About")
            }
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        downloadbutton.isEnabled = false
    }
}
