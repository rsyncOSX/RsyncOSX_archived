// swiftlint:disable line_length

import Foundation

final class FullrestoreTask: SetConfigurations {
    private var config: Configuration?
    var arguments: [String]?
    var dryrun: Bool = true
    weak var sendprocess: SendOutputProcessreference?
    var process: RsyncProcess?
    var outputprocess: OutputfromProcess?

    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void

    func executerestore(index: Int) {
        if let hiddenID = configurations?.gethiddenID(index: index) {
            if dryrun {
                arguments = configurations?.arguments4tmprestore(hiddenID: hiddenID,
                                                                 argtype: .argdryRun)
                let lastindex = (arguments?.count ?? 0) - 1
                guard lastindex > -1 else { return }
                arguments?[lastindex] = SharedReference.shared.pathforrestore ?? ""
            } else {
                arguments = configurations?.arguments4tmprestore(hiddenID: hiddenID,
                                                                 argtype: .arg)
                let lastindex = (arguments?.count ?? 0) - 1
                guard lastindex > -1 else { return }
                arguments?[lastindex] = SharedReference.shared.pathforrestore ?? ""
            }
            if let arguments = arguments {
                process = RsyncProcess(arguments: arguments, config: nil, processtermination: processtermination, filehandler: filehandler)
                outputprocess = OutputfromProcessRsync()
                sendprocess?.sendoutputprocessreference(outputprocess: outputprocess)
                process?.executeProcess(outputprocess: outputprocess)
            }
        }
    }

    init(dryrun: Bool, processtermination: @escaping () -> Void, filehandler: @escaping () -> Void) {
        sendprocess = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.processtermination = processtermination
        self.filehandler = filehandler
        self.dryrun = dryrun
    }
}
