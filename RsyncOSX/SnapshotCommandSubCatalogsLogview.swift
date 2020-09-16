//
//  SnapshotCommandSubCatalogsLogview.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27/11/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class SnapshotCommandSubCatalogsLogview: ProcessCmd {
    init(arguments: [String]?) {
        super.init(command: nil, arguments: arguments)
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
    }
}
