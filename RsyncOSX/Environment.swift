//
//  Environment.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Environment {
    var environment: [String: String]?

    init?() {
        if let environment = ViewControllerReference.shared.environment {
            if let environmentvalue = ViewControllerReference.shared.environmentvalue {
                self.environment = [environment: environmentvalue]
            }
        }
    }
}
