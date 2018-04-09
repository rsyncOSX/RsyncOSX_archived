//
//  Rclone.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06.04.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class Rclone: ProcessCmd {
    override init (command: String?, arguments: [String]?) {
        super.init(command: command, arguments: arguments)
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}
