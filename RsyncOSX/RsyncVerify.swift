//
//  RsyncVerify.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/06/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

@available(OSX 10.14, *)
final class RsyncVerify: ProcessCmdVerify {
    func setdelegate(object: UpdateProgress?) {
        self.updateDelegate = object
    }

    init(arguments: [String]?, config: Configuration?) {
        super.init(command: nil, arguments: arguments, config: config)
    }
}
