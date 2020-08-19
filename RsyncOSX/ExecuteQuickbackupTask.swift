//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

// The Operation object to execute a scheduled job.
// The object get the hiddenID for the job, reads the
// rsync parameters for the job, creates a object to finalize the
// job after execution as logging. The reference to the finalize object
// is set in the static object. The finalize object is invoked
// when the job discover (observs) the termination of the process.

final class ExecuteQuickbackupTask: SetSchedules, SetConfigurations {
    let outputprocess = OutputProcessRsync()
    var arguments: [String]?
    var config: Configuration?

    private func executetask(updateprogress: UpdateProgress?) {
        if let dict: NSDictionary = ViewControllerReference.shared.quickbackuptask {
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                let getconfigurations: [Configuration]? = configurations?.getConfigurations()
                guard getconfigurations != nil else { return }
                let configArray = getconfigurations!.filter { ($0.hiddenID == hiddenID) }
                guard configArray.count > 0 else { return }
                self.config = configArray[0]
                if hiddenID >= 0, self.config != nil {
                    self.arguments = ArgumentsSynchronize(config: self.config).argumentssynchronize(dryRun: false, forDisplay: false)
                    // Setting reference to finalize the job, finalize job is done when rsynctask ends (in process termination)
                    ViewControllerReference.shared.completeoperation = CompleteQuickbackupTask(dict: dict)
                    globalMainQueue.async {
                        if let arguments = self.arguments {
                            weak var sendprocess: SendOutputProcessreference?
                            sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                            let process = RsyncVerify(arguments: arguments, config: self.config)
                            if updateprogress != nil {
                                process.setdelegate(object: updateprogress!)
                                let sendprocessreference = updateprogress as? SendOutputProcessreference
                                sendprocessreference?.sendoutputprocessreference(outputprocess: self.outputprocess)
                            }
                            process.executeProcess(outputprocess: self.outputprocess)
                            sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
                        }
                    }
                }
            }
        }
    }

    init() {
        self.executetask(updateprogress: nil)
    }

    init(updateprogress: UpdateProgress?) {
        self.executetask(updateprogress: updateprogress)
    }
}
