//
//  Rsync.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

final class Rsync: ProcessCmd {

    func setdelegate(object: UpdateProgress) {
        self.updateDelegate = object
    }

    init (arguments: [String]?) {
        super.init(command: nil, arguments: arguments)
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}
