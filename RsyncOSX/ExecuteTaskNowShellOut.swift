//
//  ExecuteTaskNowShellOut.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import ShellOut

final class ExecuteTaskNowShellOut: ExecuteTaskNow {
    var error: Bool = false

    func executepretask() throws {
        if let index = self.index {
            if let pretask = configurations?.getConfigurations()?[index].pretask {
                let task = try shellOut(to: pretask)
                if task.contains("error"), (configurations?.getConfigurations()?[index].haltshelltasksonerror ?? 0) == 1 {
                    let outputprocess = OutputfromProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: pretask containes error, aborting")
                    _ = Logfile(TrimTwo(outputprocess.getOutput() ?? []).trimmeddata, true)
                    error = true
                }
            }
        }
    }

    func executeposttask() throws {
        if let index = self.index {
            if let posttask = configurations?.getConfigurations()?[index].posttask {
                let task = try shellOut(to: posttask)
                if task.contains("error"), (configurations?.getConfigurations()?[index].haltshelltasksonerror ?? 0) == 1 {
                    let outputprocess = OutputfromProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: posstak containes error")
                    _ = Logfile(TrimTwo(outputprocess.getOutput() ?? []).trimmeddata, true)
                }
            }
        }
    }

    override func executetasknow() {
        if let index = self.index {
            // Execute pretask
            if configurations?.getConfigurations()?[index].executepretask == 1 {
                do {
                    try executepretask()
                } catch let e {
                    let error = e as? ShellOutError
                    let outputprocess = OutputfromProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: pretask fault, aborting")
                    outputprocess.addlinefromoutput(str: error?.message ?? "")
                    _ = Logfile(TrimTwo(outputprocess.getOutput() ?? []).trimmeddata, true)
                    self.error = true
                }
            }

            guard error == false else { return }
            outputprocess = OutputfromProcessRsync()
            if let hiddenID = configurations?.gethiddenID(index: index) {
                if let arguments = configurations?.arguments4rsync(hiddenID: hiddenID, argtype: .arg) {
                    let process = RsyncProcess(arguments: arguments,
                                               config: configurations?.getConfigurations()?[index],
                                               processtermination: processtermination,
                                               filehandler: filehandler)
                    process.executeProcess(outputprocess: outputprocess)
                    startstopindicators?.startIndicatorExecuteTaskNow()
                    setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
                }
            }
        }
    }

    deinit {
        // Execute posttask
        guard self.error == false else { return }
        if let index = self.index {
            if self.configurations?.getConfigurations()?[index].executeposttask == 1 {
                do {
                    try self.executeposttask()
                } catch let e {
                    let error = e as? ShellOutError
                    let outputprocess = OutputfromProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: posttask fault")
                    outputprocess.addlinefromoutput(str: error?.message ?? "")
                    _ = Logfile(TrimTwo(outputprocess.getOutput() ?? []).trimmeddata, true)
                }
            }
        }
    }
}
