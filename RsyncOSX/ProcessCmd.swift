//
//  processCmd.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

protocol ErrorOutput: AnyObject {
    func erroroutput()
}

protocol DisableEnablePopupSelectProfile: AnyObject {
    func disableselectpopupprofile()
    func enableselectpopupprofile()
}

class ProcessCmd: Delay {
    // Message to calling class
    weak var updateDelegate: UpdateProgress?
    // Observers
    weak var notifications_datahandle: NSObjectProtocol?
    weak var notifications_termination: NSObjectProtocol?
    // Command to be executed, normally rsync
    var command: String?
    // Arguments to command
    var arguments: [String]?
    // true if processtermination
    var termination: Bool = false
    // possible error ouput
    weak var possibleerrorDelegate: ErrorOutput?
    // Enable and disable select profile
    weak var profilepopupDelegate: DisableEnablePopupSelectProfile?

    func setupdateDelegate(object: UpdateProgress) {
        self.updateDelegate = object
    }

    func executeProcess(outputprocess: OutputProcess?) {
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
                // Enable select profile
                self.profilepopupDelegate?.enableselectpopupprofile()
            }
        }
        ViewControllerReference.shared.process = task
        self.profilepopupDelegate?.disableselectpopupprofile()
        if #available(OSX 10.13, *) {
            do {
                try task.run()
            } catch let e {
                let error = e as NSError
                let outputprocess = OutputProcess()
                outputprocess.addlinefromoutput(str: error.description)
                _ = Logging(outputprocess, true)
            }
        } else {
            task.launch()
        }
    }

    // Terminate Process, used when user Aborts task.
    func abortProcess() {
        _ = InterruptProcess()
    }

    init(command: String?, arguments: [String]?) {
        self.command = command
        self.arguments = arguments
        self.possibleerrorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.profilepopupDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }
}
