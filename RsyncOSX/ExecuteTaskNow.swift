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

class ExecuteTaskNow: SetConfigurations {
    weak var setprocessDelegate: SendOutputProcessreference?
    weak var startstopindicators: StartStopProgressIndicatorSingleTask?
    weak var deinitDelegate: DeinitExecuteTaskNow?
    var outputprocess: OutputfromProcess?
    var index: Int?
    var command: RsyncProcess?

    func executetasknow() {
        if let index = index,
           let hiddenID = configurations?.gethiddenID(index: index)
        {
            outputprocess = OutputfromProcessRsync()
            if let arguments = configurations?.arguments4rsync(hiddenID: hiddenID,
                                                               argtype: .arg)
            {
                command = RsyncProcess(arguments: arguments,
                                       config: configurations?.getConfigurations()?[index],
                                       processtermination: processtermination,
                                       filehandler: filehandler)
                command?.executeProcess(outputprocess: outputprocess)
                startstopindicators?.startIndicatorExecuteTaskNow()
                setprocessDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
            }
        }
    }

    init(index: Int) {
        self.index = index
        setprocessDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        startstopindicators = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        deinitDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        executetasknow()
    }
}

extension ExecuteTaskNow {
    func processtermination() {
        startstopindicators?.stopIndicator()
        if let index = index {
            configurations?.setCurrentDateonConfiguration(index: index, outputprocess: outputprocess)
        }
        deinitDelegate?.deinitexecutetasknow()
        command = nil
    }

    func filehandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
