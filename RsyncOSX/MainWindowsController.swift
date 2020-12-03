//
//  MainWindowsController.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class MainWindowsController: NSWindowController {
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
            toolbar.allowsUserCustomization = true
            toolbar.autosavesConfiguration = true
            toolbar.displayMode = .iconOnly
            toolbar.delegate = self
            self.window?.toolbar = toolbar
        }
        window?.toolbar?.validateVisibleItems()
    }

    func buildToolbarButton(_ itemIdentifier: NSToolbarItem.Identifier, _ title: String, _ image: NSImage, _ selector: String) -> NSToolbarItem {
        let toolbarItem = RSToolbarItem(itemIdentifier: itemIdentifier)
        toolbarItem.autovalidates = true

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
    func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .allprofiles:
            let title = NSLocalizedString("All profiles", comment: "Star")
            return buildToolbarButton(.allprofiles, title, AppAssets.sum, "allprofiles")
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
    static var sum: RSImage! = {
        RSImage(named: "allprofiles")
    }()
}

public typealias RSImage = NSImage

public extension RSImage {
    /// Create a colored image from the source image using a specified color.
    ///
    /// - Parameter color: The color with which to fill the mask image.
    /// - Returns: A new masked image.
    func maskWithColor(color: CGColor) -> RSImage? {
        guard let maskImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = RSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
            return coloredImage
        } else {
            return nil
        }
    }

    /// Create a scaled image from image data.
    ///
    /// - Note: the returned image may be larger than `maxPixelSize`, but not more than `maxPixelSize * 2`.
    /// - Parameters:
    ///   - data: The data object containing the image data.
    ///   - maxPixelSize: The maximum dimension of the image.
    static func scaleImage(_ data: Data, maxPixelSize: Int) -> CGImage? {
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

        // If the image data contains a smaller image than the max size, just return it.
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

    /// Create a thumbnail from a CGImageSource.
    ///
    /// - Parameters:
    ///   - imageSource: The `CGImageSource` from which to create the thumbnail.
    ///   - maxPixelSize: The maximum dimension of the resulting image.
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
        // Use NSValidatedUserInterfaceItem protocol rather than calling validateToolbarItem:.

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
