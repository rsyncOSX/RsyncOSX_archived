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
protocol Connections: class {
    func displayConnections()
}

class TCPconnections: SetConfigurations, Delay {

    private var indexBoolremoteserverOff: [Bool]?
    weak var testconnectionsDelegate: Connections?
    weak var newprofileDelegate: NewProfile?

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

    // Getting the structure for test connection
    func gettestAllremoteserverConnections() -> [Bool]? {
        return self.indexBoolremoteserverOff
    }

    // Testing all remote servers.
    // Adding connection true or false in array[bool]
    // Do the check in background que, reload table in global main queue
    func testAllremoteserverConnections () {
        self.indexBoolremoteserverOff = nil
        self.indexBoolremoteserverOff = [Bool]()
        guard self.configurations!.configurationsDataSourcecount() > 0 else {
            // Tell main view profile menu might presented
            self.newprofileDelegate?.enableProfileMenu()
            return
        }
        globalDefaultQueue.async(execute: { () -> Void in
            var port: Int = 22
            for i in 0 ..< self.configurations!.configurationsDataSourcecount() {
                if let record = self.configurations?.getargumentAllConfigurations()[i] {
                    if record.config!.offsiteServer.isEmpty == false {
                        if let sshport: Int = record.config!.sshport { port = sshport }
                        let (success, _) = self.testTCPconnection(record.config!.offsiteServer, port: port, timeout: 1)
                        if success {
                            self.indexBoolremoteserverOff!.append(false)
                        } else {
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

    init() {
        self.testconnectionsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.newprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}
