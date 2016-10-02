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

final class Utils {
    
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

    // Tools for rsync parameters
    
    
 }

