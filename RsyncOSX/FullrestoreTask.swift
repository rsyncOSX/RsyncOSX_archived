// swiftlint:disable line_length

import Foundation

final class FullrestoreTask: SetConfigurations {
    private var config: Configuration?
    var arguments: [String]?
    var dryrun: Bool = true
    weak var sendprocess: SendOutputProcessreference?
    var process: RsyncProcessCmdClosure?
    var outputprocess: OutputProcess?

    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void

    func executerestore(index: Int) {
        if self.dryrun {
            self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .argdryRun)
            let lastindex = (self.arguments?.count ?? 0) - 1
            guard lastindex > -1 else { return }
            self.arguments?[lastindex] = ViewControllerReference.shared.temporarypathforrestore ?? ""
        } else {
            self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .arg)
            let lastindex = (self.arguments?.count ?? 0) - 1
            guard lastindex > -1 else { return }
            self.arguments?[lastindex] = ViewControllerReference.shared.temporarypathforrestore ?? ""
        }
        if let arguments = self.arguments {
            self.process = RsyncProcessCmdClosure(arguments: arguments, config: nil, processtermination: processtermination, filehandler: filehandler)
            self.outputprocess = OutputProcessRsync()
            self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
            self.process?.executeProcess(outputprocess: self.outputprocess)
        }
    }

    init(dryrun: Bool, processtermination: @escaping () -> Void, filehandler: @escaping () -> Void) {
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.processtermination = processtermination
        self.filehandler = filehandler
        self.dryrun = dryrun
    }
}
