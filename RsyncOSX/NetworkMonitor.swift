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
protocol NetworkCheckObserver: AnyObject {
    func statusDidChange(status: NWPath.Status)
}

@available(OSX 10.14, *)
class NetworkMonitor {
    struct NetworkChangeObservation {
        weak var observer: NetworkCheckObserver?
    }

    private var monitor = NWPathMonitor()
    private var observations = [ObjectIdentifier: NetworkChangeObservation]()
    var currentStatus: NWPath.Status {
        return monitor.currentPath.status
    }

    init() {
        self.monitor.pathUpdateHandler = { [unowned self] path in
            for (id, observations) in self.observations {
                // If any observer is nil, remove it from the list of observers
                guard let observer = observations.observer else {
                    self.observations.removeValue(forKey: id)
                    continue
                }
                DispatchQueue.main.async {
                    observer.statusDidChange(status: path.status)
                }
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    func addObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = NetworkChangeObservation(observer: observer)
    }

    func removeObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}
