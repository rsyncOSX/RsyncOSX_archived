//
//  InterruptProcess.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/06/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct InterruptProcess {
    // Enable and disable select profile
    weak var profilepopupDelegate: DisableEnablePopupSelectProfile?
    init() {
        profilepopupDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        profilepopupDelegate?.enableselectpopupprofile()
        guard SharedReference.shared.process != nil else { return }
        let output = OutputfromProcess()
        let string = "Interrupted: " + Date().long_localized_string_from_date()
        output.addlinefromoutput(str: string)
        _ = Logfile(output, true)
        SharedReference.shared.process?.interrupt()
        SharedReference.shared.process = nil
    }

    init(output: OutputfromProcess?) {
        profilepopupDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        profilepopupDelegate?.enableselectpopupprofile()
        guard SharedReference.shared.process != nil, output != nil else { return }
        _ = Logfile(output, true)
        SharedReference.shared.process?.interrupt()
        SharedReference.shared.process = nil
    }
}
