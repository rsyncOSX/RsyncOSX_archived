//
//  RcloneArgumentsOneConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation
struct RcloneArgumentsOneConfiguration {

    var config: RcloneConfiguration?
    var arg: [String]?
    var argdryRun: [String]?

    init(config: RcloneConfiguration) {
        self.config = config
        self.arg = RcloneRsyncProcessArguments().argumentsRsync(config, dryRun: false)
        self.argdryRun = RcloneRsyncProcessArguments().argumentsRsync(config, dryRun: true)
    }
}
