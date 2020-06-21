//
//  NetworkMonitor.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/06/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation
import Network

@available(OSX 10.14, *)
class NetworkMonitor {
    var monitor: NWPathMonitor?
    var netStatusChangeHandler: (() -> Void)?

    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }

    var interfaceType: NWInterface.InterfaceType? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.filter {
            monitor.currentPath.usesInterfaceType($0.type)
        }.first?.type
    }

    var availableInterfacesTypes: [NWInterface.InterfaceType]? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map { $0.type }
    }

    var isExpensive: Bool {
        return monitor?.currentPath.isExpensive ?? false
    }

    init() {
        self.startMonitoring()
    }

    deinit {
        self.stopMonitoring()
    }

    func startMonitoring() {
        self.monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetStatus_Monitor")
        self.monitor?.start(queue: queue)
        self.monitor?.pathUpdateHandler = { _ in
            self.netStatusChangeHandler?()
        }
    }

    func stopMonitoring() {
        if let monitor = self.monitor {
            monitor.cancel()
            self.monitor = nil
        }
    }
}
