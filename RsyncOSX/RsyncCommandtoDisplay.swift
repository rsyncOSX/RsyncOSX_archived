//
//  Verifyrsyncpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.07.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

protocol Setinfoaboutrsync: AnyObject {
    func setinfoaboutrsync()
}

enum RsyncCommand {
    case synchronize
    case restore
    case verify
}

struct RsyncCommandtoDisplay: SetConfigurations {
    private var rsynccommand: String?

    func getrsyncommand() -> String? {
        return rsynccommand
    }

    init(_ display: RsyncCommand,
         _ config: Configuration)
    {
        var str = ""
        str = Getrsyncpath().rsyncpath ?? ""
        str += " "
        switch display {
        case .synchronize:
            if let arguments = ArgumentsSynchronize(config: config).argumentssynchronize(dryRun: true, forDisplay: true) {
                for i in 0 ..< arguments.count {
                    str += arguments[i]
                }
            }
        case .restore:
            if let arguments = ArgumentsRestore(config: config).argumentsrestore(dryRun: true, forDisplay: false, tmprestore: false) {
                for i in 0 ..< arguments.count {
                    str += arguments[i]
                }
            }
        case .verify:
            if let arguments = ArgumentsVerify(config: config).argumentsverify(forDisplay: true) {
                for i in 0 ..< arguments.count {
                    str += arguments[i]
                }
            }
        }
        rsynccommand = str
    }
}
