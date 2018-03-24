//
//  ViewControllerEncrypt.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

import Cocoa

class ViewControllerEncrypt: NSViewController {

    private var profilesArray: [String]?
    private var profile: RcloneProfiles?
    private var useprofile: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.profile = nil
        self.profile = RcloneProfiles()
        self.profilesArray = self.profile!.getDirectorysStrings()
    }

    @IBAction func rclone(_ sender: NSButton) {
        _ = TestRclone()
    }
}
