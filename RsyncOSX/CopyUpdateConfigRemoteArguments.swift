//
//  CopyUpdateConfigRemoteArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03.08.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class CopyUpdateConfigRemoteArguments: RsyncArguments {
    init(config: Configuration) {
        let filename = Readwritefiles(task: .configuration)
        let localpath = filename.getpath()
        let remotepath = "##.Rsync/" + Tools.shared.getMacSerialNumber() + "/"
        super.init(config: config, remoteFile: remotepath, localCatalog: localpath, drynrun: true)
    }
}
