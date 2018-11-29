//
//  RsyncVersionString.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class RsyncVersionString: ProcessCmd {

    init () {
        super.init(command: nil, arguments: ["--version"])
        let outputprocess = OutputProcess()
        if ViewControllerReference.shared.norsync == false {
            self.updateDelegate = nil
            self.executeProcess(outputprocess: outputprocess)
            self.delayWithSeconds(0.25) {
                guard outputprocess.getOutput() != nil else { return }
                guard outputprocess.getOutput()!.count > 0 else { return }
                ViewControllerReference.shared.rsyncversionshort = outputprocess.getOutput()![0]
                ViewControllerReference.shared.rsyncversionstring = outputprocess.getOutput()!.joined(separator: "\n")
                weak var shortstringDelegate: RsyncIsChanged?
                shortstringDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
                shortstringDelegate?.rsyncischanged()
            }
        }
    }
}
