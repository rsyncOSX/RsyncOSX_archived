//
//  numbers.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.05.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class Numbers {
    
    // Second last String in Array rsync output of how much in what time
    private var resultRsync:String?
    // calculated number of files
    // output Array to keep output from rsync in
    private var output:Array<String>?
    // numbers after dryrun and stats
    var totalNumber:Int?
    var totalDirs:Int?
    var totalNumberSizebytes:Double?
    var transferredNumber:Int?
    var transferredNumberSizebytes:Double?
    var newfiles:Int?
    var deletefiles:Int?
    
    // Get numbers from rsync (dry run)
    func getTransferredNumbers (numbers : enumNumbers) -> Int {
        
        switch numbers {
        case .totalDirs:
            guard (self.totalDirs != nil) else {
                return 0
            }
            return self.totalDirs!
        case .totalNumber:
            guard (self.totalNumber != nil) else {
                return 0
            }
            return self.totalNumber!
        case .transferredNumber:
            guard (self.transferredNumber != nil) else {
                return 0
            }
            return self.transferredNumber!
        case .totalNumberSizebytes:
            guard (self.totalNumberSizebytes != nil) else {
                return 0
            }
            return Int(self.totalNumberSizebytes!/1024)
        case .transferredNumberSizebytes:
            guard (self.transferredNumberSizebytes != nil) else {
                return 0
            }
            return Int(self.transferredNumberSizebytes!/1024)
        case .new:
            guard (self.newfiles != nil) else {
                return 0
            }
            return Int(self.newfiles!)
        case .delete:
            guard (self.deletefiles != nil) else {
                return 0
            }
            return Int(self.deletefiles!)
        }
    }

    
    // Function for getting numbers out of output
    // after Process termination is discovered. Function
    // is executed from rsync Process after Process termination.
    // And it is a kind of UGLY...
    func setNumbers() {
        
        let transferredFiles = self.output!.filter({(($0).contains("files transferred:"))})
        // ver 3.x - [Number of regular files transferred: 24]
        // ver 2.x - [Number of files transferred: 24]
        let transferredFilesSize = self.output!.filter({(($0).contains("Total transferred file size:"))})
        // ver 3.x - [Total transferred file size: 278,642 bytes]
        // ver 2.x - [Total transferred file size: 278197 bytes]
        let totalFileSize = self.output!.filter({(($0).contains("Total file size:"))})
        // ver 3.x - [Total file size: 1,016,382,148 bytes]
        // ver 2.x - [Total file size: 1016381703 bytes]
        let totalFilesNumber = self.output!.filter({(($0).contains("Number of files:"))})
        // ver 3.x - [Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)]
        // ver 2.x - [Number of files: 3956]
        // New files
        let new = self.output!.filter({(($0).contains("Number of created files:"))})
        // Delete files
        let delete = self.output!.filter({(($0).contains("Number of deleted files:"))})
        
        // Must make it somewhat robust, it it breaks all values is set to 0
        
        if (transferredFiles.count == 1 && transferredFilesSize.count == 1 &&  totalFileSize.count == 1 &&  totalFilesNumber.count == 1) {
            
            if (SharingManagerConfiguration.sharedInstance.rsyncVer3) {
                // Ver3 of rsync adds "," as 1000 mark, must replace it and then split numbers into components
                let transferredFilesParts = (transferredFiles[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                let transferredFilesSizeParts = (transferredFilesSize[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                let totalFilesNumberParts = (totalFilesNumber[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                let totalFileSizeParts = (totalFileSize[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                let newParts = (new[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                let deleteParts = (delete[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                
                // ["Number", "of", "regular", "files", "transferred:", "24"]
                // ["Total", "transferred", "file", "size:", "281653", "bytes"]
                // ["Number", "of", "files:", "3956", "(reg:", "3197", "dir:", "758", "link:", "1)"]
                // ["Total", "file", "size:", "1016385159", "bytes"]
                // ["Number" "of" "created" "files:" "0"]
                // ["Number" "of" "deleted" "files:" "0"]
                
                if transferredFilesParts.count > 5 {self.transferredNumber = Int(transferredFilesParts[5])} else {self.transferredNumber = 0}
                if transferredFilesSizeParts.count > 4 {self.transferredNumberSizebytes = Double(transferredFilesSizeParts[4])} else {self.transferredNumberSizebytes = 0}
                if totalFilesNumberParts.count > 5 {self.totalNumber = Int(totalFilesNumberParts[5])} else {self.totalNumber = 0}
                if totalFileSizeParts.count > 3 {self.totalNumberSizebytes = Double(totalFileSizeParts[3])} else {self.totalNumberSizebytes = 0}
                if totalFilesNumberParts.count > 7 {self.totalDirs = Int(totalFilesNumberParts[7].replacingOccurrences(of: ")", with: ""))} else {self.totalDirs = 0}
                if newParts.count > 4 {self.newfiles = Int(newParts[4])} else {self.newfiles = 0}
                if deleteParts.count > 4 {self.deletefiles = Int(deleteParts[4])} else {self.deletefiles = 0}
                
            } else {
                
                let transferredFilesParts = (transferredFiles[0] as AnyObject).components(separatedBy: " ")
                let transferredFilesSizeParts = (transferredFilesSize[0] as AnyObject).components(separatedBy: " ")
                let totalFilesNumberParts = (totalFilesNumber[0] as AnyObject).components(separatedBy: " ")
                let totalFileSizeParts = (totalFileSize[0] as AnyObject).components(separatedBy: " ")
                
                // ["Number", "of", "files", "transferred:", "24"]
                // ["Total", "transferred", "file", "size:", "281579", "bytes"]
                // ["Number", "of", "files:", "3956"]
                // ["Total", "file", "size:", "1016385085", "bytes"]
                
                if transferredFilesParts.count > 4 {self.transferredNumber = Int(transferredFilesParts[4])} else {self.transferredNumber = 0}
                if transferredFilesSizeParts.count > 4 {self.transferredNumberSizebytes = Double(transferredFilesSizeParts[4])} else {self.transferredNumberSizebytes = 0}
                if totalFilesNumberParts.count > 3 {self.totalNumber = Int(totalFilesNumberParts[3])} else {self.totalNumber = 0}
                if totalFileSizeParts.count > 3 {self.totalNumberSizebytes = Double(totalFileSizeParts[3])} else {self.totalNumberSizebytes = 0}
                // Rsync ver 2.x does not count directories, new files or deleted files
                self.totalDirs = 0
                self.newfiles = 0
                self.deletefiles = 0
            }
        } else {
            // If it breaks set number of transferred files to
            // size of output.
            self.transferredNumber = self.output!.count
        }
    }
    
    
    // Collecting statistics about job
    func statistics(numberOfFiles:String?) -> Array<String> {
        var numberstring:String?
        var parts:Array<String>?
        
        
        guard (self.resultRsync != nil) else {
            return ["0","0"]
        }
        
        if (SharingManagerConfiguration.sharedInstance.rsyncVer3) {
            // ["sent", "409687", "bytes", "", "received", "5331", "bytes", "", "830036.00", "bytes/sec"]
            let newmessage = self.resultRsync!.replacingOccurrences(of: ",", with: "")
            parts = newmessage.components(separatedBy: " ")
        } else {
            // ["sent", "262826", "bytes", "", "received", "2248", "bytes", "", "58905.33", "bytes/sec"]
            parts = self.resultRsync!.components(separatedBy: " ")
        }
        
        var resultsent:String?
        var resultreceived:String?
        var result:String?
        
        var bytesTotalsent:Double = 0
        var bytesTotalreceived:Double = 0
        var bytesTotal:Double = 0
        var bytesSec:Double = 0
        var seconds:Double = 0
        
        guard parts!.count > 9 else {
            return ["0","0"]
        }
        guard (Double(parts![1]) != nil && (Double(parts![5]) != nil) && (Double(parts![8]) != nil) ) else {
            return ["0","0"]
        }
        
        // Sent
        resultsent = parts![1] + " bytes in "
        bytesTotalsent = Double(parts![1])!
        // Received
        resultreceived = parts![5] + " bytes in "
        bytesTotalreceived = Double(parts![5])!
        
        if (bytesTotalsent > bytesTotalreceived) {
            // backup task
            result = resultsent! + parts![8] + " b/sec"
            bytesSec = Double(parts![8])!
            seconds = bytesTotalsent/bytesSec
            bytesTotal = bytesTotalsent
        } else {
            // restore task
            result = resultreceived! + parts![8] + " b/sec"
            bytesSec = Double(parts![8])!
            seconds = bytesTotalreceived/bytesSec
            bytesTotal = bytesTotalreceived
        }
        // Dont have numbers of file as input
        if (numberOfFiles == nil) {
            numberstring = String(self.output!.count) + " files : " + String(format:"%.2f",(bytesTotal/1024)/1000) + " MB in " + String(format:"%.2f",seconds) + " seconds"
        } else {
            numberstring = numberOfFiles! + " files : " + String(format:"%.2f",(bytesTotal/1024)/1000) + " MB in " + String(format:"%.2f",seconds) + " seconds"
        }
        if (result == nil) {
            result = "hmmm...."
        }
        return [numberstring!, result!]
    }
    
    init (output:Array<String>) {
        self.output = output
        if (self.output!.count > 2) {
            self.resultRsync = (self.output![self.output!.count-2])
        }
    }
}

