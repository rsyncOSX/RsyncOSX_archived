//
//  ProcessCmdVerify.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/06/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation
import Network

@available(OSX 10.14, *)
class ProcessCmdVerify: ProcessCmd {
    var config: Configuration?
    var monitor: NetworkMonitor?

    func executemonitornetworkconnection() {
        // guard self.arguments?.contains("--dry-run") ?? false == false else { return }
        guard self.config?.offsiteServer.isEmpty == false else { return }
        guard ViewControllerReference.shared.monitornetworkconnection == true else { return }
        self.monitor = NetworkMonitor()
        self.monitor?.netStatusChangeHandler = { [unowned self] in
            self.statusDidChange()
        }
    }

    func statusDidChange() {
        if self.monitor?.monitor?.currentPath.status != .satisfied {
            let output = OutputProcess()
            let string = "Network dropped: " + Date().long_localized_string_from_date()
            output.addlinefromoutput(str: string)
            _ = InterruptProcess(process: self.processReference, output: output)
        }
    }

    init(command: String?, arguments: [String]?, config: Configuration?) {
        super.init(command: command, arguments: arguments)
        self.config = config
        self.executemonitornetworkconnection()
    }

    deinit {
        self.monitor?.stopMonitoring()
        self.monitor = nil
    }
}
