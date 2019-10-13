//
//  ArgumentsRestore.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ArgumentsRestore: RsyncParametersProcess {

    var config: Configuration?

    func argumentsrestore(dryRun: Bool, forDisplay: Bool, tmprestore: Bool) -> [String] {
        self.localCatalog =  self.config!.localCatalog
        if  self.config!.snapshotnum != nil {
            self.remoteargssnapshot( self.config!)
        } else {
            self.remoteargs( self.config!)
        }
        self.setParameters1To6( self.config!, dryRun: dryRun, forDisplay: forDisplay, verify: false)
        self.setParameters8To14( self.config!, dryRun: dryRun, forDisplay: forDisplay)
        if tmprestore {
            self.argumentsforrestore(dryRun: dryRun, forDisplay: forDisplay, tmprestore: tmprestore)
        } else {
            self.argumentsforrestore(dryRun: dryRun, forDisplay: forDisplay, tmprestore: tmprestore)
        }
        return self.arguments!
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
