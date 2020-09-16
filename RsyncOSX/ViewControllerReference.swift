//
//  ViewControllerReference.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 05.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Cocoa
import Foundation

enum ViewController {
    case vctabmain
    case vcloggdata
    case vcnewconfigurations
    case vctabschedule
    case vcrestore
    case vcssh
    case vcsnapshot
    case vcverify
    case vcabout
    case vcprogressview
    case vcquickbackup
    case vcremoteinfo
    case vcallprofiles
    case vcestimatingtasks
    case vcinfolocalremote
    case vcalloutput
    case vcedit
    case vcrsyncparameters
}

final class ViewControllerReference {
    // Creates a singelton of this class
    class var shared: ViewControllerReference {
        struct Singleton {
            static let instance = ViewControllerReference()
        }
        return Singleton.instance
    }

    // Reference to the quick backup task
    var quickbackuptask: NSDictionary?
    // Download URL if new version is avaliable
    var URLnewVersion: String?
    // True if version 3.1.2 or 3.1.3 of rsync in /usr/local/bin
    var rsyncversion3: Bool = false
    // Optional path to rsync
    var localrsyncpath: String?
    // No valid rsyncPath - true if no valid rsync is found
    var norsync: Bool = false
    // rsync command
    var rsync: String = "rsync"
    var usrbinrsync: String = "/usr/bin/rsync"
    var usrlocalbinrsync: String = "/usr/local/bin/rsync"
    // Where RsyncOSX config files are stored
    var configpath: String = "/Rsync/"
    // New RsynOSX config files and path
    var newconfigpath: String = "/.rsyncosx/"
    var usenewconfigpath: Bool = true
    // Plistnames and key
    var scheduleplist: String = "/scheduleRsync.plist"
    var schedulekey: String = "Schedule"
    var configurationsplist: String = "/configRsync.plist"
    var configurationskey: String = "Catalogs"
    var userconfigplist: String = "/config.plist"
    var userconfigkey: String = "config"
    // Detailed logging
    var detailedlogging: Bool = true
    // Temporary path for restore
    var temporarypathforrestore: String?
    var completeoperation: CompleteQuickbackupTask?
    // Loggfile
    var minimumlogging: Bool = false
    var fulllogging: Bool = false
    var logname: String = "rsynclog"
    var fileURL: URL?
    // String tasks
    var synchronize: String = "synchronize"
    var snapshot: String = "snapshot"
    var syncremote: String = "syncremote"
    var synctasks: Set<String>
    // Mark number of days since last backup
    var marknumberofdayssince: Double = 5
    // rsync version string
    var rsyncversionstring: String?
    // rsync short version
    var rsyncversionshort: String?
    // filsize logfile warning
    var logfilesize: Int = 100_000
    // Extra lines in rsync output
    var extralines: Int = 18
    // Paths
    var pathrsyncosx: String?
    var pathrsyncosxsched: String?
    var namersyncosx = "RsyncOSX.app"
    var namersyncosssched = "RsyncOSXsched.app"
    // Mac serialnumer
    var macserialnumber: String?
    // Automatic execute local configurations in menuapp when mounting local volumes
    var automaticexecutelocalvolumes: Bool = false
    // True if menuapp is running
    var menuappisrunning: Bool = false
    // Initial start
    var initialstart: Int = 0
    // Setting environmentvariable for Process object
    var environment: String?
    var environmentvalue: String?
    // Check input when loading schedules and adding config
    var checkinput: Bool = false
    // Halt on error
    var haltonerror: Bool = false
    // Global SSH parameters
    var sshport: Int?
    var sshkeypathandidentityfile: String?
    // Check for network changes
    var monitornetworkconnection: Bool = false
    // Reference to the active process
    var process: Process?
    // Reference to main View
    private var viewControllertabMain: NSViewController?
    // Reference to Copy files
    private var viewControllerRestore: NSViewController?
    // Reference to the New tasks
    private var viewControllerNewConfigurations: NSViewController?
    // Reference to the  Schedule
    private var viewControllertabSchedule: NSViewController?
    // Which profile to use, if default nil
    private var viewControllerLoggData: NSViewController?
    // Reference to Ssh view
    private var viewControllerSsh: NSViewController?
    // Reference to About
    private var viewControllerAbout: NSViewController?
    // ProgressView single task
    private var viewControllerProgressView: NSViewController?
    // Quick backup
    private var viewControllerQuickbackup: NSViewController?
    // Remote info
    private var viewControllerRemoteInfo: NSViewController?
    // Snapshot
    private var viewControllerSnapshot: NSViewController?
    // All profiles
    private var viewControllerAllProfiles: NSViewController?
    // Estimating tasks
    private var viewControllerEstimatingTasks: NSViewController?
    // Local and remote info
    private var viewControllerInfoLocalRemote: NSViewController?
    // Verify
    private var viewControllerVerify: NSViewController?
    // Alloutput
    private var viewControllerAlloutput: NSViewController?
    // Edit
    private var viewControllerEdit: NSViewController?
    // Rsync parameters
    private var viewControllerRsyncParameters: NSViewController?

    func getvcref(viewcontroller: ViewController) -> NSViewController? {
        switch viewcontroller {
        case .vctabmain:
            return self.viewControllertabMain
        case .vcloggdata:
            return self.viewControllerLoggData
        case .vcnewconfigurations:
            return self.viewControllerNewConfigurations
        case .vctabschedule:
            return self.viewControllertabSchedule
        case .vcrestore:
            return self.viewControllerRestore
        case .vcssh:
            return self.viewControllerSsh
        case .vcabout:
            return self.viewControllerAbout
        case .vcprogressview:
            return self.viewControllerProgressView
        case .vcquickbackup:
            return self.viewControllerQuickbackup
        case .vcremoteinfo:
            return self.viewControllerRemoteInfo
        case .vcsnapshot:
            return self.viewControllerSnapshot
        case .vcallprofiles:
            return self.viewControllerAllProfiles
        case .vcestimatingtasks:
            return self.viewControllerEstimatingTasks
        case .vcinfolocalremote:
            return self.viewControllerInfoLocalRemote
        case .vcverify:
            return self.viewControllerVerify
        case .vcalloutput:
            return self.viewControllerAlloutput
        case .vcedit:
            return self.viewControllerEdit
        case .vcrsyncparameters:
            return self.viewControllerRsyncParameters
        }
    }

    func setvcref(viewcontroller: ViewController, nsviewcontroller: NSViewController?) {
        switch viewcontroller {
        case .vctabmain:
            self.viewControllertabMain = nsviewcontroller
        case .vcloggdata:
            self.viewControllerLoggData = nsviewcontroller
        case .vcnewconfigurations:
            self.viewControllerNewConfigurations = nsviewcontroller
        case .vctabschedule:
            self.viewControllertabSchedule = nsviewcontroller
        case .vcrestore:
            self.viewControllerRestore = nsviewcontroller
        case .vcssh:
            self.viewControllerSsh = nsviewcontroller
        case .vcabout:
            self.viewControllerAbout = nsviewcontroller
        case .vcprogressview:
            self.viewControllerProgressView = nsviewcontroller
        case .vcquickbackup:
            self.viewControllerQuickbackup = nsviewcontroller
        case .vcremoteinfo:
            self.viewControllerRemoteInfo = nsviewcontroller
        case .vcsnapshot:
            self.viewControllerSnapshot = nsviewcontroller
        case .vcallprofiles:
            self.viewControllerAllProfiles = nsviewcontroller
        case .vcestimatingtasks:
            self.viewControllerEstimatingTasks = nsviewcontroller
        case .vcinfolocalremote:
            self.viewControllerInfoLocalRemote = nsviewcontroller
        case .vcverify:
            self.viewControllerVerify = nsviewcontroller
        case .vcalloutput:
            self.viewControllerAlloutput = nsviewcontroller
        case .vcedit:
            self.viewControllerEdit = nsviewcontroller
        case .vcrsyncparameters:
            self.viewControllerRsyncParameters = nsviewcontroller
        }
    }

    init() {
        self.synctasks = Set<String>()
        self.synctasks = [self.synchronize, self.snapshot, self.syncremote]
    }
}
