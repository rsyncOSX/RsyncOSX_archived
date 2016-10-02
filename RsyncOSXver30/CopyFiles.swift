//
//  CopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class CopyFiles {
    
    // Index from View
    private var index:Int?
    // stack of Work
    private var work:[enumscpTasks]?
    // Setting the configuration element according to index
    private var config:configuration?
    // when files.txt is copied from remote server get the records
    private var files:[String]?
    // Arguments and command for Process object
    var arguments:[String]?
    var command:String?
    // The arguments object
    var argumentsObject:scpNSTaskArguments?
    // Message to calling class do a refresh
    weak var refreshtable_delegate:RefreshtableViewtabMain?
    // Command real run - for the copy process (by rsync)
    private var argumentsRsync:[String]?
    // Command dry-run - for the copy process (by rsync)
    private var argymentsRsyncDrynRun:[String]?
    // String to display in view
    private var commandDisplay:String?
    // Start and stop progress view
    weak var progress_delegate: StartStopProgressIndicatorViewBatch?
    // The Process object
    var task:rsyncProcess?
    // rsync outPut object
    var output:outputProcess?
    
    
    // Get output from Rsync
    func getOutput() -> NSMutableArray {
        return self.output!.getOutput()
    }
    
    // Estimate run
    func estimate(remotefile:String, localCatalog:String) {
        self.argumentsObject = scpNSTaskArguments(task: .copy, config: self.config!, remoteFile: remotefile, localCatalog: localCatalog, drynrun: true)
        self.arguments = self.argumentsObject!.getArgs()
        self.command = nil
        self.task = rsyncProcess(notification: false, tabMain: false, command : nil)
        self.output = outputProcess()
        self.task!.executeProcess(self.arguments!, output: self.output!)
    }
    
    // Execute run
    func execute(remotefile:String, localCatalog:String) {
        self.argumentsObject = scpNSTaskArguments(task: .copy, config: self.config!, remoteFile: remotefile, localCatalog: localCatalog, drynrun: nil)
        self.arguments = self.argumentsObject!.getArgs()
        self.command = nil
        self.task = rsyncProcess(notification: false, tabMain: false, command : nil)
        self.output = outputProcess()
        self.task!.executeProcess(self.arguments!, output: self.output!)
    }
    
    // Get arguments for rsync to show
    func getCommandDisplayinView(remotefile:String, localCatalog:String) -> String? {
        self.commandDisplay = scpNSTaskArguments(task: .copy, config: self.config!, remoteFile: remotefile, localCatalog: localCatalog, drynrun: true).getcommandDisplay()
        return self.commandDisplay
    }
    
    // As soon as we get the termination message kick of 
    // the next work. Work is first ssh and then scp
    func nextWork() {
        self.doWork()
    }
    
    // The work stack.
    // This is the iniatil work when selecting a row to restore from.
    // The stack is .create and .scpFind
    private func doWork() {
        if (self.work != nil) {
            if (self.work!.count > 0) {
                let work:enumscpTasks = (self.work?.removeFirst())!
                self.argumentsObject = scpNSTaskArguments(task: work, config: self.config!, remoteFile: nil, localCatalog: nil, drynrun: nil)
                self.arguments = self.argumentsObject!.getArgs()
                self.command = self.argumentsObject!.getCommand()
                self.command = self.argumentsObject!.getCommand()
                self.task = rsyncProcess(notification: false, tabMain: false, command : self.command)
                self.output = outputProcess()
                self.task!.executeProcess(self.arguments!, output: self.output!)
                
            } else {
                // Files.txt are ready to read
                self.files = self.argumentsObject?.getSearchfile()
                if let pvc = SharingManagerConfiguration.sharedInstance.CopyObjectMain as? ViewControllerCopyFiles {
                    self.progress_delegate = pvc
                    self.refreshtable_delegate = pvc
                    self.refreshtable_delegate?.refreshInMain()
                    self.progress_delegate?.stop()
                }
            }
        }
    }
    // Filter function
    func filter(search:String?) -> [String] {
        if (search != nil) {
            if (search!.isEmpty == false) {
                // Filter data
                return self.files!.filter({$0.contains(search!)})
            } else {
                return self.files!
            }
        } else {
            if (self.files != nil) {
               return self.files!
            }
            return [""]
        }
    }
    
    
    init (index:Int) {
        // Setting index and configuration object
        self.index = index
        self.config = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!]
        // Create inital stack of work
        self.work = [enumscpTasks]()
        // Append workload in reverse order
        // Work are poped of top of stack
        self.work!.append(.create)
        self.work!.append(.scpFind)
        // Do first part of job
        self.doWork()
    }
    
  }

