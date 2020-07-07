//
//  RemoteCapacity.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16/12/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class RemoteCapacity: SetConfigurations, Connected {
    var outputprocess: OutputProcess?
    var remotecapacity: [NSMutableDictionary]?
    var index: Int?
    var object: UpdateProgress?

    func enableremotecapacitybutton() -> Bool {
        if self.index! < self.configurations!.getConfigurations().count {
            return false
        } else {
            return true
        }
    }

    private func getremotesizes(index: Int) {
        self.outputprocess = OutputProcess()
        if let config = self.configurations?.getConfigurations()[index] {
            if self.connected(config: config) == true, config.offsiteServer.isEmpty == false {
                let duargs: DuArgumentsSsh = DuArgumentsSsh(config: config)
                guard duargs.getArguments() != nil || duargs.getCommand() != nil else { return }
                let task: DuCommandSsh = DuCommandSsh(command: duargs.getCommand(), arguments: duargs.getArguments())
                task.setdelegate(object: self.object!)
                task.executeProcess(outputprocess: self.outputprocess)
            } else {
                self.processTermination()
            }
        }
    }

    init(object: UpdateProgress) {
        guard self.configurations?.getConfigurationsDataSource() != nil else { return }
        guard (self.configurations?.getConfigurations().count ?? -1) > 0 else { return }
        self.object = object
        self.remotecapacity = [NSMutableDictionary]()
        self.index = 0
        self.getremotesizes(index: self.index ?? 0)
    }
}

extension RemoteCapacity: UpdateProgress {
    func processTermination() {
        let numbers = RemoteNumbers(outputprocess: self.outputprocess)
        let result = NSMutableDictionary()
        let offsiteServer = self.configurations!.getConfigurations()[index!].offsiteServer
        let offsiteCatalog = self.configurations!.getConfigurations()[index!].offsiteCatalog
        result.setValue(offsiteServer, forKey: "offsiteServer")
        result.setValue(offsiteCatalog, forKey: "offsiteCatalog")
        result.setValue(numbers.getused(), forKey: "used")
        result.setValue(numbers.getavail(), forKey: "avail")
        result.setValue(numbers.getpercentavaliable(), forKey: "availpercent")
        self.remotecapacity?.append(result)
        self.index = self.index! + 1
        guard self.index! < self.configurations!.getConfigurations().count else { return }
        self.getremotesizes(index: self.index!)
    }

    func fileHandler() {
        //
    }
}
