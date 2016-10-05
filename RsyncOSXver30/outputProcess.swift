//
//  arrayNSTask.swift
//  Rsync
//
//  Created by Thomas Evensen on 11/01/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class outputProcess {
    
    // Second last String in Array rsync output of how much in what time
    private var message:String = String()
    // calculated number of files
    // set from rsync
    private var calculatedNumberOfFiles:Int?
    // output Array to keep output from rsync in
    private var output = NSMutableArray()
    // output for batchTasks
    private var batchoutput = NSMutableArray()
    // output Array temporary indexes
    private var startIndex:Int?
    private var endIndex:Int?
    // numbers after dryrun and stats
    private var totalnumber:Int?
    private var transferredNumber:Int?
    private var totalnumberSize:Double?
    private var transferredNumberSize:Double?
    
    func removeObjectsOutput() {
        if (self.output.count > 0) {
            self.output.removeAllObjects()
        }
    }
   
    func copySummarizedResultBatch() {
        let result = self.statistics()[0] + " , " + self.statistics()[1]
        self.batchoutput.add(result)
    }
    
    func getOutputCount () -> Int {
        return self.output.count
    }
    
    func getOutput () -> NSMutableArray {
        return self.output
    }
    
    func getOutputbatch() -> NSMutableArray {
        return self.batchoutput
    }
    
    // Return end message of Rsync
    func endMessage() -> String {
        return self.message
    }
    
    // Add line to output
    func addLine (_ str: String) {
        let sentence = str
        
        if (self.startIndex == nil) {
            self.startIndex = 0
        } else {
            self.startIndex = self.getOutputCount()+1
        }
        sentence.enumerateLines {
            line, stop in
            if line.characters.last != "/" {
                self.output.add(line)
            }
        }
        self.endIndex = self.output.count
        if (self.endIndex! > 2) {
            self.message = (self.output[self.endIndex!-2] as? String)!
        }
    }
    
    // Function for getting numbers out of output
    // after Process termination is discovered. Function
    // is executed from rsync Process after Process termination
    func getNumbers() {
        let numbers = self.output.filter({(($0 as? String)?.contains("Number of"))!})
        let total = self.output.filter({(($0 as? String)?.contains("Total"))!})
        if (numbers.count > 1 && total.count > 1) {
            var numberParts:[String]?
            var transferredNumberParts:[String]?
            var totalSizeParts:[String]?
            var transferredSizeParts:[String]?
            // numbers
            if (SharingManagerConfiguration.sharedInstance.rsyncVer3) {
                numberParts = (numbers[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                transferredNumberParts  = (numbers[3] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                self.totalnumber = Int(numberParts![3])
                self.transferredNumber = Int(transferredNumberParts![5])
            } else {
                numberParts = (numbers[0] as AnyObject).components(separatedBy: " ")
                transferredNumberParts = (numbers[1] as AnyObject).components(separatedBy: " ")
                self.totalnumber = Int(numberParts![3])
                self.transferredNumber = Int(transferredNumberParts![4])
            }
            // total
            if (SharingManagerConfiguration.sharedInstance.rsyncVer3) {
                totalSizeParts = (total[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                transferredSizeParts = (total[1] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                self.totalnumberSize = Double(totalSizeParts![3])
                self.transferredNumberSize = Double(transferredSizeParts![4])
            } else {
                totalSizeParts = (total[0] as AnyObject).components(separatedBy: " ")
                transferredSizeParts = (total[1] as AnyObject).components(separatedBy: " ")
                self.totalnumberSize = Double(totalSizeParts![3])
                self.transferredNumberSize = Double(transferredSizeParts![4])
            }
            print(self.totalnumber!)
            print(self.totalnumberSize!)
            print(self.transferredNumber!)
            print(self.transferredNumberSize!)
        }
    }
    
    
    // Collecting statistics about job
    func statistics() -> [String] {
        var numberstring:String?
        var parts:[String]?
        
        if (SharingManagerConfiguration.sharedInstance.rsyncVer3) {
            let newmessage = message.replacingOccurrences(of: ",", with: "")
            parts = newmessage.components(separatedBy: " ")
        } else {
            parts = self.message.components(separatedBy: " ")
        }
        var resultsent:String?
        var resultreceived:String?
        var result:String?
        var i:Int = 0
        
        var bytesTotalsent:Double = 0
        var bytesTotalreceived:Double = 0
        var bytesTotal:Double = 0
        var bytesSec:Double = 0
        var seconds:Double = 0
        
        for part in parts! {
            // sent
            if (i == 1) {
                resultsent = part + " bytes in "
                if (Double(part) != nil) {
                    bytesTotalsent = Double(part)!
                } else {
                    return ["0","0"]
                }
                // received
            } else if (i == 5) {
                resultreceived = part + " bytes in "
                if (Double(part) != nil) {
                    bytesTotalreceived = Double(part)!
                }
            } else if (i == 8) {
                if (bytesTotalsent > bytesTotalreceived) {
                    // backup task
                    result = resultsent! + part + " b/sec"
                    bytesSec = Double(part)!
                    seconds = bytesTotalsent/bytesSec
                    bytesTotal = bytesTotalsent
                } else {
                    // restore task
                    result = resultreceived! + part + " b/sec"
                    bytesSec = Double(part)!
                    seconds = bytesTotalreceived/bytesSec
                    bytesTotal = bytesTotalreceived
                }
            }
            i = i + 1
        }
        numberstring = String(self.output.count) + " files : " + String(format:"%.2f",(bytesTotal/1024)/1000) + " MB in " + String(format:"%.2f",seconds) + " seconds"
        if (result == nil) {
            result = "hmmm...."
        }
        return [numberstring!, result!]
    }

    init () {
        // Second last String in Array rsync output of how much and in what time
        self.message = " "
    }
 }
