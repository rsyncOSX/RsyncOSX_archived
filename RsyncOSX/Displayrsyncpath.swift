//
//  Verifyrsyncpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.07.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

protocol Setinfoaboutrsync: AnyObject {
    func setinfoaboutrsync()
}

enum RsynccommandDisplay {
    case synchronize
    case restore
    case verify
}

struct Displayrsyncpath: SetConfigurations {
    var displayrsyncpath: String?

    init(index _: Int, display: RsynccommandDisplay) {
        var str: String?
        if let config = self.configurations?.getargumentAllConfigurations(),
           self.configurations?.getargumentAllConfigurations().count ?? 0 > 0
        {
            str = Getrsyncpath().rsyncpath ?? ""
            str = str! + " "
            switch display {
            case .synchronize:
                if let count = config[0].argdryRunDisplay?.count {
                    for i in 0 ..< count {
                        str = str! + config[0].argdryRunDisplay![i]
                    }
                }
            case .restore:
                if let count = config[0].restoredryRunDisplay?.count {
                    for i in 0 ..< count {
                        str = str! + config[0].restoredryRunDisplay![i]
                    }
                }
            case .verify:
                if let count = config[0].verifyDisplay?.count {
                    for i in 0 ..< count {
                        str = str! + config[0].verifyDisplay![i]
                    }
                }
            }
            self.displayrsyncpath = str
        }
    }
}
