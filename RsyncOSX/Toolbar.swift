//
//  Toolbar.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Cocoa
import Foundation

extension NSToolbarItem.Identifier {
    static let allprofiles = NSToolbarItem.Identifier("allprofiles")
    static let backupnow = NSToolbarItem.Identifier("backupnow")
    static let estimateandquickbackup = NSToolbarItem.Identifier("estimateandquickbackup")
    // static let execute = NSToolbarItem.Identifier("execute")
    // static let abort = NSToolbarItem.Identifier("abort")
    static let config = NSToolbarItem.Identifier("config")
}

extension Selector {
    static let allprofiles = #selector(ViewControllerSideBar.allprofiles(_:))
    static let backupnow = #selector(ViewControllerSideBar.automaticbackup(_:))
    static let estimateandquickbackup = #selector(ViewControllerSideBar.totinfo(_:))
    // static let execute = #selector(ViewControllerSideBar.allprofiles(_:))
    // static let abort = #selector(ViewControllerSideBar.allprofiles(_:))
    static let config = #selector(ViewControllerSideBar.userconfiguration(_:))
}

extension MainWindowsController: NSToolbarDelegate {
    func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem?
    {
        switch itemIdentifier {
        case .allprofiles:
            let title = NSLocalizedString("List all profiles and configurations...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.allprofiles, Selector.allprofiles)
        case .backupnow:
            let title = NSLocalizedString("Execute all tasks now...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.backupnow, Selector.backupnow)
        case .estimateandquickbackup:
            let title = NSLocalizedString("Execute estimate and quickbackup for all tasks...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.estimateandquickbackup, Selector.estimateandquickbackup)
        /*
         case .execute:
             let title = NSLocalizedString("Execute selected tasks...", comment: "Toolbar")
             return buildToolbarButton(.allprofiles, title, AppAssets.execute, "allprofiles")
         case .abort:
             let title = NSLocalizedString("Abort task...", comment: "Toolbar")
             return buildToolbarButton(.allprofiles, title, AppAssets.abort, "abort")
         */
        case .config:
            let title = NSLocalizedString("Show userconfig...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.config, Selector.config)
        default:
            break
        }
        return nil
    }

    func buildToolbarButton(_ itemIdentifier: NSToolbarItem.Identifier, _ title: String, _ image: NSImage, _ selector: Selector) -> NSToolbarItem {
        let toolbarItem = RSToolbarItem(itemIdentifier: itemIdentifier)
        toolbarItem.autovalidates = false
        let button = NSButton()
        button.bezelStyle = .texturedRounded
        button.image = image
        button.imageScaling = .scaleProportionallyDown
        button.action = selector
        toolbarItem.view = button
        toolbarItem.toolTip = title
        toolbarItem.label = title
        return toolbarItem
    }

    func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .allprofiles,
            .flexibleSpace,
            .backupnow,
            .estimateandquickbackup,
            .flexibleSpace,
            // .execute,
            // .abort,
            .flexibleSpace,
            .config,
            .flexibleSpace,
        ]
    }

    func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .allprofiles,
            .flexibleSpace,
            .backupnow,
            .estimateandquickbackup,
            .flexibleSpace,
            // .execute,
            // .abort,
            .flexibleSpace,
            .config,
            .flexibleSpace,
        ]
    }

    func toolbarWillAddItem(_: Notification) {}

    func toolbarDidRemoveItem(_: Notification) {}
}

struct AppAssets {
    static var allprofiles: NSImage! = {
        NSImage(named: "allprofiles")
    }()

    static var backupnow: NSImage! = {
        NSImage(named: "backupnow")
    }()

    static var estimateandquickbackup: NSImage! = {
        NSImage(named: "quickbackup")
    }()

    static var execute: NSImage! = {
        NSImage(named: "execute")
    }()

    static var abort: NSImage! = {
        NSImage(named: "abort")
    }()

    static var config: NSImage! = {
        NSImage(named: "config")
    }()
}

public class RSToolbarItem: NSToolbarItem {
    override public func validate() {
        guard let view = view, view.window != nil else {
            isEnabled = false
            return
        }
        isEnabled = isValidAsUserInterfaceItem()
    }
}

private extension RSToolbarItem {
    func isValidAsUserInterfaceItem() -> Bool {
        if let target = target as? NSResponder {
            return validateWithResponder(target) ?? false
        }
        var responder = view?.window?.firstResponder
        if responder == nil {
            return false
        }
        while true {
            if let validated = validateWithResponder(responder!) {
                return validated
            }
            responder = responder?.nextResponder
            if responder == nil {
                break
            }
        }
        if let appDelegate = NSApplication.shared.delegate {
            if let validated = validateWithResponder(appDelegate) {
                return validated
            }
        }
        return false
    }

    func validateWithResponder(_ responder: NSObjectProtocol) -> Bool? {
        guard responder.responds(to: action), let target = responder as? NSUserInterfaceValidations else {
            return nil
        }
        return target.validateUserInterfaceItem(self)
    }
}

extension ViewControllerSideBar {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar -  Estimate and execute automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }

    // Missing Execute
}

extension ViewControllerNewConfigurations {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar -  Estimate and execute automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerSchedule {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar -  Estimate and execute automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerSnapshots {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar -  Estimate and execute automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerRestore {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar -  Estimate and execute automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerLoggData {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar -  Estimate and execute automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerSsh {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }
}
