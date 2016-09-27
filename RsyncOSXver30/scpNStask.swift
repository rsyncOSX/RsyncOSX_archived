//
//  scpNStask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/06/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class scpNStask {
    
    var output = [String]()
    
    // Function for executing /usr/bin/scp or /usr/bin/rsync, /usr/local/bin/rsync commands
    func executeNSTask (_ cmd : String, arg: [String]){
        // Task
        let task = Process()
        task.launchPath = cmd
        task.arguments = arg
        // Observators
        var obs : NSObjectProtocol!
        var obs1 : NSObjectProtocol!
        // Pipe
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        // Observator for reading data from pipe
        obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: nil, queue: nil)
        { notification -> Void in
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    self.addString(str as String)
                }
                outHandle.waitForDataInBackgroundAndNotify()
            }
        }
        // Observator NSTask termination
        obs = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: task, queue: nil)
        { notification in
            GlobalMainQueue.async(flags: .barrier, execute: {
                self.removeNSTask()
            }) 
            NotificationCenter.default.removeObserver(obs)
            NotificationCenter.default.removeObserver(obs1)
        }
        task.launch()
        self.addNSTask(task)
    }
    
    
    // Function for adding lines to output 
    // Counting files
    private func addString (_ str: String) {
        let sentence = str
        sentence.enumerateLines{
            line, stop in
            if line.characters.last != "/" {
                self.output.append(line as String)
            }
        }
    }
    
    // Returns number of files copied
    func count() -> Int {
        return self.output.count
    }
    
    // Used during initializing of Execute window. All NSTasks must be completed before any
    // calculations and/or backup tasks are started.
    
    func addNSTask(_ task:Process) {
        SharingManagerConfiguration.sharedInstance.count.append(task)
    }
    
    func removeNSTask() {
        if (SharingManagerConfiguration.sharedInstance.count.count > 0) {
            SharingManagerConfiguration.sharedInstance.count.removeLast()
        }
    }
    
    func countNSTask() -> Int {
        return SharingManagerConfiguration.sharedInstance.count.count
    }
    
    func emptyNSTask() {
        SharingManagerConfiguration.sharedInstance.count.removeAll()
    }
    
    func killTask() {
        if self.countNSTask() > 0 {
            let task = SharingManagerConfiguration.sharedInstance.count[self.countNSTask() - 1]
            task.terminate()
        }
    }
}
