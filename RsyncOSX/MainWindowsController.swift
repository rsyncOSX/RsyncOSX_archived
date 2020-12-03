//
//  MainWindowsController.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

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
        globalMainQueue.async { () -> Void in
            let toolbar = NSToolbar(identifier: "Toolbar")
            toolbar.allowsUserCustomization = false
            toolbar.autosavesConfiguration = false
            toolbar.displayMode = .iconOnly
            toolbar.delegate = self
            // self.window?.toolbar = toolbar
        }
        window?.toolbar?.validateVisibleItems()
    }
}
