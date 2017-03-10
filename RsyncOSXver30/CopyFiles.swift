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
    private var work:Array<enumscopyfiles>?
    // Setting the configuration element according to index
    private var config:configuration?
    // when files.txt is copied from remote server get the records
    private var files:Array<String>?
    // Arguments and command for Process object
    private var arguments:Array<String>?
    private var command:String?
    // The arguments object
    var argumentsObject:scpProcessArguments?
    // Message to calling class do a refresh
    weak var refreshtable_delegate:RefreshtableView?
    // Command real run - for the copy process (by rsync)
    private var argumentsRsync:Array<String>?
    // Command dry-run - for the copy process (by rsync)
    private var argymentsRsyncDrynRun:Array<String>?
    // String to display in view
    private var commandDisplay:String?
    // Start and stop progress view
    weak var progress_delegate: StartStopProgressIndicator?
    // The Process object
    var task:RsyncProcess?
    // rsync outPut object
    var output:outputProcess?
    
    
    // Get output from Rsync
    func getOutput() -> Array<String> {
        return self.output!.getOutput()
    }
    
    // Abort operation, terminate process
    func Abort() {
        guard self.task != nil else {
            return
        }
        self.task!.abortProcess()
    }
    
    // Execute Process (either dryrun or realrun)
    func executeRsync(remotefile:String, localCatalog:String, dryrun:Bool) {
        if(dryrun) {
            self.argumentsObject = scpProcessArguments(task: .rsync, config: self.config!, remoteFile: remotefile, localCatalog: localCatalog, drynrun: true)
            self.arguments = self.argumentsObject!.getArguments()
        } else {
            self.argumentsObject = scpProcessArguments(task: .rsync, config: self.config!, remoteFile: remotefile, localCatalog: localCatalog, drynrun: nil)
            self.arguments = self.argumentsObject!.getArguments()
        }
        self.command = nil
        self.output = nil
        self.task = RsyncProcess(operation: false, tabMain: false, command : nil)
        self.output = outputProcess()
        self.task!.executeProcess(self.arguments!, output: self.output!)
    }
    
    // Get arguments for rsync to show
    func getCommandDisplayinView(remotefile:String, localCatalog:String) -> String {
        self.commandDisplay = scpProcessArguments(task: .rsync, config: self.config!, remoteFile: remotefile, localCatalog: localCatalog, drynrun: true).getcommandDisplay()
        guard self.commandDisplay != nil else {
            return ""
        }
        return self.commandDisplay!
    }
    
    // As soon as we get the termination message kick of 
    // the next work. Work is first ssh and then scp
    func nextWork() {
        self.doWork()
    }
    
    // The work stack.
    // This is the initial work when selecting a row to restore from.
    // The stack is .create and .scp
    private func doWork() {
        
        guard (self.work != nil) else {
            return
        }
        
        if (self.work!.count > 0) {
            self.output = nil
            let work:enumscopyfiles = self.work!.removeFirst()
            self.argumentsObject = scpProcessArguments(task: work, config: self.config!, remoteFile: nil, localCatalog: nil, drynrun: nil)
            self.arguments = self.argumentsObject!.getArguments()
            self.command = self.argumentsObject!.getCommand()
            self.task = RsyncProcess(operation: false, tabMain: false, command : self.command)
            self.output = outputProcess()
            self.task!.executeProcess(self.arguments!, output: self.output!)
        } else {
            // Files.txt are ready to read
            self.files = self.argumentsObject!.getSearchfile()
            if let pvc = SharingManagerConfiguration.sharedInstance.CopyObjectMain as? ViewControllerCopyFiles {
                self.progress_delegate = pvc
                self.refreshtable_delegate = pvc
                self.refreshtable_delegate?.refresh()
                self.progress_delegate?.stop()
            }
        }
    }
    
    // Filter function
    func filter(search:String?) -> Array<String> {
        
        guard search != nil else {
            if (self.files != nil) {
                return self.files!
            } else {
              return [""]
            }
            
        }
        
        if (search!.isEmpty == false) {
            // Filter data
            return self.files!.filter({$0.contains(search!)})
        } else {
            return self.files!
        }
    }
    
    
    init (index:Int) {
        // Setting index and configuration object
        self.index = index
        self.config = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!]
        // Create inital stack of work
        self.work = Array<enumscopyfiles>()
        // Work are poped of top of stack
        self.work!.append(.create)
        self.work!.append(.scp)
        // Do first part of job
        self.doWork()
    }
    
  }

