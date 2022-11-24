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
    static let synchronizeall = NSToolbarItem.Identifier("synchronizeall")
    static let estimateandsynchronize = NSToolbarItem.Identifier("estimateandsynchronize")
    static let executetasknow = NSToolbarItem.Identifier("executetasknow")
    static let abort = NSToolbarItem.Identifier("abort")
    static let userconfig = NSToolbarItem.Identifier("userconfig")
}

extension Selector {
    static let synchronizeall = #selector(ViewControllerSideBar.automaticbackup(_:))
    static let estimateandsynchronize = #selector(ViewControllerSideBar.totinfo(_:))
    static let executetasknow = #selector(ViewControllerMain.executemultipleselectedindexes(_:))
    static let abort = #selector(ViewControllerMain.abort(_:))
    static let userconfig = #selector(ViewControllerSideBar.userconfiguration(_:))
}

extension MainWindowsController: NSToolbarDelegate {
    func toolbar(_: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem?
    {
        switch itemIdentifier {
        case .synchronizeall:
            let title = NSLocalizedString("Execute all tasks now...", comment: "Toolbar")
            return toolbarbuttonsandactions(.synchronizeall, title, AppAssets.synchronizeall, Selector.synchronizeall)
        case .estimateandsynchronize:
            let title = NSLocalizedString("Execute estimate and quickbackup for all tasks...", comment: "Toolbar")
            return toolbarbuttonsandactions(.estimateandsynchronize, title, AppAssets.estimateandsynchronize, Selector.estimateandsynchronize)
        case .executetasknow:
            let title = NSLocalizedString("Execute selected tasks...", comment: "Toolbar")
            return toolbarbuttonsandactions(.executetasknow, title, AppAssets.executetasknow, Selector.executetasknow)
        case .abort:
            let title = NSLocalizedString("Abort task...", comment: "Toolbar")
            return toolbarbuttonsandactions(.abort, title, AppAssets.abort, Selector.abort)
        case .userconfig:
            let title = NSLocalizedString("Show userconfig...", comment: "Toolbar")
            return toolbarbuttonsandactions(.userconfig, title, AppAssets.userconfig, Selector.userconfig)
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
            .space,
            .synchronizeall,
            .estimateandsynchronize,
            .executetasknow,
            .space,
            .abort,
            .userconfig,
        ]
    }

    func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .space,
            .synchronizeall,
            .estimateandsynchronize,
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
    static var synchronizeall: NSImage! = NSImage(named: "synchronizeall")

    static var estimateandsynchronize: NSImage! = NSImage(named: "estimateandsynchronize")

    static var executetasknow: NSImage! = NSImage(named: "executetasknow")

    static var abort: NSImage! = NSImage(named: "abort")

    static var userconfig: NSImage! = NSImage(named: "userconfig")
}
