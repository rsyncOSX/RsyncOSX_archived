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
    var pretask: String?
    var posttask: String?
    var error: Bool = false

    func executepretask() {
        if let index = self.index {
            if let pretask = self.configurations?.getConfigurations()[index].pretask {
                let pipe = Pipe()
                do {
                    try shellOut(to: pretask, errorHandle: pipe.fileHandleForWriting)
                    _ = LoggOutputfromPipe(pipe: pipe)
                } catch {
                    let error = error as? ShellOutError
                    let outputprocess = OutputProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut error")
                    outputprocess.addlinefromoutput(str: error?.message ?? "")
                    _ = Logging(outputprocess, true)
                    self.error = true
                }
            }
        }
    }

    func executeposttask() {
        if let index = self.index {
            if let posttask = self.configurations?.getConfigurations()[index].posttask {
                let pipe = Pipe()
                do {
                    try shellOut(to: posttask, errorHandle: pipe.fileHandleForWriting)
                    _ = LoggOutputfromPipe(pipe: pipe)
                } catch {
                    let error = error as? ShellOutError
                    let outputprocess = OutputProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut error")
                    outputprocess.addlinefromoutput(str: error?.message ?? "")
                    _ = Logging(outputprocess, true)
                }
            }
        }
    }

    override func executetasknow() {
        if let index = self.index {
            // Execute pretask
            self.executepretask()
            guard self.error == false else { return }
            self.outputprocess = OutputProcessRsync()
            if let arguments = self.configurations?.arguments4rsync(index: index, argtype: .arg) {
                if #available(OSX 10.14, *) {
                    let process = RsyncVerify(arguments: arguments, config: (self.configurations?.getConfigurations()[index])!)
                    process.setdelegate(object: self)
                    process.executeProcess(outputprocess: self.outputprocess)
                    self.startstopindicators?.startIndicatorExecuteTaskNow()
                    self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
                } else {
                    let process = Rsync(arguments: arguments)
                    process.setdelegate(object: self)
                    process.executeProcess(outputprocess: self.outputprocess)
                    self.startstopindicators?.startIndicatorExecuteTaskNow()
                    self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
                }
            }
        }
    }

    deinit {
        // Execute posttask
        guard self.error == false else { return }
        self.executeposttask()
    }
}
