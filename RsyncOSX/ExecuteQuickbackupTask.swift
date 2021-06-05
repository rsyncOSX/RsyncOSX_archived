//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

final class ExecuteQuickbackupTask: SetSchedules, SetConfigurations {
    var outputprocess: OutputfromProcess?
    var arguments: [String]?
    var config: Configuration?

    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void

    private func executetask() {
        if let dict: NSDictionary = SharedReference.shared.quickbackuptask {
            if let hiddenID: Int = dict.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int {
                let getconfigurations: [Configuration]? = configurations?.getConfigurations()
                guard getconfigurations != nil else { return }
                let configArray = getconfigurations!.filter { $0.hiddenID == hiddenID }
                guard configArray.count > 0 else { return }
                config = configArray[0]
                if hiddenID >= 0, config != nil {
                    arguments = ArgumentsSynchronize(config: config).argumentssynchronize(dryRun: false, forDisplay: false)
                    // Setting reference to finalize the job, finalize job is done when rsynctask ends (in process termination)
                    SharedReference.shared.completeoperation = CompleteQuickbackupTask(dict: dict)
                    globalMainQueue.async {
                        if let arguments = self.arguments {
                            let process = RsyncProcess(arguments: arguments,
                                                       config: self.config,
                                                       processtermination: self.processtermination,
                                                       filehandler: self.filehandler)
                            process.executeProcess(outputprocess: self.outputprocess)
                        }
                    }
                }
            }
        }
    }

    init(processtermination: @escaping () -> Void,
         filehandler: @escaping () -> Void,
         outputprocess: OutputfromProcess?)
    {
        self.processtermination = processtermination
        self.filehandler = filehandler
        self.outputprocess = outputprocess
        executetask()
    }
}
