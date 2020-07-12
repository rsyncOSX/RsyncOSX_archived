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
    func executepre() {
        do {
            try shellOut(to: "totally-invalid-pre")
        } catch {
            let error = error as? ShellOutError
            let outputprocess = OutputProcess()
            outputprocess.addlinefromoutput(str: "ShellOut error")
            outputprocess.addlinefromoutput(str: error?.message ?? "")
            _ = Logging(outputprocess, true)
        }
    }

    func executepost() {
        do {
            try shellOut(to: "totally-invalid-post")
        } catch {
            let error = error as? ShellOutError
            let outputprocess = OutputProcess()
            outputprocess.addlinefromoutput(str: "ShellOut error")
            outputprocess.addlinefromoutput(str: error?.message ?? "")
            _ = Logging(outputprocess, true)
        }
    }

    override func executetasknow() {
        if let index = self.index {
            self.executepre()
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
        self.executepost()
    }
}
