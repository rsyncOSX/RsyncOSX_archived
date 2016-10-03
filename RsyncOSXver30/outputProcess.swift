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
