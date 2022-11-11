//
//  Checksynchronizedfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class Checksynchronizedfiles: SetConfigurations, Presentoutput {
    var index: Int?
    weak var indicatorDelegate: StartStopProgressIndicatorSingleTask?

    func checksynchronizedfiles() {
        guard SharedReference.shared.process == nil else { return }
        if let index = index,
           let hiddenID = configurations?.gethiddenID(index: index)
        {
            if let arguments = configurations?.arguments4verify(hiddenID: hiddenID) {
                Task {
                    await verifyandchanged(arguments: arguments)
                }
            }
        }
    }

    @MainActor
    private func verifyandchanged(arguments: [String]) async {
        indicatorDelegate?.startIndicator()
        let command = RsyncProcessAsync(arguments: arguments,
                                        config: nil,
                                        processtermination: processtermination)
        await command.executeProcess()
    }

    init(index: Int?) {
        self.index = index
        indicatorDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }
}

extension Checksynchronizedfiles {
    func processtermination(data: [String]?) {
        indicatorDelegate?.stopIndicator()
        presentoutputfromrsync(data: data)
    }
}
