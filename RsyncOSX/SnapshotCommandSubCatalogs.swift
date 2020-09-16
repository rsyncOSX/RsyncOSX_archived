//
//  SnapshotCommandSubDir.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class SnapshotCommandSubCatalogs: ProcessCmd {
    init(arguments: [String]?) {
        super.init(command: nil, arguments: arguments)
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
    }
}
