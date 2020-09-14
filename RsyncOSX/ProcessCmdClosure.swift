//
//  ProcessCmdClosure.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 14/09/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

class ProcessCmdClosure: Delay {
    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void
    // Verify network connection
    var config: Configuration?
    var monitor: NetworkMonitor?
    // Observers
    weak var notifications_datahandle: NSObjectProtocol?
    weak var notifications_termination: NSObjectProtocol?
    // Arguments to command
    var arguments: [String]?
    // true if processtermination
    var termination: Bool = false
    // possible error ouput
    weak var possibleerrorDelegate: ErrorOutput?
    // Enable and disable select profile
    weak var profilepopupDelegate: DisableEnablePopupSelectProfile?

    func executemonitornetworkconnection() {
        // guard self.arguments?.contains("--dry-run") ?? false == false else { return }
        guard self.config?.offsiteServer.isEmpty == false else { return }
        guard ViewControllerReference.shared.monitornetworkconnection == true else { return }
        self.monitor = NetworkMonitor()
        self.monitor?.netStatusChangeHandler = { [unowned self] in
            self.statusDidChange()
        }
    }

    func statusDidChange() {
        if self.monitor?.monitor?.currentPath.status != .satisfied {
            let output = OutputProcess()
            let string = "Network dropped: " + Date().long_localized_string_from_date()
            output.addlinefromoutput(str: string)
            _ = InterruptProcess(output: output)
        }
    }

    func executeProcess(outputprocess: OutputProcess?) {
        // Process
        let task = Process()
        // Getting version of rsync
        task.launchPath = Getrsyncpath().rsyncpath
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
                    self?.filehandler()
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
                self.processtermination()
                // Must remove for deallocation
                NotificationCenter.default.removeObserver(self.notifications_datahandle as Any)
                NotificationCenter.default.removeObserver(self.notifications_termination as Any)
                // Enable select profile
                self.profilepopupDelegate?.enableselectpopupprofile()
            }
        }
        ViewControllerReference.shared.process = task
        self.profilepopupDelegate?.disableselectpopupprofile()
        do {
            try task.run()
        } catch let e {
            let error = e as NSError
            let outputprocess = OutputProcess()
            outputprocess.addlinefromoutput(str: error.description)
            _ = Logging(outputprocess, true)
        }
    }

    // Terminate Process, used when user Aborts task.
    func abortProcess() {
        _ = InterruptProcess()
    }

    init(arguments: [String]?, config: Configuration?, processtermination: @escaping () -> Void, filehandler: @escaping () -> Void) {
        self.arguments = arguments
        self.processtermination = processtermination
        self.filehandler = filehandler
        self.config = config
        self.executemonitornetworkconnection()
        self.possibleerrorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.profilepopupDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    deinit {
        self.monitor?.stopMonitoring()
        self.monitor = nil
        print("stop monitoring ProcessCmdClosure")
    }
}
