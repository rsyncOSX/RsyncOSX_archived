//
//  ProcessCmdVerify.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/06/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Network

@available(OSX 10.14, *)
class ProcessCmdVerify: ProcessCmd {
    var config: Configuration?
    var monitor: NetworkMonitor?

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
                // Must remove for deallocation
                NotificationCenter.default.removeObserver(self.notifications_datahandle as Any)
                NotificationCenter.default.removeObserver(self.notifications_termination as Any)
            }
        }
        self.processReference = task
        task.launch()
    }

    func executecontinuislycheckforconnected() {
        // guard self.arguments?.contains("--dry-run") ?? false == false else { return }
        guard self.config?.offsiteServer.isEmpty == false else { return }
        guard ViewControllerReference.shared.executecontinuislycheckforconnected == true else { return }
        self.monitor = NetworkMonitor()
        self.monitor?.netStatusChangeHandler = { [unowned self] in
            self.statusDidChange()
        }
    }

    func statusDidChange() {
        if self.monitor?.monitor?.currentPath.status != .satisfied {
            _ = InterruptProcess(process: self.processReference)
        }
    }

    init(command: String?, arguments: [String]?, config: Configuration?) {
        super.init(command: command, arguments: arguments)
        self.config = config
        self.executecontinuislycheckforconnected()
    }

    deinit {
        self.monitor?.stopMonitoring()
        self.monitor = nil
    }
}
