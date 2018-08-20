//
//  RcloneUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation
// Reading userconfiguration from file into RsyncOSX
final class RcloneUserconfiguration {

    private func readUserconfiguration(dict: NSDictionary) {
        // Optional path for rsync
        if let rclonePath = dict.value(forKey: "rclonePath") as? String {
            RcloneReference.shared.rclonePath = rclonePath
        }
    }

    init (userconfigRsyncOSX: [NSDictionary]) {
        if userconfigRsyncOSX.count > 0 {
            self.readUserconfiguration(dict: userconfigRsyncOSX[0])
        }
        RcloneTools().verifyrclonepath()
    }
}
