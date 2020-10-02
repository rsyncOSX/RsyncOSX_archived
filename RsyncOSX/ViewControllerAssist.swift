//
//  ViewControllerAssist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerAssit: NSViewController {
    var remotecomputers: Set<String>?
    var remoteusers: Set<String>?
    var remotecatalogs: Set<String>?
    var remotebase: Set<String>?
    var localcatalogs: Set<String>?
    var numberofsets: Int = 5
    var nameandpaths: NamesandPaths?
    var assist: [Set<String>]?

    @IBAction func closeview(_: NSButton) {
        self.view.window?.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameandpaths = NamesandPaths(profileorsshrootpath: .profileroot)
        self.assist = [Set<String>]()
        self.test()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    func test() {
        self.remotecomputers = ["10.0.0.57"]
        self.remoteusers = ["thomas"]
        self.remotecatalogs = ["GitHub", "Documents", "rcloneencrypted", "Pictures_raw"]
        self.remotebase = ["/backup2/RsyncOSX", "/backup/RsyncOSX"]
        self.localcatalogs = ["GitHub", "Documents", "rcloneencrypted", "Pictures_raw"]
        for i in 0 ..< (self.numberofsets - 1) {
            switch i {
            case 0:
                self.assist?.append(self.remotecomputers ?? [])
            case 1:
                self.assist?.append(self.remoteusers ?? [])
            case 2:
                self.assist?.append(self.remotecatalogs ?? [])
            case 3:
                self.assist?.append(self.remotebase ?? [])
            case 4:
                self.assist?.append(self.localcatalogs ?? [])
            default:
                return
            }
        }
    }
}
