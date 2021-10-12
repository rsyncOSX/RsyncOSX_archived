//
//  TCPconnections.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

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

    init() {
        testconnectionsDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        newprofileDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }
}
