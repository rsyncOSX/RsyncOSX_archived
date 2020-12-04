//
//  Toolbar.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma line_length

import Cocoa
import Foundation

extension NSToolbarItem.Identifier {
    static let allprofiles = NSToolbarItem.Identifier("allprofiles")
    static let backupnow = NSToolbarItem.Identifier("backupnow")
    static let estimateandquickbackup = NSToolbarItem.Identifier("estimateandquickbackup")
    static let executetasknow = NSToolbarItem.Identifier("executetasknow")
    static let abort = NSToolbarItem.Identifier("abort")
    static let userconfig = NSToolbarItem.Identifier("userconfig")
}

extension Selector {
    static let allprofiles = #selector(ViewControllerSideBar.allprofiles(_:))
    static let backupnow = #selector(ViewControllerSideBar.automaticbackup(_:))
    static let estimateandquickbackup = #selector(ViewControllerSideBar.totinfo(_:))
    static let executetasknow = #selector(ViewControllerMain.executemultipleselectedindexes(_:))
    static let abort = #selector(ViewControllerMain.abort(_:))
    static let userconfig = #selector(ViewControllerSideBar.userconfiguration(_:))
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
            return buildToolbarButton(.backupnow, title, AppAssets.backupnow, Selector.backupnow)
        case .estimateandquickbackup:
            let title = NSLocalizedString("Execute estimate and quickbackup for all tasks...", comment: "Toolbar")
            return buildToolbarButton(.estimateandquickbackup, title, AppAssets.estimateandquickbackup, Selector.estimateandquickbackup)
        case .executetasknow:
            let title = NSLocalizedString("Execute selected tasks...", comment: "Toolbar")
            return buildToolbarButton(.executetasknow, title, AppAssets.executetasknow, Selector.executetasknow)
        case .abort:
            let title = NSLocalizedString("Abort task...", comment: "Toolbar")
            return buildToolbarButton(.abort, title, AppAssets.abort, Selector.abort)
        case .userconfig:
            let title = NSLocalizedString("Show userconfig...", comment: "Toolbar")
            return buildToolbarButton(.userconfig, title, AppAssets.userconfig, Selector.userconfig)
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
            .executetasknow,
            .abort,
            .flexibleSpace,
            .userconfig,
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
            .executetasknow,
            .abort,
            .flexibleSpace,
            .userconfig,
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
        NSImage(named: "estimateandquickbackup")
    }()

    static var executetasknow: NSImage! = {
        NSImage(named: "executetasknow")
    }()

    static var abort: NSImage! = {
        NSImage(named: "abort")
    }()

    static var userconfig: NSImage! = {
        NSImage(named: "userconfig")
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
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }
}

extension ViewControllerNewConfigurations {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
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

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
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

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }

    // Toolbar -  abort Snapshots
    @IBAction func abort(_: NSButton) {
        self.info.stringValue = Infosnapshots().info(num: 2)
        self.snapshotlogsandcatalogs?.snapshotcatalogstodelete = nil
    }
}

extension ViewControllerRestore {
    @IBAction func allprofiles(_: NSButton) {
        self.presentAsModalWindow(self.allprofiles!)
    }

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
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

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard ViewControllerReference.shared.process == nil else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard ViewControllerReference.shared.process == nil else { return }
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
        guard ViewControllerReference.shared.process == nil else { return }
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }
}
