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

    func argumentsrestore(dryRun: Bool, forDisplay: Bool, tmprestore: Bool) -> [String] {
        self.localCatalog =  self.config!.localCatalog
        if  self.config!.snapshotnum != nil {
            self.remoteargssnapshot(config: self.config!)
        } else {
            self.remoteargs(config: self.config!)
        }
        self.setParameters1To6(config: self.config!, dryRun: dryRun, forDisplay: forDisplay, verify: false)
        self.setParameters8To14(config: self.config!, dryRun: dryRun, forDisplay: forDisplay)
        self.argumentsforrestore(dryRun: dryRun, forDisplay: forDisplay, tmprestore: tmprestore)
        return self.arguments ?? [""]
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
