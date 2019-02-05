//
//  ViewControllerReference.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 05.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation
import Cocoa

enum ViewController {
    case vctabmain
    case vcloggdata
    case vcnewconfigurations
    case vctabschedule
    case vccopyfiles
    case vcssh
    case vcabout
    case vcbatch
    case vcprogressview
    case vcquickbackup
    case vcremoteinfo
    case vcsnapshot
    case vcallprofiles
    case vcencrypt
    case vcestimatingtasks
    case vcinfolocalremote
    case vcrestore
    case vcverify
    case vcalloutput
}

class ViewControllerReference {

    // Creates a singelton of this class
    class var  shared: ViewControllerReference {
        struct Singleton {
            static let instance = ViewControllerReference()
        }
        return Singleton.instance
    }

    // Reference to waiting tasks, required for cancel task
    var dispatchTaskWaiting: DispatchWorkItem?
    // Temporary storage of the first scheduled task
    var quickbackuptask: NSDictionary?
    // Download URL if new version is avaliable
    var URLnewVersion: String?
    // True if version 3.2.1 of rsync in /usr/local/bin
    var rsyncVer3: Bool = false
    // Optional path to rsync
    var rsyncPath: String?
    // No valid rsyncPath - true if no valid rsync is found
    var norsync: Bool = false
    // Detailed logging
    var detailedlogging: Bool = true
    // Temporary path for restore
    var restorePath: String?
    var completeoperation: CompleteQuickbackupTask?
    // rsync command
    var rsync: String = "rsync"
    var usrbinrsync: String = "/usr/bin/rsync"
    var usrlocalbinrsync: String = "/usr/local/bin/rsync"
    var configpath: String = "/Rsync/"
    // Loggfile
    var minimumlogging: Bool = false
    var fulllogging: Bool = false
    var logname: String = "rsynclog"
    var fileURL: URL?
    // String tasks
    var backup: String = "synchronize"
    var combined: String = "combined"
    var snapshot: String = "snapshot"
    // Mark number of days since last backup
    var marknumberofdayssince: Double = 5
    // rsync version string
    var rsyncversionstring: String?
    // rsync short version
    var rsyncversionshort: String?
    // filsize logfile warning
    var logfilesize: Int = 100000
    // Paths
    var pathrsyncosx: String?
    var pathrsyncosxsched: String?
    var namersyncosx = "RsyncOSX.app"
    var namersyncosssched = "RsyncOSXsched.app"
    // Mac serialnumer
    var macserialnumber: String?
    // Reference to main View
    private var viewControllertabMain: NSViewController?
    // Reference to Copy files
    private var viewControllerCopyFiles: NSViewController?
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
    //  Refereence to batchview
    private var viewControllerBatch: NSViewController?
    // ProgressView single task
    private var viewControllerProgressView: NSViewController?
    // Quick batch
    private var viewControllerQuickBatch: NSViewController?
    // Remote info
    private var viewControllerRemoteInfo: NSViewController?
    // Snapshot
    private var viewControllerSnapshot: NSViewController?
    // All profiles
    private var viewControllerAllProfiles: NSViewController?
    // Encrypt
     private var viewControllerEncrypt: NSViewController?
    // Estimating tasks
    private var viewControllerEstimatingTasks: NSViewController?
    // Local and remote info
    private var viewControllerInfoLocalRemote: NSViewController?
    // Restore
    private var viewControllerRestore: NSViewController?
    // Verify
    private var viewControllerVerify: NSViewController?
    // Alloutput
    private var viewControllerAlloutput: NSViewController?
    // Execute scheduled tasks in menu app, default off
    var executescheduledtasksmenuapp: Bool = false
    // True if menuapp is running
    var menuappisrunning: Bool = false
    // Day of week to keep snapshots
    var dayofweeksnapshots: StringDayofweek = .Sunday

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
        case .vccopyfiles:
            return self.viewControllerCopyFiles
        case .vcssh:
            return self.viewControllerSsh
        case .vcabout:
            return self.viewControllerAbout
        case .vcbatch:
            return self.viewControllerBatch
        case .vcprogressview:
            return self.viewControllerProgressView
        case .vcquickbackup:
            return self.viewControllerQuickBatch
        case .vcremoteinfo:
            return self.viewControllerRemoteInfo
        case .vcsnapshot:
            return self.viewControllerSnapshot
        case .vcallprofiles:
            return self.viewControllerAllProfiles
        case .vcencrypt:
            return self.viewControllerEncrypt
        case .vcestimatingtasks:
            return self.viewControllerEstimatingTasks
        case .vcinfolocalremote:
            return self.viewControllerInfoLocalRemote
        case .vcrestore:
            return self.viewControllerRestore
        case .vcverify:
            return self.viewControllerVerify
        case .vcalloutput:
            return self.viewControllerAlloutput
        }
    }

    func setvcref(viewcontroller: ViewController, nsviewcontroller: NSViewController) {
        switch viewcontroller {
        case .vctabmain:
            self.viewControllertabMain = nsviewcontroller
        case .vcloggdata:
            self.viewControllerLoggData = nsviewcontroller
        case .vcnewconfigurations:
            self.viewControllerNewConfigurations = nsviewcontroller
        case .vctabschedule:
            self.viewControllertabSchedule = nsviewcontroller
        case .vccopyfiles:
            self.viewControllerCopyFiles = nsviewcontroller
        case .vcssh:
            self.viewControllerSsh = nsviewcontroller
        case .vcabout:
            self.viewControllerAbout = nsviewcontroller
        case .vcbatch:
            self.viewControllerBatch = nsviewcontroller
        case .vcprogressview:
            self.viewControllerProgressView = nsviewcontroller
        case .vcquickbackup:
            self.viewControllerQuickBatch = nsviewcontroller
        case .vcremoteinfo:
            self.viewControllerRemoteInfo = nsviewcontroller
        case .vcsnapshot:
            self.viewControllerSnapshot = nsviewcontroller
        case .vcallprofiles:
            self.viewControllerAllProfiles = nsviewcontroller
        case .vcencrypt:
            self.viewControllerEncrypt = nsviewcontroller
        case .vcestimatingtasks:
            self.viewControllerEstimatingTasks = nsviewcontroller
        case .vcinfolocalremote:
            self.viewControllerInfoLocalRemote = nsviewcontroller
        case .vcrestore:
            self.viewControllerRestore = nsviewcontroller
        case .vcverify:
            self.viewControllerVerify = nsviewcontroller
        case .vcalloutput:
            self.viewControllerAlloutput = nsviewcontroller
        }
    }
}
