//
//  rsyncProcess.swift
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class RsyncProcess {
    
    // Number of calculated files to be copied
    var calculatedNumberOfFiles:Int = 0
    // Variable for reference to NSTask
    var ProcessReference:Process?
    // Message to calling class
    weak var process_update:UpdateProgress?
    // If process is created in NSOperation
    var inOperation:Bool?
    // Creating obcect from tabMain
    var tabMain:Bool?
    // Observer
    weak var observationCenter: NSObjectProtocol?
    // Command to be executed, normally rsync
    var command:String?
        
    func executeProcess (_ arg: [String], output:outputProcess){
        // Task
        let task = Process()
        // Setting the correct path for rsync
        // If self.command != nil other command than rsync to be executed
        // Other commands are either ssh or scp (from CopyFiles)
        if let command = self.command {
            task.launchPath = command
        } else {
            task.launchPath = SharingManagerConfiguration.sharedInstance.setRsyncCommand()
        }
        task.arguments = arg
        // Pipe for reading output from NSTask
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        // Observator for reading data from pipe
        // Observer is removed when Process terminates
        self.observationCenter = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: nil, queue: nil)
            { notification -> Void in
                let data = outHandle.availableData
                if data.count > 0 {
                    if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        // Add files to be copied, the output.addString takes care of 
                        // splitting the output
                        output.addLine(str as String)
                        self.calculatedNumberOfFiles = output.getOutputCount()
                        if (self.inOperation == false) {
                            // Send message about files
                            self.process_update?.FileHandler()
                        }
                    }
                    outHandle.waitForDataInBackgroundAndNotify()
                }
            }
        // Observator Process termination
        // Observer is removed when Process terminates
        self.observationCenter = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: task, queue: nil)
            { notification -> Void in
                // Collectiong numbers in output
                // Forcing a --stats in dryrun which produces a summarized detail about
                // files and bytes. getNumbers collects that info and store the result in the
                // object.
                output.getNumbers()
                if (self.inOperation == false) {
                    // Send message about process termination
                    self.process_update?.ProcessTermination()
                } else {
                    // We are in Scheduled operation and must finalize the job
                    // e.g logging date and stuff like that
                    SharingManagerConfiguration.sharedInstance.operation?.finalizeScheduledJob(output: output)
                    // After logging is done set reference to object = nil
                    SharingManagerConfiguration.sharedInstance.operation = nil
                }
                NotificationCenter.default.removeObserver(self.observationCenter as Any)
            }
        self.ProcessReference = task
        task.launch()
    }
    
    func getProcess() -> Process? {
        return self.ProcessReference
    }
    
    func abortProcess() {
        if self.ProcessReference != nil {
            self.ProcessReference!.terminate()
        }
    }
    
    init (operation: Bool, tabMain:Bool, command : String?) {
        
        self.inOperation = operation
        self.tabMain = tabMain
        self.command = command
        
        // If process object is created from a scheduled task do not set delegates.
        if (self.inOperation == false) {
            // Check where to return the delegate call
            // Either in ViewControllertabMain or ViewControllerCopyFiles
            switch tabMain {
            case true:
                if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                    self.process_update = pvc
                }
            case false:
                if let pvc = SharingManagerConfiguration.sharedInstance.CopyObjectMain as? ViewControllerCopyFiles {
                    self.process_update = pvc
                }
            }
        }
    }
    
}
