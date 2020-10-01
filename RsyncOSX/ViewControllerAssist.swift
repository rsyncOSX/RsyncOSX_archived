//
//  ViewControllerAssist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerAssit: NSViewController {
    var remotecomputers: Set<String>?
    var remoteusers: Set<String>?
    var remotecatalogs:  Set<String>?
    var remotebase: Set<String>?
    var localcatalogs: Set<String>?
    var nameandpaths: NamesandPaths?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameandpaths = NamesandPaths(profileorsshrootpath: .profileroot)
        self.test()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    func test() {
        self.remotecomputers = ["10.0.0.57"]
        self.remoteusers = ["thomas"]
        self.remotecatalogs = ["GitHub","Documents","rcloneencrypted","Pictures_raw"]
        self.remotebase = ["/backup2/RsyncOSX","/backup/RsyncOSX"]
        self.localcatalogs = ["GitHub","Documents","rcloneencrypted","Pictures_raw"]
    }
}
