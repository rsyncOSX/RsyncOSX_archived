//
//  TabViewController.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class TabViewController: NSTabViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame.size.height = 500
        self.view.frame.size.width = 1000
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
}
