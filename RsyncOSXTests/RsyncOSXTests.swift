//
//  RsyncOSXTests.swift
//  RsyncOSXTests
//
//  Created by Thomas Evensen on 25/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import XCTest
@testable import RsyncOSX

class RsyncOSXTests: XCTestCase, SetConfigurations {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testnumberofargumentstorsync() {
        _ = Selectprofile(profile: "XCTest")
        let count = self.configurations?.arguments4rsync(index: 1, argtype: .argdryRun).count
        XCTAssertEqual(count, 14, "Should be equal to 14")
    }

    func testnumberofconfigurations() {
        let count = self.configurations?.getConfigurations().count
        XCTAssertEqual(count, 2, "Should be equal to 2")
    }
}
