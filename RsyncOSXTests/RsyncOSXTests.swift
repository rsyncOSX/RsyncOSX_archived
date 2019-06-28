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
         _ = Selectprofile(profile: "XCTest")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testnumberofargumentstorsync() {
        let count = self.configurations?.arguments4rsync(index: 0, argtype: .argdryRun).count
        XCTAssertEqual(count, 14, "Should be equal to 14")
    }

    func testnumberofconfigurations() {
        let count = self.configurations?.getConfigurations().count
        XCTAssertEqual(count, 2, "Should be equal to 2")
    }

    func testargumentsdryrun() {
        let arguments = ["--archive", "--verbose", "--compress", "--delete", "-e", "ssh -p 22", "--exclude=.git",
                         "--backup", "--backup-dir=../backup_XCTest", "--suffix=_$(date +%Y-%m-%d.%H.%M)", "--dry-run",
                         "--stats", "/Users/thomas/XCTest/", "thomas@10.0.0.57:/backup2/RsyncOSX/XCTest/"]
        XCTAssertEqual(arguments, self.configurations?.arguments4rsync(index: 0, argtype: .argdryRun),
                       "Arguments should be equal")
    }

    func testargumentsrealrun() {
        let arguments = ["--archive", "--verbose", "--compress", "--delete", "-e", "ssh -p 22", "--exclude=.git",
                         "--backup", "--backup-dir=../backup_XCTest", "--suffix=_$(date +%Y-%m-%d.%H.%M)",
                         "--stats", "/Users/thomas/XCTest/", "thomas@web:~/XCTest/"]
        XCTAssertEqual(arguments, self.configurations?.arguments4rsync(index: 1, argtype: .arg),
                       "Arguments should be equal")
    }

}
