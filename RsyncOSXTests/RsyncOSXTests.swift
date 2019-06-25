//
//  RsyncOSXTests.swift
//  RsyncOSXTests
//
//  Created by Thomas Evensen on 25/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import XCTest
@testable import RsyncOSX

class RsyncOSXTests: XCTestCase {

    var outputprocess: OutputProcess?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test() {
        let storage = PersistentStorageAPI(profile: nil)
        if let userConfiguration =  storage.getUserconfiguration(readfromstorage: true) {
            _ = Userconfiguration(userconfigRsyncOSX: userConfiguration)
        }
        let configurations = Configurations(profile: "XCTest")
        // let schedules = Schedules(profile: "XCTest")
        
        let index = 1
        // let hiddenID = configurations.gethiddenID(index: index)
        let arguments = configurations.arguments4rsync(index: index, argtype: .argdryRun)
        let process = Rsync(arguments: arguments)
        self.outputprocess = OutputProcess()
        process.setdelegate(object: self)
        process.executeProcess(outputprocess: self.outputprocess)
    }

}

extension RsyncOSXTests: UpdateProgress {

    func processTermination() {
        print(self.outputprocess?.getOutput() ?? "")
    }

    func fileHandler() {
        //
    }

}
