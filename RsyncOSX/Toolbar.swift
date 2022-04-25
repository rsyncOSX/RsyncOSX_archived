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
    static let backupnow = NSToolbarItem.Identifier("backupnow")
    static let estimateandquickbackup = NSToolbarItem.Identifier("estimateandquickbackup")
    static let executetasknow = NSToolbarItem.Identifier("executetasknow")
    static let abort = NSToolbarItem.Identifier("abort")
    static let userconfig = NSToolbarItem.Identifier("userconfig")
}

extension Selector {
    static let backupnow = #selector(ViewControllerSideBar.automaticbackup(_:))
    static let estimateandquickbackup = #selector(ViewControllerSideBar.totinfo(_:))
    static let executetasknow = #selector(ViewControllerMain.executemultipleselectedindexes(_:))
    static let abort = #selector(ViewControllerMain.abort(_:))
    static let userconfig = #selector(ViewControllerSideBar.userconfiguration(_:))
    // static let addtask = #selector(ViewControllerSideBar.addtask(_:))
}

extension MainWindowsController: NSToolbarDelegate {
    func toolbar(_: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem?
    {
        switch itemIdentifier {
        case .backupnow:
            let title = NSLocalizedString("Execute all tasks now...", comment: "Toolbar")
            return toolbarbuttonsandactions(.backupnow, title, AppAssets.backupnow, Selector.backupnow)
        case .estimateandquickbackup:
            let title = NSLocalizedString("Execute estimate and quickbackup for all tasks...", comment: "Toolbar")
            return toolbarbuttonsandactions(.estimateandquickbackup, title, AppAssets.estimateandquickbackup, Selector.estimateandquickbackup)
        case .executetasknow:
            let title = NSLocalizedString("Execute selected tasks...", comment: "Toolbar")
            return toolbarbuttonsandactions(.executetasknow, title, AppAssets.executetasknow, Selector.executetasknow)
        case .abort:
            let title = NSLocalizedString("Abort task...", comment: "Toolbar")
            return toolbarbuttonsandactions(.abort, title, AppAssets.abort, Selector.abort)
        case .userconfig:
            let title = NSLocalizedString("Show userconfig...", comment: "Toolbar")
            return toolbarbuttonsandactions(.userconfig, title, AppAssets.userconfig, Selector.userconfig)
        /*
         case .addtask:
             let title = NSLocalizedString("Add task...", comment: "Toolbar")
             return toolbarbuttonsandactions(.addtask, title, AppAssets.addtask, Selector.addtask)
         */
        default:
            break
        }
        return nil
    }

    func toolbarbuttonsandactions(_ itemIdentifier: NSToolbarItem.Identifier,
                                  _ title: String,
                                  _ image: NSImage,
                                  _ selector: Selector) -> NSToolbarItem
    {
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
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
            // .addtask,
            .space,
            .backupnow,
            .estimateandquickbackup,
            .executetasknow,
            .space,
            .abort,
            .userconfig,
        ]
    }

    func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            // .addtask,
            .space,
            .backupnow,
            .estimateandquickbackup,
            .executetasknow,
            .space,
            .abort,
            .userconfig,
        ]
    }

    func toolbarWillAddItem(_: Notification) {}

    func toolbarDidRemoveItem(_: Notification) {}
}

struct AppAssets {
    static var backupnow: NSImage! = NSImage(named: "backupnow")

    static var estimateandquickbackup: NSImage! = NSImage(named: "estimateandquickbackup")

    static var executetasknow: NSImage! = NSImage(named: "executetasknow")

    static var abort: NSImage! = NSImage(named: "abort")

    static var userconfig: NSImage! = NSImage(named: "userconfig")

    static var addtask: NSImage! = NSImage(named: "greenplus")
}
