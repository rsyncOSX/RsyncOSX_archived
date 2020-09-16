//
//  RsyncVersionString.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class RsyncVersionString: ProcessCmd {
    var outputprocess: OutputProcess?

    init() {
        super.init(command: nil, arguments: ["--version"])
        self.outputprocess = OutputProcess()
        if ViewControllerReference.shared.norsync == false {
            self.updateDelegate = self
            self.executeProcess(outputprocess: self.outputprocess)
        }
    }
}

extension RsyncVersionString: UpdateProgress {
    func processTermination() {
        guard self.outputprocess?.getOutput()?.count ?? 0 > 0 else { return }
        if let rsyncversionshort = self.outputprocess?.getOutput()?[0],
            let rsyncversionstring = self.outputprocess?.getOutput()?.joined(separator: "\n")
        {
            ViewControllerReference.shared.rsyncversionshort = rsyncversionshort
            ViewControllerReference.shared.rsyncversionstring = rsyncversionstring
        }
        weak var shortstringDelegate: RsyncIsChanged?
        shortstringDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        shortstringDelegate?.rsyncischanged()
    }

    func fileHandler() {
        // none
    }
}
