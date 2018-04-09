//
//  Combined.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06.04.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

protocol Norcloneconfig: class {
    func norcloneconfig()
}

class Combined: SetConfigurations {

    var configurationsrclone: ConfigurationsRclone?
    var arguments: [String]?
    var command: String?
    var execute: Bool = false

    init(profile: String?, index: Int) {
        self.configurationsrclone = ConfigurationsRclone(profile: profile)
        if let rclonehiddenID = self.configurations?.getConfigurations()[index].rclonehiddenID {
            if let rcloneindex = self.configurationsrclone?.getIndex(rclonehiddenID) {
                if rcloneindex >= 0 {
                    self.arguments = self.configurationsrclone?.arguments4rclone(index: rcloneindex, argtype: .arg)
                    self.command = RcloneTools().rclonepath()
                    self.execute = true
                }
            }
        }
        if execute {
            let executerclone = Rclone(command: self.command, arguments: self.arguments)
            executerclone.executeProcess(outputprocess: nil)
        } else {
            weak var norcloneconfigDelegate: Norcloneconfig?
            norcloneconfigDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            norcloneconfigDelegate?.norcloneconfig()
        }
    }
}
