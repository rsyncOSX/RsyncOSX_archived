//
//  TCPconnections.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

// Protocol for doing a refresh in main view after testing for connectivity
protocol Connections: AnyObject {
    func displayConnections()
}

class TCPconnections: SetConfigurations, Delay {
    private var indexBoolremoteserverOff: [Bool]?
    weak var testconnectionsDelegate: Connections?
    weak var newprofileDelegate: NewProfile?
    var client: TCPClient?
    var connectionscheckcompleted: Bool = false

    // Test for TCP connection
    func testTCPconnection(_ host: String, port: Int, timeout: Int) -> Bool {
        self.client = TCPClient(address: host, port: Int32(port))
        guard let client = client else { return true }
        switch client.connect(timeout: timeout) {
        case .success:
            return true
        default:
            return false
        }
    }

    // Getting the structure for test connection
    func gettestAllremoteserverConnections() -> [Bool]? {
        return self.indexBoolremoteserverOff
    }

    // Testing all remote servers.
    // Adding connection true or false in array[bool]
    // Do the check in background que, reload table in global main queue
    func testAllremoteserverConnections() {
        self.indexBoolremoteserverOff = nil
        self.indexBoolremoteserverOff = [Bool]()
        guard (self.configurations?.configurationsDataSourcecount() ?? -1) > 0 else {
            // Tell main view profile menu might presented
            self.newprofileDelegate?.reloadprofilepopupbutton()
            return
        }
        globalDefaultQueue.async { () -> Void in
            var port: Int = 22
            for i in 0 ..< (self.configurations?.configurationsDataSourcecount() ?? 0) {
                if let config = self.configurations?.getConfigurations()[i] {
                    if config.offsiteServer.isEmpty == false {
                        if let sshport: Int = config.sshport { port = sshport }
                        let success = self.testTCPconnection(config.offsiteServer, port: port, timeout: 1)
                        if success {
                            self.indexBoolremoteserverOff!.append(false)
                        } else {
                            self.indexBoolremoteserverOff!.append(true)
                        }
                    } else {
                        self.indexBoolremoteserverOff!.append(false)
                    }
                    // Reload table when all remote servers are checked
                    if i == ((self.configurations?.configurationsDataSourcecount() ?? 0) - 1) {
                        // Send message to do a refresh table in main view
                        self.testconnectionsDelegate?.displayConnections()
                        // Tell main view profile menu might presented
                        self.newprofileDelegate?.reloadprofilepopupbutton()
                        self.connectionscheckcompleted = true
                    }
                }
            }
        }
    }

    init() {
        self.testconnectionsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.newprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }
}
