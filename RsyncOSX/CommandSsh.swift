//
//  sshprocessCmd.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class CommandSsh: ProcessCmd {
    override init(command: String?, arguments: [String]?) {
        super.init(command: command, arguments: arguments)
        self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
    }
}
