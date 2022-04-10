//
//  RsyncVersionString.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

struct RsyncVersionString {
    var outputprocess: OutputfromProcess?
    init() {
        if SharedReference.shared.norsync == false {
            outputprocess = OutputfromProcess()
            let command = RsyncProcess(arguments: ["--version"],
                                       config: nil,
                                       processtermination: processtermination,
                                       filehandler: filehandler)
            command.executeProcess(outputprocess: outputprocess)
        }
    }
}

extension RsyncVersionString {
    func processtermination() {
        guard outputprocess?.getOutput()?.count ?? 0 > 0 else { return }
        if let rsyncversionshort = outputprocess?.getOutput()?[0],
           let rsyncversionstring = outputprocess?.getOutput()?.joined(separator: "\n")
        {
            SharedReference.shared.rsyncversionshort = rsyncversionshort
            SharedReference.shared.rsyncversionstring = rsyncversionstring
        }
        weak var shortstringDelegate: RsyncIsChanged?
        // shortstringDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        shortstringDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        shortstringDelegate?.rsyncischanged()
    }

    func filehandler() {
        // none
    }
}
