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
        let localCatalog = filename.getfilenameandpath()
        let remoteFile = "/Rsync/" + Tools.shared.getMacSerialNumber() + "/configRsync.plist"
        super.init(config: config, remoteFile: remoteFile, localCatalog: localCatalog, drynrun: false)
    }
}
