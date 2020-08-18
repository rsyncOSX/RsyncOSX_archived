//
//  RsyncOSXTests.swift
//  RsyncOSXTests
//
//  Created by Thomas Evensen on 25/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length trailing_comma

@testable import RsyncOSX
import XCTest

class RsyncOSXTests: XCTestCase, SetConfigurations, SetSchedules {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        _ = Selectprofile(profile: "XCTest", selectedindex: nil)
        ViewControllerReference.shared.temporarypathforrestore = "/temporaryrestore"
        ViewControllerReference.shared.checkinput = true
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
        XCTAssertEqual(count, 4, "Should be equal to 4")
    }

    func testargumentsdryrun() {
        let arguments = ["--archive", "--verbose", "--compress", "--delete", "-e", "ssh -p 22", "--exclude=.git",
                         "--backup", "--backup-dir=../backup_XCTest", "--suffix=_$(date +%Y-%m-%d.%H.%M)",
                         "--dry-run", "--stats", "/Users/thomas/XCTest/",
                         "thomas@10.0.0.57:/backup2/RsyncOSX/XCTest/"]
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

    func testargumentsrestore() {
        let arguments = ["--archive", "--verbose", "--compress", "--delete", "-e", "ssh -p 22", "--exclude=.git",
                         "--backup", "--backup-dir=../backup_XCTest", "--suffix=_$(date +%Y-%m-%d.%H.%M)",
                         "--stats", "thomas@web:~/XCTest/", "/Users/thomas/XCTest/"]
        XCTAssertEqual(arguments, self.configurations?.arguments4restore(index: 1, argtype: .arg),
                       "Arguments should be equal")
    }

    func testargumentsverify() {
        let arguments = ["--checksum", "--recursive", "--verbose", "--compress", "--delete", "-e", "ssh -p 22",
                         "--exclude=.git", "--backup", "--backup-dir=../backup_XCTest",
                         "--suffix=_$(date +%Y-%m-%d.%H.%M)", "--dry-run", "--stats", "/Users/thomas/XCTest/",
                         "thomas@web:~/XCTest/"]
        XCTAssertEqual(arguments, self.configurations?.arguments4verify(index: 1),
                       "Arguments should be equal")
    }

    func testargumentsrestore0() {
        let arguments = ["--archive", "--verbose", "--compress", "--delete", "-e", "ssh -p 22", "--exclude=.git",
                         "--backup", "--backup-dir=../backup_XCTest", "--suffix=_$(date +%Y-%m-%d.%H.%M)",
                         "--stats", "thomas@10.0.0.57:/backup2/RsyncOSX/XCTest/", "/Users/thomas/XCTest/"]
        XCTAssertEqual(arguments, self.configurations?.arguments4restore(index: 0, argtype: .arg),
                       "Arguments should be equal")
    }

    func testargumentsrestoretmp0() {
        let arguments = ["--archive", "--verbose", "--compress", "--delete", "-e", "ssh -p 22", "--exclude=.git",
                         "--backup", "--backup-dir=../backup_XCTest", "--suffix=_$(date +%Y-%m-%d.%H.%M)",
                         "--stats", "thomas@10.0.0.57:/backup2/RsyncOSX/XCTest/", "/temporaryrestore"]
        XCTAssertEqual(arguments, self.configurations?.arguments4tmprestore(index: 0, argtype: .arg),
                       "Arguments should be equal")
    }

    func testargumentssyncremoterealrun() {
        let arguments = ["--archive", "--verbose", "--compress", "--delete", "-e", "ssh -p 22", "--exclude=.git",
                         "--stats", "thomas@web:~/remotecatalog/", "/Users/thomas/localcatalog/"]
        XCTAssertEqual(arguments, self.configurations?.arguments4rsync(index: 2, argtype: .arg),
                       "Arguments should be equal")
    }

    func testargumentssnapshot() {
        let arguments = ["--archive", "--verbose", "--compress", "--delete", "-e", "ssh -i ~/.ssh_rsyncosx/rsyncosx -p 22",
                         "--stats", "--link-dest=~/XCTest/99", "/Users/thomas/XCTest/", "thomas@10.0.0.57:~/XCTest/100"]
        XCTAssertEqual(arguments, self.configurations?.arguments4rsync(index: 3, argtype: .arg),
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

    func testaddschedule() {
        let schedules = SchedulesXCTEST(profile: "XCTest")
        let today: Date = Date()
        let tomorrow = Calendar.current.date(byAdding: .hour, value: 12, to: today)
        let dayaftertomorrow = Calendar.current.date(byAdding: .day, value: 2, to: today)
        schedules.addschedule(hiddenID: 1, schedule: .daily, start: dayaftertomorrow!)
        schedules.addschedule(hiddenID: 1, schedule: .weekly, start: dayaftertomorrow!)
        schedules.addschedule(hiddenID: 1, schedule: .once, start: tomorrow!)
        XCTAssertEqual(3, schedules.getSchedule()?.count, "Should be three")
        let schedulesortedandexpanded = ScheduleSortedAndExpand(schedules: schedules)
        XCTAssertEqual("11h 59m", schedulesortedandexpanded.sortandcountscheduledonetask(1, profilename: nil, number: true), "11h 59m")
    }

    func testaddconfig() {
        // Local snapshot only, if not connected no snapshot task
        let configurations = ConfigurationsXCTEST(profile: "XCTest")
        let dict: NSMutableDictionary = [
            "task": ViewControllerReference.shared.snapshot,
            "backupID": "backupID",
            "localCatalog": "localCatalog",
            "offsiteCatalog": "offsiteCatalog",
            // "offsiteServer": "offsiteServer",
            // "offsiteUsername": "offsiteUsername",
            "parameter1": "parameter1",
            "parameter2": "parameter2",
            "parameter3": "parameter3",
            "parameter4": "parameter4",
            "parameter5": "parameter5",
            "parameter6": "parameter6",
            "dryrun": "dryrun",
            "dateRun": "",
        ]
        dict.setValue(1, forKey: "snapshotnum")
        configurations.addNewConfigurations(dict)
        let count = configurations.getConfigurations().count
        XCTAssertEqual(count, 5, "Should be equal to 5")
    }

    func testaddnoconfig1() {
        // Missing "offsiteUsername": "offsiteUsername",
        let configurations = ConfigurationsXCTEST(profile: "XCTest")
        let dict: NSMutableDictionary = [
            "task": ViewControllerReference.shared.snapshot,
            "backupID": "backupID",
            "localCatalog": "localCatalog",
            "offsiteCatalog": "offsiteCatalog",
            "offsiteServer": "offsiteServer",
            "parameter1": "parameter1",
            "parameter2": "parameter2",
            "parameter3": "parameter3",
            "parameter4": "parameter4",
            "parameter5": "parameter5",
            "parameter6": "parameter6",
            "dryrun": "dryrun",
            "dateRun": "",
        ]
        dict.setValue(1, forKey: "snapshotnum")
        configurations.addNewConfigurations(dict)
        let count = configurations.getConfigurations().count
        XCTAssertEqual(count, 4, "Should be equal to 4")
    }

    func testaddnoconfig2() {
        // Missing  "offsiteServer": "offsiteServer"
        let configurations = ConfigurationsXCTEST(profile: "XCTest")
        let dict: NSMutableDictionary = [
            "task": ViewControllerReference.shared.snapshot,
            "backupID": "backupID",
            "localCatalog": "localCatalog",
            "offsiteCatalog": "offsiteCatalog",
            "offsiteUsername": "offsiteUsername",
            "parameter1": "parameter1",
            "parameter2": "parameter2",
            "parameter3": "parameter3",
            "parameter4": "parameter4",
            "parameter5": "parameter5",
            "parameter6": "parameter6",
            "dryrun": "dryrun",
            "dateRun": "",
        ]
        dict.setValue(1, forKey: "snapshotnum")
        configurations.addNewConfigurations(dict)
        let count = configurations.getConfigurations().count
        XCTAssertEqual(count, 4, "Should be equal to 4")
    }

    func testreorgschedulesbefore() {
        ViewControllerReference.shared.temporarypathforrestore = "/temporaryrestore"
        ViewControllerReference.shared.checkinput = false
        _ = Selectprofile(profile: "Datacheck", selectedindex: nil)
        let count = CountSchedulesandLogs()
        XCTAssertEqual(19, count.schedulerecords, "Should be 19")
        XCTAssertEqual(299, count.logrecords, "Should be 299")
    }

    func testreorgschedulesafter() {
        ViewControllerReference.shared.temporarypathforrestore = "/temporaryrestore"
        ViewControllerReference.shared.checkinput = true
        _ = Selectprofile(profile: "Datacheck", selectedindex: nil)
        let count = CountSchedulesandLogs()
        XCTAssertEqual(10, count.schedulerecords, "Should be 10")
        XCTAssertEqual(299, count.logrecords, "Should be 299")
    }
}
