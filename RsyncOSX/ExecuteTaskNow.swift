//
//  ExecuteTaskNow.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

protocol DeinitExecuteTaskNow: AnyObject {
    func deinitexecutetasknow()
}

class ExecuteTaskNow: SetConfigurations {
    weak var setprocessDelegate: SendOutputProcessreference?
    weak var startstopindicators: StartStopProgressIndicatorSingleTask?
    weak var deinitDelegate: DeinitExecuteTaskNow?
    var outputprocess: OutputProcess?
    var index: Int?

    func executetasknow() {
        if let index = self.index {
            self.outputprocess = OutputProcessRsync()
            if let arguments = self.configurations?.arguments4rsync(index: index, argtype: .arg) {
                let process = RsyncClosure(arguments: arguments,
                                           config: self.configurations?.getConfigurations()[index],
                                           processtermination: self.processtermination,
                                           filehandler: self.filehandler)
                process.executeProcess(outputprocess: self.outputprocess)
                self.startstopindicators?.startIndicatorExecuteTaskNow()
                self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
            }
        }
    }

    init(index: Int) {
        self.index = index
        self.setprocessDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.startstopindicators = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.deinitDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.executetasknow()
    }
}

extension ExecuteTaskNow {
    func processtermination() {
        print("processtermination ExecuteTaskNow")
        self.startstopindicators?.stopIndicator()
        if let index = self.index {
            self.configurations?.setCurrentDateonConfiguration(index: index, outputprocess: self.outputprocess)
        }
        self.deinitDelegate?.deinitexecutetasknow()
    }

    func filehandler() {
        print("filehandler ExecuteTaskNow")
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
