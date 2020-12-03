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
    func setsize() {
        self.view.frame.size.width = 995 + 12
        self.view.frame.size.height = 350 + 12
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setsize()
    }
}
