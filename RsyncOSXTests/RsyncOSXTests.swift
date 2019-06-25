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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storage = PersistentStorageAPI(profile: nil)
        if let userConfiguration =  storage.getUserconfiguration(readfromstorage: true) {
            _ = Userconfiguration(userconfigRsyncOSX: userConfiguration)
        }
        let configurations = Configurations(profile: "XCTest")
        let schedules = Schedules(profile: "XCTest")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}
