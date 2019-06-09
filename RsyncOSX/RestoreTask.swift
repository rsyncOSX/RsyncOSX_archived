//
//  RestoreTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11.06.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class RestoreTask: SetConfigurations {
    var arguments: [String]?
    init(index: Int, outputprocess: OutputProcess?, dryrun: Bool, tmprestore: Bool) {
        weak var taskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        if dryrun {
            if tmprestore {
                self.arguments = self.configurations!.arguments4tmprestore(index: index, argtype: .argdryRun)
                let lastindex = self.arguments!.count - 1
                self.arguments![lastindex] = ViewControllerReference.shared.restorePath ?? ""
            } else {
                self.arguments = self.configurations!.arguments4restore(index: index, argtype: .argdryRun)
            }
        } else {
            if tmprestore {
                self.arguments = self.configurations!.arguments4tmprestore(index: index, argtype: .arg)
                let lastindex = self.arguments!.count - 1
                self.arguments![lastindex] = ViewControllerReference.shared.restorePath ?? ""
            } else {
                self.arguments = self.configurations!.arguments4restore(index: index, argtype: .arg)
            }
        }
        guard arguments != nil else { return }
        let process = Rsync(arguments: self.arguments)
        process.executeProcess(outputprocess: outputprocess)
        taskDelegate?.getProcessReference(process: process.getProcess()!)
    }
}
