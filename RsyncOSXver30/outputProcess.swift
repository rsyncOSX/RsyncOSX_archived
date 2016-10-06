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
    private var totalNumber:Int?
    private var totalDirs:Int?
    private var totalNumberSizebytes:Double?
    private var transferredNumber:Int?
    private var transferredNumberSizebytes:Double?
    // enum for returning what is asked for
    enum enumNumbers {
        case totalNumber
        case totalDirs
        case totalNumberSizebytes
        case transferredNumber
        case transferredNumberSizebytes
    }
    
    
    func removeObjectsOutput() {
        if (self.output.count > 0) {
            self.output.removeAllObjects()
        }
    }
   
    func copySummarizedResultBatch() {
        let result = self.statistics(numberOfFiles: nil)[0] + " , " + self.statistics(numberOfFiles: nil)[1]
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
    
    // Get numbers from rsync (dry run)
    func getTransferredNumbers (numbers : enumNumbers) -> Int {
        switch numbers {
        case .totalDirs:
            if (self.totalDirs != nil) {
                return self.totalDirs!
            } else {
                return 0
            }
        case .totalNumber:
            if (self.totalNumber != nil) {
                return self.totalNumber!
            } else {
                return 0
            }
        case .transferredNumber:
            if (self.transferredNumber != nil) {
                return self.transferredNumber!
            } else {
                return 0
            }
        case .totalNumberSizebytes:
            if (self.totalNumberSizebytes != nil) {
                return Int(self.totalNumberSizebytes!/1024)
            } else {
                return 0
            }
        case .transferredNumberSizebytes:
            if (self.transferredNumberSizebytes != nil) {
                return Int(self.transferredNumberSizebytes!/1024)
            } else {
                return 0
            }
        }
    }
    
    // Function for printing all numbers rsync dry run
    func printNumbers() {
        print("Directorys :" + "\(self.getTransferredNumbers(numbers: .totalDirs))")
        print("Total number of files :" + "\(self.getTransferredNumbers(numbers: .totalNumber))")
        print("Total number of transferred files :" + "\(self.getTransferredNumbers(numbers: .transferredNumber))")
        print("Total number of KB :" + "\(self.getTransferredNumbers(numbers: .totalNumberSizebytes))")
        print("Total number of KB transferred :" + "\(self.getTransferredNumbers(numbers: .transferredNumberSizebytes))")
    }
    
    // Function for getting numbers out of output
    // after Process termination is discovered. Function
    // is executed from rsync Process after Process termination.
    // And it is UGLY...
    func getNumbers() {
        let numbers = self.output.filter({(($0 as? String)?.contains("Number of"))!})
        let total = self.output.filter({(($0 as? String)?.contains("Total"))!})
        if (numbers.count > 1 && total.count > 1) {
            var numberParts:[String]?
            var transferredNumberParts:[String]?
            var totalSizeParts:[String]?
            var transferredSizeParts:[String]?
            
            // Dissection of rsync output to get the numbers.
            // Ver3 of rsync also reports about number of directories
            // Stock version does not.
            
            if (SharingManagerConfiguration.sharedInstance.rsyncVer3) {
                // Ver3 of rsync adds "," as 1000 mark, must replace it and then split numbers into components
                numberParts = (numbers[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                
                if numbers.count > 3 {
                    transferredNumberParts  = (numbers[3] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                } else {
                    transferredNumberParts  = (numbers[2] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                }
                if (numberParts != nil && transferredNumberParts != nil) {
                    if (numberParts!.count > 7 && transferredNumberParts!.count > 5) {
                        self.totalNumber = Int(numberParts![5])
                        self.transferredNumber = Int(transferredNumberParts![5])
                        self.totalDirs = Int(numberParts![7].replacingOccurrences(of: ")", with: ""))
                    }
                }
            } else {
                // Stock version of rsync
                numberParts = (numbers[0] as AnyObject).components(separatedBy: " ")
                transferredNumberParts = (numbers[1] as AnyObject).components(separatedBy: " ")
                
                if (numberParts != nil && transferredNumberParts != nil) {
                    if (numberParts!.count > 3 && transferredNumberParts!.count > 4) {
                        self.totalNumber = Int(numberParts![3])
                        self.transferredNumber = Int(transferredNumberParts![4])
                    }
                }
            }
            
            // Dissection of rsync output to get the total of bytes
            
            if (SharingManagerConfiguration.sharedInstance.rsyncVer3) {
                // Ver3 of rsync adds "," as 1000 mark, must replace it and then split numbers into components
                totalSizeParts = (total[0] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                transferredSizeParts = (total[1] as AnyObject).replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
                
                if (totalSizeParts != nil && transferredNumberParts != nil) {
                    if (totalSizeParts!.count > 3 && transferredNumberParts!.count > 4) {
                        self.totalNumberSizebytes = Double(totalSizeParts![3])
                        self.transferredNumberSizebytes = Double(transferredSizeParts![4])
                    }
                }
            } else {
                // Stock version of rsync
                totalSizeParts = (total[0] as AnyObject).components(separatedBy: " ")
                transferredSizeParts = (total[1] as AnyObject).components(separatedBy: " ")
                if (totalSizeParts != nil && transferredNumberParts != nil) {
                    if (totalSizeParts!.count > 3 && transferredNumberParts!.count > 4) {
                        self.totalNumberSizebytes = Double(totalSizeParts![3])
                        self.transferredNumberSizebytes = Double(transferredSizeParts![4])
                    }
                }
            }
        }
    }
    
    
    // Collecting statistics about job
    func statistics(numberOfFiles:String?) -> [String] {
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
        if (numberOfFiles == nil) {
            numberstring = String(self.output.count) + " files : " + String(format:"%.2f",(bytesTotal/1024)/1000) + " MB in " + String(format:"%.2f",seconds) + " seconds"
        } else {
            numberstring = numberOfFiles! + " files : " + String(format:"%.2f",(bytesTotal/1024)/1000) + " MB in " + String(format:"%.2f",seconds) + " seconds"
        }
        
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
