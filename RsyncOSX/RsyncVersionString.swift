//
//  RsyncVersionString.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

struct RsyncVersionString {
    var outputprocess: OutputProcess?
    init() {
        if ViewControllerReference.shared.norsync == false {
            self.outputprocess = OutputProcess()
            let command = RsyncProcessCmdClosure(arguments: ["--version"],
                                                 config: nil,
                                                 processtermination: self.processtermination,
                                                 filehandler: self.filehandler)
            command.executeProcess(outputprocess: self.outputprocess)
        }
    }
}

extension RsyncVersionString {
    func processtermination() {
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

    func filehandler() {
        // none
    }
}
