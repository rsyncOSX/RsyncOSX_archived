//
//  RestoreTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11.06.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class FullrestoreTask: SetConfigurations {
    var arguments: [String]?
    weak var sendprocess: SendProcessreference?
    var process: ProcessCmd?
    var outputprocess: OutputProcess?

    init(index: Int, dryrun: Bool, tmprestore: Bool, updateprogress: UpdateProgress) {
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if dryrun {
            if tmprestore {
                self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .argdryRun)
                let lastindex = (self.arguments?.count ?? 0) - 1
                guard lastindex > -1 else { return }
                self.arguments?[lastindex] = ViewControllerReference.shared.temporarypathforrestore ?? ""
            } else {
                self.arguments = self.configurations?.arguments4restore(index: index, argtype: .argdryRun)
            }
        } else {
            if tmprestore {
                self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .arg)
                let lastindex = (self.arguments?.count ?? 0) - 1
                guard lastindex > -1 else { return }
                self.arguments?[lastindex] = ViewControllerReference.shared.temporarypathforrestore ?? ""
            } else {
                self.arguments = self.configurations?.arguments4restore(index: index, argtype: .arg)
            }
        }
        if let arguments = self.arguments {
            self.process = ProcessCmd(command: nil, arguments: arguments)
            self.outputprocess = OutputProcessRsync()
            self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
            self.process?.setupdateDelegate(object: updateprogress)
            self.process?.executeProcess(outputprocess: outputprocess)
        }
    }
}
