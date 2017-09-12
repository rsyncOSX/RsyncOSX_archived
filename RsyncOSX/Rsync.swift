//
//  Rsync.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

final class Rsync: ProcessCmd {

    init (arguments: Array<String>?) {
        super.init(command: nil, arguments: arguments, aScheduledOperation: false)
        // Process is inated from Main
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
    }
}
