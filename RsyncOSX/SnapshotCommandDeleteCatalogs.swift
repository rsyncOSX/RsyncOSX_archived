//
//  SnapshotCommandDeleteCatalogs.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class SnapshotCommandDeleteCatalogs: ProcessCmd {

    func setdelegate(object: UpdateProgress) {
        self.updateDelegate = object
    }

    override init (command: String?, arguments: [String]?) {
        super.init(command: command, arguments: arguments)
    }
}
