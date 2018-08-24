//
//  TCPconnections.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

// Protocol for doing a refresh in main view after testing for connectivity
protocol Connections: class {
    func displayConnections()
}

class TCPconnections: SetConfigurations, Delay {
    
}
