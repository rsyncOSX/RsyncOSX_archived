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

    func executepretask() async throws {
        if let index = index {
            if let pretask = configurations?.getConfigurations()?[index].pretask {
                do {
                    try await shellOut(to: pretask)
                } catch {
                    let outputprocess = OutputfromProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: execute pretask failed")
                    _ = Logfile(TrimTwo(outputprocess.getOutput() ?? []).trimmeddata, error: true)
                }
            }
        }
    }

    func executeposttask() async throws {
        if let index = index {
            if let posttask = configurations?.getConfigurations()?[index].posttask {
                do {
                    try await shellOut(to: posttask)
                } catch {
                    let outputprocess = OutputfromProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: execute posttask failed")
                    _ = Logfile(TrimTwo(outputprocess.getOutput() ?? []).trimmeddata, error: true)
                }
            }
        }
    }

    @MainActor
    override func executetasknow() async {
        if let index = index {
            // Execute pretask
            if configurations?.getConfigurations()?[index].executepretask == 1 {
                do {
                    try await executepretask()
                } catch let e {
                    let error = e as? ShellOutError
                    let outputprocess = OutputfromProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: pretask fault, aborting")
                    outputprocess.addlinefromoutput(str: error?.message ?? "")
                    _ = Logfile(TrimTwo(outputprocess.getOutput() ?? []).trimmeddata, error: true)
                    self.error = true
                }
            }

            guard error == false else { return }
            if let hiddenID = configurations?.gethiddenID(index: index) {
                if let arguments = configurations?.arguments4rsync(hiddenID: hiddenID, argtype: .arg) {
                    startstopindicators?.startIndicatorExecuteTaskNow()
                    let process = RsyncProcessAsync(arguments: arguments,
                                                    config: configurations?.getConfigurations()?[index],
                                                    processtermination: processtermination)
                    await process.executeProcess()
                }
            }
        }
    }

    override func processtermination(data: [String]?) {
        startstopindicators?.stopIndicator()
        if let index = index {
            configurations?.setCurrentDateonConfiguration(index: index, outputfromrsync: data)
        }
        deinitDelegate?.deinitexecutetasknow()
        command = nil
        presentoutputfromrsync(data: data)
        // Execute pretask
        if let index = index {
            if configurations?.getConfigurations()?[index].executeposttask == 1 {
                Task {
                    do {
                        try await executeposttask()
                    } catch let e {
                        let error = e as? ShellOutError
                        let outputprocess = OutputfromProcess()
                        outputprocess.addlinefromoutput(str: "ShellOut: pretask fault, aborting")
                        outputprocess.addlinefromoutput(str: error?.message ?? "")
                        _ = Logfile(TrimTwo(outputprocess.getOutput() ?? []).trimmeddata, error: true)
                        self.error = true
                    }
                }
            }
        }
    }
}
