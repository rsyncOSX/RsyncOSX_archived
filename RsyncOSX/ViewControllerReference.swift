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
    var timerTaskWaiting: Timer?
    var dispatchTaskWaiting: DispatchWorkItem?
    // Temporary storage of the first scheduled task
    var scheduledTask: NSDictionary?
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
    // Kind of Operation method. eiher Timer or DispatchWork
    var operation: OperationObject = .dispatch
    // Reference to the Operation object
    // Reference is set in when Scheduled task is executed
    var completeoperation: CompleteScheduledOperation?
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
    // Mark number of days since last backup
    var marknumberofdayssince: Double = 5
    // rsync version string
    var rsyncversionstring: String?
    // rsync short version
    var rsyncversionshort: String?
    // Paths
    var pathrsyncosx: String?
    var pathrsyncosxsched: String?
    var namersyncosx = "RsyncOSX.app"
    var namersyncosssched = "RsyncOSXsched.app"
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
    // Execute scheduled apps in menu app
    var executescheduledappsinmenuapp: Bool = true

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
        }
    }
}
