//
//  ArgumentsLocalcatalogInfo.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ArgumentsLocalcatalogInfo: RsyncParameters {
    var config: Configuration?

    func argumentslocalcataloginfo(dryRun: Bool, forDisplay: Bool) -> [String]? {
        if let config = self.config {
            self.localCatalog = config.localCatalog
            self.setParameters1To6(config: config, dryRun: dryRun, forDisplay: forDisplay, verify: false)
            self.setParameters8To14(config: config, dryRun: dryRun, forDisplay: forDisplay)
            switch config.task {
            case ViewControllerReference.shared.synchronize:
                self.argumentsforsynchronize(dryRun: dryRun, forDisplay: forDisplay)
            case ViewControllerReference.shared.snapshot:
                self.argumentsforsynchronizesnapshot(dryRun: dryRun, forDisplay: forDisplay)
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
