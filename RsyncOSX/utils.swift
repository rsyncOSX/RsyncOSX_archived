//
//  Utils.swift
//  Rsync
//
//  Created by Thomas Evensen on 09/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//swiftlint:disable syntactic_sugar line_length

import Foundation

var globalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

var globalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: .background)
}

var globalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInitiated)
}

var globalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: .utility)
}

var globalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInteractive)
}

var globalDefaultQueue: DispatchQueue {
    return DispatchQueue.global(qos: .default)
}

// Used in mainTab to present info about process
enum DisplayProcessInfo {
    case estimating
    case executing
    case setmaxNumber
    case loggingrun
    case countfiles
    case changeprofile
    case profilesenabled
    case abort
    case blank
    case error
}

// Protocol for doing a refresh in main view after testing for connectivity
protocol Connections : class {
    func displayConnections()
}

// Static shared class Utils

final class Utils {

    private var indexBoolremoteserverOff: [Bool]?
    weak var testconnectionsDelegate: Connections?
    weak var profilemenuDelegate: AddProfiles?

    // Creates a singelton of this class
    class var  shared: Utils {
        struct Singleton {
            static let instance = Utils()
        }
        return Singleton.instance
    }

    // Test for TCP connection
    func testTCPconnection (_ addr: String, port: Int, timeout: Int) -> (Bool, String) {
        var connectionOK: Bool = false
        var str: String = ""
        let client: TCPClient = TCPClient(addr: addr, port: port)
        let (success, errmsg) = client.connect(timeout: timeout)
        connectionOK = success
        if connectionOK {
            str = "connection OK"
        } else {
            str = errmsg
        }
        return (connectionOK, str)
    }

    // Setting date format
    func setDateformat() -> DateFormatter {
        let dateformatter = DateFormatter()
        // We are forcing en_US format of date strings
        dateformatter.locale = Locale(identifier: "en_US")
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
        self.indexBoolremoteserverOff = nil
        self.indexBoolremoteserverOff = Array<Bool>()

        guard Configurations.shared.configurationsDataSourcecount() > 0 else {
            if let pvc = Configurations.shared.viewControllertabMain as? ViewControllertabMain {
                self.profilemenuDelegate = pvc
                // Tell main view profile menu might presented
                self.profilemenuDelegate?.enableProfileMenu()
            }
            return
        }

        globalDefaultQueue.async(execute: { () -> Void in

            var port: Int = 22
            for i in 0 ..< Configurations.shared.configurationsDataSourcecount() {
                if let record = Configurations.shared.getargumentAllConfigurations()[i] as? ArgumentsOneConfiguration {
                    if record.config!.offsiteServer != "" {
                        if let sshport: Int = record.config!.sshport {
                            port = sshport
                        }
                        let (success, _) = Utils.shared.testTCPconnection(record.config!.offsiteServer, port: port, timeout: 1)
                        if success {
                            self.indexBoolremoteserverOff!.append(false)
                        } else {
                            // self.remoteserverOff = true
                            self.indexBoolremoteserverOff!.append(true)
                        }
                    } else {
                        self.indexBoolremoteserverOff!.append(false)
                    }
                    // Reload table when all remote servers are checked
                    if i == (Configurations.shared.configurationsDataSourcecount() - 1) {
                        // Send message to do a refresh
                        if let pvc = Configurations.shared.viewControllertabMain as? ViewControllertabMain {
                            self.testconnectionsDelegate = pvc
                            self.profilemenuDelegate = pvc
                            // Update table in main view
                            self.testconnectionsDelegate?.displayConnections()
                            // Tell main view profile menu might presented
                            self.profilemenuDelegate?.enableProfileMenu()
                        }
                    }
                }
            }
        })
    }

    // Function for verifying thar rsync is present in either
    // standard path or path set by user
    func noRsync() {
        if Configurations.shared.noRysync == true {
            if let rsync = Configurations.shared.rsyncPath {
                Alerts.showInfo("ERROR: no rsync in " + rsync)
            } else {
                Alerts.showInfo("ERROR: no rsync in /usr/local/bin")
            }
        } else {
            Alerts.showInfo("Scheduled operation in progress")
        }
    }

    // Function to verify full rsyncpath
    func verifyrsyncpath() {
        let fileManager = FileManager.default
        let path: String?
        // If not in /usr/bin or /usr/local/bin
        // rsyncPath is set if none of the above
        if let rsyncPath = Configurations.shared.rsyncPath {
            path = rsyncPath + "rsync"
        } else if Configurations.shared.rsyncVer3 {
            path = "/usr/local/bin/" + "rsync"
        } else {
            path = "/usr/bin/" + "rsync"
        }
        if fileManager.fileExists(atPath: path!) == false {
            Configurations.shared.noRysync = true
        } else {
            Configurations.shared.noRysync = false
        }
    }

    // Display the correct command to execute
    // Used for displaying the commands only
    func rsyncpathtodisplay(index: Int, dryRun: Bool) -> String {
        var str: String?
        let config = Configurations.shared.getargumentAllConfigurations()[index] as? ArgumentsOneConfiguration
        if dryRun {
            str = self.rsyncpath() + " "
            if let count = config?.argdryRunDisplay?.count {
                for i in 0 ..< count {
                    str = str! + (config?.argdryRunDisplay![i])!
                }
            }
        } else {
            str = self.rsyncpath() + " "
            if let count = config?.argDisplay?.count {
                for i in 0 ..< count {
                    str = str! + (config?.argDisplay![i])!
                }
            }
        }
        return str!
    }

    /// Function returns the correct path for rsync
    /// according to configuration set by user or
    /// default value.
    /// - returns : full path of rsync command
    func rsyncpath() -> String {
        if Configurations.shared.rsyncVer3 {
            if Configurations.shared.rsyncPath == nil {
                return "/usr/local/bin/rsync"
            } else {
                return Configurations.shared.rsyncPath! + "rsync"
            }
        } else {
            return "/usr/bin/rsync"
        }
    }
}
