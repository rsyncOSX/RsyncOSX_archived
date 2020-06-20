//
//  NetworkMonitor.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/06/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation
import Network

protocol ReportNetworkMonitor: AnyObject {
    func noconnection()
}

@available(OSX 10.14, *)
class NetworkMonitor {
    let monitor = NWPathMonitor()
    weak var reportnetworkmonitorDelegate: ReportNetworkMonitor?

    init(object: Any) {
        self.reportnetworkmonitorDelegate = object as? ReportNetworkMonitor
        self.monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                self.reportnetworkmonitorDelegate?.noconnection()
                let output = OutputProcess()
                let string = "Network connection lost: " + Date().long_localized_string_from_date()
                output.addlinefromoutput(str: string)
                _ = Logging(output, true)
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        self.monitor.start(queue: queue)
    }

    deinit {
        print("deinit")
    }
}
