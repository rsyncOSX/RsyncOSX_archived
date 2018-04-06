//
//  Combined.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06.04.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class Combined: SetConfigurations {
    
    var configurationsrclone: ConfigurationsRclone?
    var arguments: [String]?
    var command: String?
    
    init(profile: String?, index: Int) {
        self.configurationsrclone = ConfigurationsRclone(profile: profile)
        if let rclonehiddenID = self.configurations?.getConfigurations()[index].rclonehiddenID {
            let rcloneindex = self.configurationsrclone?.getIndex(rclonehiddenID)
            self.arguments = self.configurationsrclone?.arguments4rclone(index: rcloneindex!, argtype: .arg)
            self.command = RcloneTools().rclonepath()
        }
    }
}
