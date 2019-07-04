//
//  Activetab.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/07/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Activetab {
    var isactive: Bool = false

    init(viewcontroller: ViewController) {
        if ViewControllerReference.shared.activetab == viewcontroller {
            self.isactive = true
        } else {
            self.isactive = false
        }
    }
}
