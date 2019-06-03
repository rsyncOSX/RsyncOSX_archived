//
//  Environment.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

struct Environment {
    var environment: [String: String]?

    init?() {
        guard ViewControllerReference.shared.environment != nil else { return nil }
        guard ViewControllerReference.shared.environmentvalue != nil else { return nil }
        self.environment = [ViewControllerReference.shared.environment!: ViewControllerReference.shared.environmentvalue!]
    }
}
