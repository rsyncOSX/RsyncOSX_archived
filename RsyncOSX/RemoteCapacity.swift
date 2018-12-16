//
//  RemoteCapacity.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16/12/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class RemoteCapacity: SetConfigurations {

    var process: Process?
    var outputprocess: OutputProcess?
    var remotecapacity: [NSMutableDictionary]?

    private func getremotesizes(index: Int) {
        self.outputprocess = OutputProcess()
        let dict = self.configurations!.getConfigurationsDataSource()?[index]
        let config = Configuration(dictionary: dict!)
        let duargs: DuArgumentsSsh = DuArgumentsSsh(config: config)
        guard duargs.getArguments() != nil || duargs.getCommand() != nil else { return }
        let task: DuCommandSsh = DuCommandSsh(command: duargs.getCommand(), arguments: duargs.getArguments())
        task.executeProcess(outputprocess: self.outputprocess)
        self.process = task.getprocess()
    }
}

extension RemoteCapacity: UpdateProgress {
    func processTermination() {
        guard self.process != nil else { return }
        let numbers = RemoteNumbers(outputprocess: self.outputprocess)
        let result = NSMutableDictionary()
        result.setValue(numbers.getused(), forKey: "used")
        result.setValue(numbers.getavail(), forKey: "avail")
        result.setValue(numbers.getpercentavaliable(), forKey: "availpercent")
        self.remotecapacity?.append(result)
    }

    func fileHandler() {
        //
    }
}
