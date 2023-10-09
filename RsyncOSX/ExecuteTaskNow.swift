//
//  ExecuteTaskNow.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

protocol DeinitExecuteTaskNow: AnyObject {
    func deinitexecutetasknow()
}

class ExecuteTaskNow: SetConfigurations, Presentoutput {
    weak var startstopindicators: StartStopProgressIndicatorSingleTask?
    weak var deinitDelegate: DeinitExecuteTaskNow?
    var index: Int?
    var command: RsyncProcessAsync?

    @MainActor
    func executetasknow() async {
        if let index = index,
           let hiddenID = configurations?.gethiddenID(index: index)
        {
            if let arguments = configurations?.arguments4rsync(hiddenID: hiddenID,
                                                               argtype: .arg)
            {
                startstopindicators?.startIndicatorExecuteTaskNow()
                command = RsyncProcessAsync(arguments: arguments,
                                            config: configurations?.getConfigurations()?[index],
                                            processtermination: processtermination)
                await command?.executeProcess()
            }
        }
    }

    init(index: Int) {
        self.index = index
        startstopindicators = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        deinitDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        Task {
            await executetasknow()
        }
    }

    func processtermination(data: [String]?) {
        startstopindicators?.stopIndicator()
        if let index = index {
            configurations?.setCurrentDateonConfiguration(index: index, outputfromrsync: data)
        }
        deinitDelegate?.deinitexecutetasknow()
        command = nil
        presentoutputfromrsync(data: data)
    }
}
