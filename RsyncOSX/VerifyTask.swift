//
//  VerifyTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.07.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class VerifyTask: ProcessCmd {
    init (arguments: [String]?) {
        super.init(command: nil, arguments: arguments)
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcverify) as? ViewControllerVerify
    }
}
