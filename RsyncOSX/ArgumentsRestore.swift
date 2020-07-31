//
//  ArgumentsRestore.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ArgumentsRestore: RsyncParameters {
    var config: Configuration?

    func argumentsrestore(dryRun: Bool, forDisplay: Bool, tmprestore: Bool) -> [String]? {
        if let config = self.config {
            self.localCatalog = config.localCatalog
            if config.snapshotnum != nil {
                self.remoteargssnapshot(config: config)
            } else {
                self.remoteargs(config: config)
            }
            self.setParameters1To6(config: config, dryRun: dryRun, forDisplay: forDisplay, verify: false)
            self.setParameters8To14(config: config, dryRun: dryRun, forDisplay: forDisplay)
            self.argumentsforrestore(dryRun: dryRun, forDisplay: forDisplay, tmprestore: tmprestore)
            return self.arguments
        }
        return nil
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
