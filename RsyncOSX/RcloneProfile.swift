//
//  RcloneProfile.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class RcloneProfiles: Files {

    init () {
        super.init(whatroot: .profileRoot, configpath: RcloneReference.shared.configpath)
    }
}
