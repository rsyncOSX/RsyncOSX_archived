//
//  RsyncProcess.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 14/09/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Combine
import Foundation

protocol ErrorOutput: AnyObject {
    func erroroutput()
}

protocol DisableEnablePopupSelectProfile: AnyObject {
    func disableselectpopupprofile()
    func enableselectpopupprofile()
}

final class RsyncProcess: Errors {
    // Combine subscribers
    var subscriptons = Set<AnyCancellable>()
    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void
    var monitor: NetworkMonitor?
    // Arguments to command
    var arguments: [String]?
    // Enable and disable select profile
    weak var profilepopupDelegate: DisableEnablePopupSelectProfile?

    func executemonitornetworkconnection(config: Configuration?) {
        guard config?.offsiteServer.isEmpty == false else { return }
        guard SharedReference.shared.monitornetworkconnection == true else { return }
        monitor = NetworkMonitor()
        monitor?.netStatusChangeHandler = { [unowned self] in
            do {
                try statusDidChange()
            } catch let e {
                let error = e as NSError
                let outputprocess = OutputfromProcess()
                outputprocess.addlinefromoutput(str: error.description)
                _ = Logfile(TrimTwo(outputprocess.getOutput() ?? []).trimmeddata, error: false)
            }
        }
    }

    // Throws error
    func statusDidChange() throws {
        if monitor?.monitor?.currentPath.status != .satisfied {
            let output = OutputfromProcess()
            let string = NSLocalizedString("Network connection is dropped", comment: "network") + ":"
                + Date().long_localized_string_from_date()
            output.addlinefromoutput(str: string)
            _ = InterruptProcess()
            throw Networkerror.networkdropped
        }
    }

    func executeProcess(outputprocess: OutputfromProcess?) {
        // Must check valid rsync exists
        guard SharedReference.shared.norsync == false else { return }
        // Process
        let task = Process()
        // Getting version of rsync
        task.launchPath = Getrsyncpath().rsyncpath
        task.arguments = arguments
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
        // Combine, subscribe to NSNotification.Name.NSFileHandleDataAvailable
        NotificationCenter.default.publisher(
            for: NSNotification.Name.NSFileHandleDataAvailable)
            .sink { _ in
                let data = outHandle.availableData
                if data.count > 0 {
                    if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        outputprocess?.addlinefromoutput(str: str as String)
                        self.filehandler()
                    }
                    outHandle.waitForDataInBackgroundAndNotify()
                }
            }.store(in: &subscriptons)
        // Combine, subscribe to Process.didTerminateNotification
        NotificationCenter.default.publisher(
            for: Process.didTerminateNotification)
            .debounce(for: .milliseconds(500), scheduler: globalMainQueue)
            .sink { [self] _ in
                self.processtermination()
                // Logg to file
                _ = Logfile(TrimTwo(outputprocess?.getOutput() ?? []).trimmeddata, error: false)
                // Release Combine subscribers
                subscriptons.removeAll()
            }.store(in: &subscriptons)
        profilepopupDelegate?.disableselectpopupprofile()
        SharedReference.shared.process = task
        do {
            try task.run()
        } catch let e {
            let error = e as NSError
            self.error(errordescription: error.localizedDescription, errortype: .task)
        }
    }

    init(arguments: [String]?,
         config: Configuration?,
         processtermination: @escaping () -> Void,
         filehandler: @escaping () -> Void)
    {
        self.arguments = arguments
        self.processtermination = processtermination
        self.filehandler = filehandler
        executemonitornetworkconnection(config: config)
        profilepopupDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    deinit {
        self.monitor?.stopMonitoring()
        self.monitor = nil
        SharedReference.shared.process = nil
        // Enable select profile
        self.profilepopupDelegate?.enableselectpopupprofile()
    }
}
