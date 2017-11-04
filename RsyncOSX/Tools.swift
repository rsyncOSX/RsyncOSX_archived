//
//  Tools.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.07.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar line_length

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
    case loggingrun
    case changeprofile
    case abort
    case blank
    case error
}

// Protocol for doing a refresh in main view after testing for connectivity
protocol Connections: class {
    func displayConnections()
}

protocol Verifyrsync: class {
    func verifyrsync()
}

final class Tools: SetConfigurations {

    private var indexBoolremoteserverOff: [Bool]?
    weak var testconnectionsDelegate: Connections?
    weak var newprofileDelegate: NewProfile?
    private var macSerialNumber: String?
    weak var verifyrsyncDelegate: Verifyrsync?

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
        guard self.configurations!.configurationsDataSourcecount() > 0 else {
            // Tell main view profile menu might presented
            self.newprofileDelegate?.enableProfileMenu()
            return
        }
        globalDefaultQueue.async(execute: { () -> Void in
            var port: Int = 22
            for i in 0 ..< self.configurations!.configurationsDataSourcecount() {
                if let record = self.configurations!.getargumentAllConfigurations()[i] as? ArgumentsOneConfiguration {
                    if record.config!.offsiteServer != "" {
                        if let sshport: Int = record.config!.sshport { port = sshport }
                        let (success, _) = self.testTCPconnection(record.config!.offsiteServer, port: port, timeout: 1)
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
                    if i == (self.configurations!.configurationsDataSourcecount() - 1) {
                        // Send message to do a refresh
                            // Update table in main view
                        self.testconnectionsDelegate?.displayConnections()
                            // Tell main view profile menu might presented
                        self.newprofileDelegate?.enableProfileMenu()
                    }
                }
            }
        })
    }

    // Function to verify full rsyncpath
    func verifyrsyncpath() {
        let fileManager = FileManager.default
        let path: String?
        // If not in /usr/bin or /usr/local/bin
        // rsyncPath is set if none of the above
        if let rsyncPath = ViewControllerReference.shared.rsyncPath {
            path = rsyncPath + ViewControllerReference.shared.rsync
        } else if ViewControllerReference.shared.rsyncVer3 {
            path = "/usr/local/bin/" + ViewControllerReference.shared.rsync
        } else {
            path = "/usr/bin/" + ViewControllerReference.shared.rsync
        }
        guard ViewControllerReference.shared.rsyncVer3 == true else {
            ViewControllerReference.shared.norsync = false
            self.verifyrsyncDelegate?.verifyrsync()
            return
        }
        if fileManager.fileExists(atPath: path!) == false {
            ViewControllerReference.shared.norsync = true
        } else {
            ViewControllerReference.shared.norsync = false
        }
        self.verifyrsyncDelegate?.verifyrsync()
    }

    // Display the correct command to execute
    // Used for displaying the commands only
    func rsyncpathtodisplay(index: Int, dryRun: Bool) -> String {
        var str: String?
        let config = self.configurations!.getargumentAllConfigurations()[index] as? ArgumentsOneConfiguration
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
        if ViewControllerReference.shared.rsyncVer3 {
            if ViewControllerReference.shared.rsyncPath == nil {
                return ViewControllerReference.shared.usrlocalbinrsync
            } else {
                return ViewControllerReference.shared.rsyncPath! + ViewControllerReference.shared.rsync
            }
        } else {
            return ViewControllerReference.shared.usrbinrsync
        }
    }

    func noRsync() {
        if let rsync = ViewControllerReference.shared.rsyncPath {
            Alerts.showInfo("ERROR: no rsync in " + rsync)
        } else {
            Alerts.showInfo("ERROR: no rsync in /usr/local/bin")
        }
    }

    /// Function for computing MacSerialNumber
    func computemacSerialNumber() -> String {
        // Get the platform expert
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                                       IOServiceMatching("IOPlatformExpertDevice"))
        // Get the serial number as a CFString ( actually as Unmanaged<AnyObject>! )
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
                                                                     kIOPlatformSerialNumberKey as CFString!,
                                                                     kCFAllocatorDefault, 0)
        // Release the platform expert (we're responsible)
        IOObjectRelease(platformExpert)
        // Take the unretained value of the unmanaged-any-object
        // (so we're not responsible for releasing it)
        // and pass it back as a String or, if it fails, an empty string
        // return (serialNumberAsCFString!.takeUnretainedValue() as? String) ?? ""
        return (serialNumberAsCFString!.takeRetainedValue() as? String) ?? ""
    }

    /// Function for returning the MacSerialNumber
    func getMacSerialNumber() -> String? {
        guard self.macSerialNumber != nil else {
            // Compute it, set it and return
            self.macSerialNumber = self.computemacSerialNumber()
            return self.macSerialNumber!
        }
        return self.macSerialNumber
    }

    // Calculate seconds from now to startdate
    private func seconds (_ startdate: Date, enddate: Date?) -> Double {
        if enddate == nil {
            return startdate.timeIntervalSinceNow
        } else {
            return enddate!.timeIntervalSince(startdate)
        }
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    // Returns time in minutes
    func timeDoubleMinutes (_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (_, minf) = modf (seconds / 3600)
        let (min, _) = modf (60 * minf)
        return min
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    // Returns time in seconds
    func timeDoubleSeconds (_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        return seconds
    }

    // Returns number of hours between start and stop date
    func timehourInt(_ startdate: Date, enddate: Date?) -> Int {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (hr, _) = modf (seconds / 3600)
        return Int(hr)
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    func timeString (_ startdate: Date, enddate: Date?) -> String {
        var result: String?
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (hr, minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        // hr, min, 60 * secf
        if hr == 0 && min == 0 {
            result = String(format: "%.0f", 60 * secf) + " secs"
        } else if hr == 0 && min < 60 {
            result = String(format: "%.0f", min) + " mins " + String(format: "%.0f", 60 * secf) + " secs"
        } else if hr < 25 {
            result = String(format: "%.0f", hr) + " hours " + String(format: "%.0f", min) + " mins"
        } else {
            result = String(format: "%.0f", hr/24) + " days"
        }
        if secf <= 0 {
            result = " ... working ... "
        }
        return result!
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    func timeString (_ seconds: Double) -> String {
        var result: String?
        let (hr, minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        // hr, min, 60 * secf
        if hr == 0 && min == 0 {
            result = String(format: "%.0f", 60 * secf) + "s"
        } else if hr == 0 && min < 60 {
            result = String(format: "%.0f", min) + "m " + String(format: "%.0f", 60 * secf) + "s"
        } else if hr < 25 {
            result = String(format: "%.0f", hr) + "h " + String(format: "%.0f", min) + "m"
        } else {
            result = String(format: "%.0f", hr/24) + "d"
        }
        return result ?? ""
    }

    init() {
        self.verifyrsyncDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.testconnectionsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.newprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}
