//
//  RsyncVersionString.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class RsyncVersionString {
    @MainActor
    private func rsyncversion(arguments: [String]?) async {
        let command = RsyncAsync(arguments: arguments,
                                 processtermination: processtermination)
        await command.executeProcess()
    }

    init() {
        if SharedReference.shared.norsync == false {
            Task {
                await rsyncversion(arguments: ["--version"])
            }
        }
    }
}

extension RsyncVersionString {
    func processtermination(data: [String]?) {
        guard data?.count ?? 0 > 0 else { return }
        if let rsyncversionshort = data?[0],
           let rsyncversionstring = data?.joined(separator: "\n")
        {
            SharedReference.shared.rsyncversionshort = rsyncversionshort
            SharedReference.shared.rsyncversionstring = rsyncversionstring
        }
        weak var shortstringDelegate: RsyncIsChanged?
        shortstringDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        shortstringDelegate?.rsyncischanged()
    }
}
