//
//  RestoreTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11.06.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class FullrestoreTask: SetConfigurations {
    var arguments: [String]?
    weak var sendprocess: SendOutputProcessreference?
    var process: RsyncProcessCmdClosure?
    var outputprocess: OutputProcess?

    init(index: Int, dryrun: Bool, processtermination: @escaping () -> Void, filehandler: @escaping () -> Void) {
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if dryrun {
            self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .argdryRun)
            let lastindex = (self.arguments?.count ?? 0) - 1
            guard lastindex > -1 else { return }
            self.arguments?[lastindex] = ViewControllerReference.shared.temporarypathforrestore ?? ""
        } else {
            self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .arg)
            let lastindex = (self.arguments?.count ?? 0) - 1
            guard lastindex > -1 else { return }
            self.arguments?[lastindex] = ViewControllerReference.shared.temporarypathforrestore ?? ""
        }
        if let arguments = self.arguments {
            self.process = RsyncProcessCmdClosure(arguments: arguments, config: nil, processtermination: processtermination, filehandler: filehandler)
            self.outputprocess = OutputProcessRsync()
            self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
            self.process?.executeProcess(outputprocess: outputprocess)
        }
    }
}
