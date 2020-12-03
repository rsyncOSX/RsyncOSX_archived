//
//  MainWindowsController.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma line_length cyclomatic_complexity

import Cocoa
import Foundation

class MainWindowsController: NSWindowController, VcMain {
    private var viewcontrollersidebar: ViewControllerSideBar?
    private var tabviewcontroller: TabViewController?
    private var splitviewcontroller: NSSplitViewController? {
        guard let viewController = contentViewController else {
            return nil
        }
        return viewController.children.first as? NSSplitViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        DispatchQueue.main.async {
            let toolbar = NSToolbar(identifier: "Toolbar")
            toolbar.allowsUserCustomization = false
            toolbar.autosavesConfiguration = false
            toolbar.displayMode = .iconOnly
            toolbar.delegate = self
            self.window?.toolbar = toolbar
        }
        window?.toolbar?.validateVisibleItems()
    }

    func buildToolbarButton(_ itemIdentifier: NSToolbarItem.Identifier, _ title: String, _ image: NSImage, _ selector: String) -> NSToolbarItem {
        let toolbarItem = RSToolbarItem(itemIdentifier: itemIdentifier)
        toolbarItem.autovalidates = false
        let button = NSButton()
        button.bezelStyle = .texturedRounded
        button.image = image
        button.imageScaling = .scaleProportionallyDown
        button.action = Selector((selector))
        toolbarItem.view = button
        toolbarItem.toolTip = title
        toolbarItem.label = title
        return toolbarItem
    }

    @IBAction func allprofiles(_: Any?) {
        print("test")
    }
}

extension NSToolbarItem.Identifier {
    static let report = NSToolbarItem.Identifier("report")
    static let allprofiles = NSToolbarItem.Identifier("allprofiles")
    static let backupnow = NSToolbarItem.Identifier("backupnow")
    static let quickbackup = NSToolbarItem.Identifier("quickbackup")
    static let execute = NSToolbarItem.Identifier("execute")
    static let abort = NSToolbarItem.Identifier("abort")
    static let config = NSToolbarItem.Identifier("config")
}

extension MainWindowsController: NSToolbarDelegate {
    func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem?
    {
        switch itemIdentifier {
        case .report:
            let title = NSLocalizedString("Display output from rsync singletasks...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.report, "alloutput")
        case .allprofiles:
            let title = NSLocalizedString("List all profiles and configurations...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.allprofiles, "allprofiles")
        case .backupnow:
            let title = NSLocalizedString("Execute all tasks now...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.backupnow, "automaticbackup")
        case .quickbackup:
            let title = NSLocalizedString("Execute estimate and quickbackup for all tasks...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.quickbackup, "quickbackup")
        case .execute:
            let title = NSLocalizedString("Execute selected tasks...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.execute, "allprofiles")
        case .abort:
            let title = NSLocalizedString("Abort task...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.abort, "abort")
        case .config:
            let title = NSLocalizedString("Show userconfig...", comment: "Toolbar")
            return buildToolbarButton(.allprofiles, title, AppAssets.config, "userconfiguration")
        default:
            break
        }
        return nil
    }

    func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .report,
            .allprofiles,
            .flexibleSpace,
            .backupnow,
            .quickbackup,
            .flexibleSpace,
            .execute,
            .abort,
            .flexibleSpace,
            .config,
            .flexibleSpace,
        ]
    }

    func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .report,
            .allprofiles,
            .flexibleSpace,
            .backupnow,
            .quickbackup,
            .flexibleSpace,
            .execute,
            .abort,
            .flexibleSpace,
            .config,
            .flexibleSpace,
        ]
    }

    func toolbarWillAddItem(_: Notification) {}

    func toolbarDidRemoveItem(_: Notification) {}
}

import AppKit

struct AppAssets {
    static var report: RSImage! = {
        RSImage(named: "report")
    }()

    static var allprofiles: RSImage! = {
        RSImage(named: "allprofiles")
    }()

    static var backupnow: RSImage! = {
        RSImage(named: "backupnow")
    }()

    static var quickbackup: RSImage! = {
        RSImage(named: "quickbackup")
    }()

    static var execute: RSImage! = {
        RSImage(named: "execute")
    }()

    static var abort: RSImage! = {
        RSImage(named: "abort")
    }()

    static var config: RSImage! = {
        RSImage(named: "config")
    }()
}

public typealias RSImage = NSImage

public extension RSImage {
    static func sscaleImage(_ data: Data, maxPixelSize: Int) -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        let numberOfImages = CGImageSourceGetCount(imageSource)
        // If the image size matches exactly, then return it.
        for i in 0 ..< numberOfImages {
            guard let cfImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) else {
                continue
            }
            let imageProperties = cfImageProperties as NSDictionary
            guard let imagePixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? NSNumber else {
                continue
            }
            if imagePixelWidth.intValue != maxPixelSize {
                continue
            }
            guard let imagePixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? NSNumber else {
                continue
            }
            if imagePixelHeight.intValue != maxPixelSize {
                continue
            }
            return CGImageSourceCreateImageAtIndex(imageSource, i, nil)
        }
        // If image height > maxPixelSize, but <= maxPixelSize * 2, then return it.
        for i in 0 ..< numberOfImages {
            guard let cfImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) else {
                continue
            }
            let imageProperties = cfImageProperties as NSDictionary
            guard let imagePixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? NSNumber else {
                continue
            }
            if imagePixelWidth.intValue > maxPixelSize * 2 || imagePixelWidth.intValue < maxPixelSize {
                continue
            }
            guard let imagePixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? NSNumber else {
                continue
            }
            if imagePixelHeight.intValue > maxPixelSize * 2 || imagePixelHeight.intValue < maxPixelSize {
                continue
            }
            return CGImageSourceCreateImageAtIndex(imageSource, i, nil)
        }
        for i in 0 ..< numberOfImages {
            guard let cfImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) else {
                continue
            }
            let imageProperties = cfImageProperties as NSDictionary
            guard let imagePixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? NSNumber else {
                continue
            }
            if imagePixelWidth.intValue < 1 || imagePixelWidth.intValue > maxPixelSize {
                continue
            }
            guard let imagePixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? NSNumber else {
                continue
            }
            if imagePixelHeight.intValue > 0, imagePixelHeight.intValue <= maxPixelSize {
                if let image = CGImageSourceCreateImageAtIndex(imageSource, i, nil) {
                    return image
                }
            }
        }
        return RSImage.createThumbnail(imageSource, maxPixelSize: maxPixelSize)
    }

    static func createThumbnail(_ imageSource: CGImageSource, maxPixelSize: Int) -> CGImage? {
        let options = [kCGImageSourceCreateThumbnailWithTransform: true,
                       kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                       kCGImageSourceThumbnailMaxPixelSize: NSNumber(value: maxPixelSize)]
        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
    }
}

import AppKit

public class RSToolbarItem: NSToolbarItem {
    override public func validate() {
        guard let view = view, let _ = view.window else {
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
