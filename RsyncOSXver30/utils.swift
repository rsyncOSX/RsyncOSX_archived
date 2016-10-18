//
//  utils.swift
//  Rsync
//
//  Created by Thomas Evensen on 09/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

var GlobalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

var GlobalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: .background)
}

var GlobalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInitiated)
}

var GlobalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: .utility)
}

var GlobalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInteractive)
}

var GlobalDefaultQueue: DispatchQueue {
    return DispatchQueue.global(qos: .default)
}

// Class for different tools

protocol Connections : class {
    func displayConnections()
}

final class Utils {
    
    private var indexBoolremoteserverOff:[Bool]?
    weak var delegate_testconnections:Connections?
    
    // Creates a singelton of this class
    class var  sharedInstance: Utils {
        struct Singleton {
            static let instance = Utils()
        }
        return Singleton.instance
    }
    
    // Display the correct command to execute
    func setRsyncCommandDisplay(index:Int, dryRun:Bool) -> String {
        var str:String?
        let config = SharingManagerConfiguration.sharedInstance.getargumentAllConfigurations()[index] as? argumentsOneConfig
        if (dryRun) {
                str = SharingManagerConfiguration.sharedInstance.setRsyncCommand() + " "
                if let count = config?.argdryRunDisplay?.count {
                    for i in 0 ..< count {
                        str = str! + (config?.argdryRunDisplay![i])!
                    }
                }
        } else {
            str = SharingManagerConfiguration.sharedInstance.setRsyncCommand() + " "
                if let count = config?.argDisplay?.count {
                    for i in 0 ..< count {
                        str = str! + (config?.argDisplay![i])!
                    }
                }
            }
        return str!
    }
    
    // Test for TCP connection
    func testTCPconnection (_ addr:String, port:Int, timeout:Int) -> (Bool, String) {
        var connectionOK:Bool = false
        var str:String = ""
        let client:TCPClient = TCPClient(addr: addr, port: port)
        let (success, errmsg) = client.connect(timeout: timeout)
        connectionOK = success
        if connectionOK {
            str = "connection OK"
        } else {
            str = errmsg
        }
        return (connectionOK, str)
    }


    func setDateformat() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale.current
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        dateformatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateformatter
    }

    // Getting the structure for test connection
    func gettestAllremoteserverConnections() -> [Bool]? {
        return self.indexBoolremoteserverOff
    }
    
    // Testing all remote servers.
    // Adding connection true or false in array[bool]
    // Do the check in background que, reload table in global main queue
    func testAllremoteserverConnections () {
        self.indexBoolremoteserverOff = [Bool]()
        GlobalDefaultQueue.async(execute: { () -> Void in
            // self.indexBoolremoteserverOff.removeAll()
            var port:Int = 22
            for i in 0 ..< SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecount() {
                let config = SharingManagerConfiguration.sharedInstance.getargumentAllConfigurations()[i] as? argumentsOneConfig
                if ((config?.config.offsiteServer)! != "") {
                    if let sshport:Int = config?.config.sshport {
                        port = sshport
                    }
                    let (success, _) = Utils.sharedInstance.testTCPconnection((config?.config.offsiteServer)!, port: port, timeout: 1)
                    if (success) {
                        self.indexBoolremoteserverOff!.append(false)
                    } else {
                        // self.remoteserverOff = true
                        self.indexBoolremoteserverOff!.append(true)
                    }
                } else {
                    self.indexBoolremoteserverOff!.append(false)
                }
                // Reload table when all remote servers are checked
                if i == (SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecount() - 1) {
                    // Send message to do a refresh
                    if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
                        self.delegate_testconnections = pvc
                        self.delegate_testconnections?.displayConnections()
                    }
                }
            }
        })
    }

    
 }

