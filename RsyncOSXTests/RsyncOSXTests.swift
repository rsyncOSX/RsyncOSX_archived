//
//  RsyncOSXTests.swift
//  RsyncOSXTests
//
//  Created by Thomas Evensen on 25/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import XCTest
@testable import RsyncOSX

class RsyncOSXTests: XCTestCase, SetConfigurations, SetSchedules {

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

    func testalllogs() {
        let schedules = ScheduleLoggData(sortascending: true)
        XCTAssertEqual(1, schedules.loggdata?.count, "Should be one")
    }

    func testselectedlog() {
        let schedules = ScheduleLoggData(hiddenID: 2, sortascending: true)
        XCTAssertEqual(1, schedules.loggdata?.count, "Should be one")
    }

    func testnologg() {
        let schedules = ScheduleLoggData(hiddenID: 1, sortascending: true)
        XCTAssertEqual(0, schedules.loggdata?.count, "Should be zero")
    }

    func testschedule() {
        let schedules = SchedulesXCTEST(profile: "XCTest")
        let today: Date = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
        schedules.addschedule(1, schedule: .once, start: tomorrow!)
        schedules.addschedule(1, schedule: .daily, start: tomorrow!)
        schedules.addschedule(1, schedule: .weekly, start: tomorrow!)
        XCTAssertEqual(3, schedules.getSchedule().count, "Should be three")
        let schedulesortedandexpanded = ScheduleSortedAndExpand(schedules: schedules)
        XCTAssertEqual("23h 59m", schedulesortedandexpanded.sortandcountscheduledonetask(1, profilename: nil, number: true), "23h 59m")
    }
}
