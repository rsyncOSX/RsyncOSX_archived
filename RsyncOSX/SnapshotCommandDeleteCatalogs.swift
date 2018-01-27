//
//  SnapshotCommandDeleteCatalogs.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

// swiftlint:disable line_length

import Foundation

final class SnapshotCommandDeleteCatalogs: ProcessCmd {
    override init (command: String?, arguments: [String]?) {
        super.init(command: command, arguments: arguments)
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
    }
}

