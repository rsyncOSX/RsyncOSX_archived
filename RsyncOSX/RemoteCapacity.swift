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
    var index: Int?

    private func getremotesizes(index: Int) {
        self.outputprocess = OutputProcess()
        let config = self.configurations!.getConfigurations()[index]
        let duargs: DuArgumentsSsh = DuArgumentsSsh(config: config)
        guard duargs.getArguments() != nil || duargs.getCommand() != nil else { return }
        let task: DuCommandSsh = DuCommandSsh(command: duargs.getCommand(), arguments: duargs.getArguments())
        task.setdelegate(object: self)
        task.executeProcess(outputprocess: self.outputprocess)
        self.process = task.getprocess()
    }

    init() {
        guard self.configurations?.getConfigurationsDataSource() != nil else { return }
        self.remotecapacity = [NSMutableDictionary]()
        self.index = 0
        self.getremotesizes(index: self.index!)
    }
}

extension RemoteCapacity: UpdateProgress {
    func processTermination() {
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
