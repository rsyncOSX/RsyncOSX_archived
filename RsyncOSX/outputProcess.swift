//
//  outputProcess.swift
//
//  Created by Thomas Evensen on 11/01/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

protocol RsyncError: class {
    func rsyncerror()
}

// enum for returning what is asked for
enum enumNumbers {
    case totalNumber
    case totalDirs
    case totalNumberSizebytes
    case transferredNumber
    case transferredNumberSizebytes
    case new
    case delete
}


final class outputProcess {
    
    // Second last String in Array rsync output of how much in what time
    private var resultRsync:String?
    // calculated number of files
    // set from rsync
    private var calculatedNumberOfFiles:Int?
    // output Array to keep output from rsync in
    private var output:Array<String>?
    // output Array temporary indexes
    private var startIndex:Int?
    private var endIndex:Int?
    // numbers after dryrun and stats
    /*
    private var totalNumber:Int?
    private var totalDirs:Int?
    private var totalNumberSizebytes:Double?
    private var transferredNumber:Int?
    private var transferredNumberSizebytes:Double?
    private var newfiles:Int?
    private var deletefiles:Int?
    */
    // Maxnumber
    private var maxNumber:Int = 0
    
    
    // Error delegate
    weak var error_delegate:ViewControllertabMain?
    // Last record of rsync 
    weak var lastrecord_delegate:ViewControllertabMain?
    
    func getMaxcount() -> Int {
        return self.maxNumber
    }
    
    func getOutputCount () -> Int {
        guard (self.output != nil) else {
            return 0
        }
        return self.output!.count
    }
    
    func getOutput () -> Array<String> {
        guard (self.output != nil) else {
            return [""]
        }
        return self.output!
    }
    
    // Return end message of Rsync
    func endMessage() -> String {
        if let message = self.resultRsync {
            return message
        } else {
            return ""
        }
    }
    
    // Add line to output
    func addLine (_ str: String) {
        let sentence = str
        
        if (self.startIndex == nil) {
            self.startIndex = 0
        } else {
            self.startIndex = self.getOutputCount()+1
        }
        sentence.enumerateLines { (line, _) in
            if line.characters.last != "/" {
                self.output!.append(line)
            }
        }
        self.endIndex = self.output!.count
        // Set maxnumber so far
        self.maxNumber = self.endIndex!
        
        if (self.endIndex! > 2) {
            self.resultRsync = (self.output![self.endIndex!-2])
        }
        // rsync error
        let error = sentence.contains("rsync error:")
        // There is an error in transferring files
        // We only informs in main view if error
        if error {
            if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain {
                self.error_delegate = pvc as? ViewControllertabMain
                self.error_delegate?.rsyncerror()
            }
        }
    }
    
    // Add line to output
    func addLine2 (_ str: String) {
        let sentence = str
        
        if (self.startIndex == nil) {
            self.startIndex = 0
        } else {
            self.startIndex = self.getOutputCount()+1
        }
        sentence.enumerateLines { (line, _) in
            self.output!.append(line)
        }
        
        self.endIndex = self.output!.count
        // Set maxnumber so far
        self.maxNumber = self.endIndex!
        
        if (self.endIndex! > 2) {
            self.resultRsync = (self.output![self.endIndex!-2])
        }
    }

    
    // Get numbers from rsync (dry run)
    func getTransferredNumbers (numbers : enumNumbers) -> Int {
        
        let number = Numbers(output: self.output!)
        number.setNumbers()
        
        
        switch numbers {
        case .totalDirs:
            guard (number.totalDirs != nil) else {
                return 0
            }
            return number.totalDirs!
        case .totalNumber:
            guard (number.totalNumber != nil) else {
                return 0
            }
            return number.totalNumber!
        case .transferredNumber:
            guard (number.transferredNumber != nil) else {
                return 0
            }
            return number.transferredNumber!
        case .totalNumberSizebytes:
            guard (number.totalNumberSizebytes != nil) else {
                return 0
            }
            return Int(number.totalNumberSizebytes!/1024)
        case .transferredNumberSizebytes:
            guard (number.transferredNumberSizebytes != nil) else {
                return 0
            }
            return Int(number.transferredNumberSizebytes!/1024)
        case .new:
            guard (number.newfiles != nil) else {
                return 0
            }
            return Int(number.newfiles!)
        case .delete:
            guard (number.deletefiles != nil) else {
                return 0
            }
            return Int(number.deletefiles!)
        }
    }
    

    // Function for getting numbers out of output
    // after Process termination is discovered. Function
    // is executed from rsync Process after Process termination.
    // And it is a kind of UGLY...
    func setNumbers() {
        let number = Numbers(output: self.output!)
        number.setNumbers()
    }
    
    
    // Collecting statistics about job
    func statistics(numberOfFiles:String?) -> Array<String> {
        
        let number = Numbers(output: self.output!)
        return number.statistics(numberOfFiles: numberOfFiles)

    }

    init () {
        self.output = Array<String>()
    }
 }
