//
//  ViewControllerSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerSsh: NSViewController {
    
    var ras:Bool = false
    var dsa:Bool = false
    var Ssh:ssh?
    
    @IBOutlet weak var dsaCheck: NSButton!
    @IBOutlet weak var rsaCheck: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.Ssh = ssh()
        if self.Ssh!.rsaBool {
            self.rsaCheck.state = NSOnState
        } else {
            self.rsaCheck.state = NSOffState
        }
        if self.Ssh!.dsaBool {
            self.dsaCheck.state = NSOnState
        } else {
            self.dsaCheck.state = NSOffState
        }
    }
}
