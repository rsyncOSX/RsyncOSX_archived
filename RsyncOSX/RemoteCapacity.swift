import Foundation

final class RemoteCapacity: Connected {
    var outputprocess: OutputProcess?
    var config: Configuration?
    var command: OtherProcessCmdClosure?

    func getremotecapacity() {
        if let config = self.config {
            guard ViewControllerReference.shared.process == nil else { return }
            self.outputprocess = OutputProcess()
            // let config = Configuration(dictionary: dict)
            guard self.connected(config: config) == true else { return }
            let duargs = DuArgumentsSsh(config: self.config!)
            guard duargs.getArguments() != nil || duargs.getCommand() != nil else { return }

            self.command = OtherProcessCmdClosure(command: duargs.getCommand(),
                                                  arguments: duargs.getArguments(),
                                                  processtermination: self.processtermination,
                                                  filehandler: self.filehandler)
            self.command?.executeProcess(outputprocess: self.outputprocess)
        }
    }

    init(config: Configuration) {
        self.config = config
    }
}

extension RemoteCapacity {
    func processtermination() {
        guard ViewControllerReference.shared.process != nil else { return }
        let numbers = RemoteNumbers(outputprocess: self.outputprocess)
        self.command = nil
    }

    func filehandler() {
        //
    }
}
