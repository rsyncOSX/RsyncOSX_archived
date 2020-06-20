//
//  ProcessCmdVerify.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/06/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

class ProcessCmdVerify: ProcessCmd, Connected {
    // A Timer object to continusly check process is alive
    var continuislycheckforalive: Timer?
    var previousnumberofoutput: Int?
    var outputprocessverifyrsync: OutputProcess?
    var config: Configuration?

    override func executeProcess(outputprocess: OutputProcess?) {
        // Process
        let task = Process()
        // If self.command != nil either alternativ path for rsync or other command than rsync to be executed
        if let command = self.command {
            task.launchPath = command
        } else {
            task.launchPath = Getrsyncpath().rsyncpath
        }
        task.arguments = self.arguments
        // If there are any Environmentvariables like
        // SSH_AUTH_SOCK": "/Users/user/.gnupg/S.gpg-agent.ssh"
        if let environment = Environment() {
            task.environment = environment.environment
        }
        // Pipe for reading output from Process
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        // Observator for reading data from pipe, observer is removed when Process terminates
        self.notifications_datahandle = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: nil, queue: nil) { [weak self] _ in
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    outputprocess?.addlinefromoutput(str: str as String)
                    // Send message about files
                    self?.updateDelegate?.fileHandler()
                    if self?.termination ?? false {
                        self?.possibleerrorDelegate?.erroroutput()
                    }
                }
                outHandle.waitForDataInBackgroundAndNotify()
            }
        }
        // Observator Process termination, observer is removed when Process terminates
        self.notifications_termination = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: nil, queue: nil) { _ in
            self.delayWithSeconds(0.5) {
                self.termination = true
                self.updateDelegate?.processTermination()
                // Deallocate the Timer object
                self.continuislycheckforalive?.invalidate()
                // Must remove for deallocation
                NotificationCenter.default.removeObserver(self.notifications_datahandle as Any)
                NotificationCenter.default.removeObserver(self.notifications_termination as Any)
            }
        }
        self.processReference = task
        task.launch()
        // Create the Timer object for verifying the process object is alive
        if self.executecontinuislycheckforconnected() {
            self.continuislycheckforalive = Timer.scheduledTimer(timeInterval: ViewControllerReference.shared.timerexecutecontinuislycheckforalive, target: self, selector: #selector(self.verifystillconnected), userInfo: nil, repeats: true)
        }
        self.outputprocessverifyrsync = outputprocess
    }

    @objc func verifystillconnected() {
        // print("verify")
        if let config = self.config {
            if connected(config: config) == false {
                let question: String = NSLocalizedString("Seems like rsync is not responding?", comment: "Process")
                let text: String = NSLocalizedString("Interrupt rsync?", comment: "Process")
                let dialog: String = NSLocalizedString("Interrupt", comment: "Process")
                let yes = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
                if yes {
                    _ = InterruptProcess(process: self.processReference)
                }
            }
        }
    }

    func executecontinuislycheckforconnected() -> Bool {
        guard self.arguments?.contains("--dry-run") ?? false == false else { return false }
        guard self.config?.offsiteServer.isEmpty == false else { return false }
        guard ViewControllerReference.shared.executecontinuislycheckforalive == true else { return false }
        return true
    }

    init(command: String?, arguments: [String]?, config: Configuration?) {
        super.init(command: command, arguments: arguments)
        self.config = config
    }
}
