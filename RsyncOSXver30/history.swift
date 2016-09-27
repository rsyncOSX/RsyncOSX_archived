//
//  history.swift
//  Rsync
//
//  Created by Thomas Evensen on 25/03/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//


import Foundation

class History {
    
    private var historyFromFile : String?
    private var historyFromServerFile : String?
    private var localcatalog : String?
    private var offsiteServer : String?
    private var observationCenter: NSObjectProtocol?
    private var NStaskReference:Process?
    
    // Getting dates as String
    func getdateLocalfile() -> String? {
        return self.historyFromFile
    }
    
    func getdateServerfile() -> String? {
        return self.historyFromServerFile
    }
    
    // Get the filename for local historyfile.
    var fileNameHistory : String? {
        get {
            var path:String?
            if let localcatalog = self.localcatalog {
                self.createDirectory((localcatalog + ".Rsync/"))
                let str = ".Rsync/" + "history.plist"
                path = localcatalog + str
            }
            return path
        }
    }
    
    private var fileNameServerHistory : String? {
        get {
            var path:String?
            if let localcatalog = self.localcatalog {
                self.createDirectory((localcatalog + ".Rsync/"))
                let prefix = offsiteServer! + "_history.plist"
                let str = ".Rsync/" + prefix
                path = localcatalog + str
            }
            return path
        }
    }
    
    // Check if .Rsync directory exists, if not create it.
    private func createDirectory (_ path:String) {
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: path)) {
        } else {
            do { try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)}
            catch _ as NSError { }
        }
    }
    
    
    // Either create a .rsync catalog if none and
    // write a .rsync/history.plist file before backup
    // is executed.
    func writehistoryFile () -> Bool {
        let array = NSMutableArray()
        let currendate = Date()
        // Set the correct dateformat
        let dateformatter = Utils.sharedInstance.setDateformat()
        let dict:NSMutableDictionary = [
            "dateRun":dateformatter.string(from: currendate)]
        array[0] = dict
        return self.writeFile(array, offsiteServer: nil)
    }
    
    // After a backup write timestamp to server_history.plist file
    func writehistoryFileserver () -> Bool {
        let array = NSMutableArray()
        let currendate = Date()
        // Set the correct dateformat
        let dateformatter = Utils.sharedInstance.setDateformat()
        let dict:NSMutableDictionary = [
            "dateRun":dateformatter.string(from: currendate)]
        array[0] = dict
        return self.writeFile(array, offsiteServer: self.offsiteServer)
    }
    
    // Private func for writing history.plist or server_history.plist file
    private func writeFile (_ array: NSMutableArray, offsiteServer:String? ) -> Bool {
        let favoritesDictionary = NSDictionary(object: array, forKey: "history" as NSCopying)
        if (offsiteServer == nil) {
            let succeeded = favoritesDictionary.write(toFile: self.fileNameHistory!, atomically: true)
            return succeeded
        } else {
            let succeeded = favoritesDictionary.write(toFile: self.fileNameServerHistory!, atomically: true)
            return succeeded
        }
    }
    
    // Get history string from local history.plist file.
    // Return timestamp as String.
    private func readhistoryFromFile () -> String? {
        var ItemsList = Array<NSDictionary>()
        let dict = NSDictionary(contentsOfFile: self.fileNameHistory!)
        let dictitems : Any? = dict?.object(forKey: "history")
        if let arrayitems = dictitems as? NSArray {
            for i in 0 ..< arrayitems.count {
                if let itemDict = arrayitems[i] as? NSDictionary {
                    _ = itemDict.object(forKey: "ItemCode") as? String
                    ItemsList.append(itemDict)
                }
            }
        }
        if (ItemsList.count > 0 ) {
            return ItemsList[0].value(forKey: "dateRun") as? String
        } else {
            return nil
        }
    }
    
    // Reading historystring copied form server_history.plist file.
    // Returning timestamp as String
    private func readhistoryserverFromFile (_ localCatalog : String, offsiteServer : String ) -> String? {
        var ItemsList = Array<NSDictionary>()
        var prefix:String?
        if (offsiteServer.isEmpty) {
            prefix = "localhost" + "_history.plist"
        } else {
            prefix = offsiteServer + "_history.plist"
        }
        let fileName:String = localCatalog + ".Rsync/" + prefix!
        let dict = NSDictionary(contentsOfFile: fileName)
        let dictitems : Any? = dict?.object(forKey: "history")
        
        if let arrayitems = dictitems as? NSArray {
            for i in 0 ..< arrayitems.count {
                if let itemDict = arrayitems[i] as? NSDictionary {
                    _ = itemDict.object(forKey: "ItemCode") as? String
                    ItemsList.append(itemDict)
                }
            }
        }
        if (ItemsList.count > 0 ) {
            return ItemsList[0].value(forKey: "dateRun") as? String
        } else {
            return nil
        }
    }
    
    // Copy remote historyfile
    // /usr/bin/scp -B -p -q thomas@10.0.0.10:/scratchdisk/rsyncOSXtest/Documents/.Rsync/history.plist /localCatalog/test.plist
    func copyremoteHistoryfile (_ config : configuration, index:Int) {
        GlobalMainQueue.async(execute: { () -> Void in
            let arguments = scpNSTaskArguments(task: enumscpTasks.scpHistory, config: config, remoteFile: nil, localCatalog: nil, drynrun: nil)
            let args:[String] = arguments.getArgs()!
            let command : String = arguments.getCommand()!
            let task = scpProcess()
            task.executeProcess(command, args: args)
        })
    }
    
    init (localcatalog : String, offsiteServer: String) {
        self.localcatalog = localcatalog
        self.historyFromFile = self.readhistoryFromFile()
        self.historyFromServerFile = self.readhistoryserverFromFile(localcatalog, offsiteServer: offsiteServer)
        if (offsiteServer.isEmpty) {
            self.offsiteServer = "localhost"
        } else {
            self.offsiteServer = offsiteServer
        }
    }
    
}
