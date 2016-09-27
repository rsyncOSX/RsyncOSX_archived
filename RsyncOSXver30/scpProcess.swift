//
//  scpNStask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/06/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class scpProcess {
    
    // var output = [String]()
    var output = NSMutableArray()
    // Observer
    weak var observationCenter: NSObjectProtocol?
    // Message to calling class
    weak var processupdate_delegate:UpdateProgress?
    
    // Function for executing /usr/bin/scp or /usr/bin/rsync, /usr/local/bin/rsync commands
    func executeProcess (_ cmd : String, args: [String]){
        // Task
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
 
        // Pipe
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
                    self.addString(str as String)
                }
                // Send message about files
                self.processupdate_delegate?.FileHandler()
                outHandle.waitForDataInBackgroundAndNotify()
            }
        }
        // Observator NSTask termination
        self.observationCenter = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: task, queue: nil)
        { notification in
            NotificationCenter.default.removeObserver(self.observationCenter)
            // Send message about process termination
            self.processupdate_delegate?.ProcessTermination()
        }
        task.launch()
    }
    
    
    // Function for adding lines to output 
    // Counting files
    private func addString (_ str: String) {
        let sentence = str
        sentence.enumerateLines{
            line, stop in
            if line.characters.last != "/" {
                self.output.add(line as String)
            }
        }
    }
    
    func getOutput() -> NSMutableArray {
        return self.output
    }
    
    // Returns number of files copied
    func count() -> Int {
        return self.output.count
    }
    
    init () {
        if let pvc = SharingManagerConfiguration.sharedInstance.CopyObjectMain as? ViewControllerCopyFiles {
            self.processupdate_delegate = pvc
        }
    }
 }
