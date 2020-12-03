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
    }
}
