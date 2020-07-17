//
//  InterruptProcess.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/06/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

struct InterruptProcess {
    // Enable and disable select profile
    weak var profilepopupDelegate: DisableEnablePopupSelectProfile?
    init() {
        self.profilepopupDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.profilepopupDelegate?.enableselectpopupprofile()
        guard ViewControllerReference.shared.process != nil else { return }
        let output = OutputProcess()
        let string = "Interrupted: " + Date().long_localized_string_from_date()
        output.addlinefromoutput(str: string)
        _ = Logging(output, true)
        ViewControllerReference.shared.process?.interrupt()
        ViewControllerReference.shared.process = nil
    }

    init(output: OutputProcess?) {
        self.profilepopupDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.profilepopupDelegate?.enableselectpopupprofile()
        guard ViewControllerReference.shared.process != nil, output != nil else { return }
        _ = Logging(output, true)
        ViewControllerReference.shared.process?.interrupt()
        ViewControllerReference.shared.process = nil
    }
}
