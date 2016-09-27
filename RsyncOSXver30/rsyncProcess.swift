//
//  rsyncNSTask.swift
//  Rsync
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class rsyncProcess {
    
    // Number of calculated files to be copied
    var calculatedNumberOfFiles:Int = 0
    // Variable for reference to NSTask
    var ProcessReference:Process?
    // Message to calling class
    weak var process_update:UpdateProgress?
    // If process is created in NSOperation
    var inNSOperation:Bool?
    // Observer
    weak var observationCenter: NSObjectProtocol?
        
    func executeProcess (_ arg: [String], output:outputProcess){
        // Task
        let task = Process()
        // Setting the correct path for rsync
        task.launchPath = SharingManagerConfiguration.sharedInstance.setRsyncCommand()
        task.arguments = arg
        // Pipe for reading output from NSTask
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        // Observator for reading data from pipe
        self.observationCenter = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: nil, queue: nil)
            { notification -> Void in
                let data = outHandle.availableData
                if data.count > 0 {
                    if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        // Add files to be copied, the output.addString takes care of 
                        // splitting the output
                        output.addLine(str as String)
                        self.calculatedNumberOfFiles = output.getOutputCount()
                        if (self.inNSOperation == false) {
                            // Send message about files
                            self.process_update?.FileHandler()
                        }
                    }
                    outHandle.waitForDataInBackgroundAndNotify()
                }
            }
        // Observator NSTask termination
        self.observationCenter = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: task, queue: nil)
            { notification -> Void in
                if (self.inNSOperation == false) {
                    // Send message about process termination
                    self.process_update?.ProcessTermination()
                }
                NotificationCenter.default.removeObserver(self.observationCenter)
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
    
    init (notification: Bool) {
        
        self.inNSOperation = notification
        
        if (self.inNSOperation == false) {
            if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                self.process_update = pvc
            }
        }
    }
    
}
