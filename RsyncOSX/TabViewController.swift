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
        view.frame.size.width = 995 + 12
        view.frame.size.height = 350 + 12
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setsize()
    }
}
