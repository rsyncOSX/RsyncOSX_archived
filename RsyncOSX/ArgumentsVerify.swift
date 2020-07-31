//
//  ArgumentsVerify.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ArgumentsVerify: RsyncParameters {
    var config: Configuration?

    func argumentsverify(forDisplay: Bool) -> [String]? {
        if let config = self.config {
            self.localCatalog = config.localCatalog
            self.remoteargs(config: config)
            self.setParameters1To6(config: config, dryRun: true, forDisplay: forDisplay, verify: true)
            self.setParameters8To14(config: config, dryRun: true, forDisplay: forDisplay)
            switch config.task {
            case ViewControllerReference.shared.synchronize:
                self.argumentsforsynchronize(dryRun: true, forDisplay: forDisplay)
            case ViewControllerReference.shared.snapshot:
                self.linkdestparameter(config: config, verify: true)
                self.argumentsforsynchronizesnapshot(dryRun: true, forDisplay: forDisplay)
            case ViewControllerReference.shared.syncremote:
                return []
            default:
                break
            }
            return self.arguments
        }
        return nil
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
