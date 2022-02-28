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
    case vcschedule
    case vcrestore
    case vcssh
    case vcsnapshot
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
    case vcsidebar
    case vcrsynccommand
}

final class SharedReference {
    // Creates a singelton of this class
    class var shared: SharedReference {
        struct Singleton {
            static let instance = SharedReference()
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
    let rsync: String = "rsync"
    let usrbinrsync: String = "/usr/bin/rsync"
    let usrlocalbinrsync: String = "/usr/local/bin/rsync"
    let opthomebrewbinrsync: String = "/opt/homebrew/bin/rsync"
    var macosarm: Bool = false
    // Where RsyncOSX config files are stored
    let configpath: String = "/.rsyncosx/"
    // User config PLIST file
    let userconfigplist: String = "/config.plist"
    let userconfigkey: String = "config"
    // User config JSON file
    let userconfigjson: String = "rsyncosxconfig.json"
    // Detailed logging
    var detailedlogging: Bool = true
    // Temporary path for restore
    var pathforrestore: String?
    var completeoperation: CompleteQuickbackupTask?
    // Loggfile
    var minimumlogging: Bool = false
    var fulllogging: Bool = false
    var logname: String = "rsynclog.txt"
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
    let namersyncosx = "RsyncOSX.app"
    let namersyncosssched = "RsyncOSXsched.app"
    // Mac serialnumer
    var macserialnumber: String?
    // True if menuapp is running
    var menuappisrunning: Bool = false
    // Initial start
    var initialstart: Int = 0
    // Setting environmentvariable for Process object
    var environment: String?
    var environmentvalue: String?
    // Check input when loading schedules
    // var checkinput: Bool = false
    // Halt on error
    var haltonerror: Bool = false
    // Global SSH parameters
    var sshport: Int?
    var sshkeypathandidentityfile: String?
    // Check for network changes
    var monitornetworkconnection: Bool = false
    // Reference to the active process
    var process: Process?
    // JSON names
    let fileschedulesjson = "schedules.json"
    let fileconfigurationsjson = "configurations.json"
    // for automatic backup
    var estimatedlistforsynchronization: Estimatedlistforsynchronization?
    let reloadstring: String = "no.blogspot.RsyncOSX.reload"
    // If firstime use
    var firsttime = false
    // if new version
    var newversionofrsyncosx = false
    // enable schdules
    var enableschdules = false

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
    // Alloutput
    private var viewControllerAlloutput: NSViewController?
    // Edit
    private var viewControllerEdit: NSViewController?
    // Rsync parameters
    private var viewControllerRsyncParameters: NSViewController?
    // Sidebar
    private var viewcontrollerSideBar: NSViewController?
    // Show rsynccommand
    private var viewcontrollerrsynccommand: NSViewController?

    func getvcref(viewcontroller: ViewController) -> NSViewController? {
        switch viewcontroller {
        case .vctabmain:
            return viewControllertabMain
        case .vcloggdata:
            return viewControllerLoggData
        case .vcnewconfigurations:
            return viewControllerNewConfigurations
        case .vcschedule:
            return viewControllertabSchedule
        case .vcrestore:
            return viewControllerRestore
        case .vcssh:
            return viewControllerSsh
        case .vcabout:
            return viewControllerAbout
        case .vcprogressview:
            return viewControllerProgressView
        case .vcquickbackup:
            return viewControllerQuickbackup
        case .vcremoteinfo:
            return viewControllerRemoteInfo
        case .vcsnapshot:
            return viewControllerSnapshot
        case .vcallprofiles:
            return viewControllerAllProfiles
        case .vcestimatingtasks:
            return viewControllerEstimatingTasks
        case .vcinfolocalremote:
            return viewControllerInfoLocalRemote
        case .vcalloutput:
            return viewControllerAlloutput
        case .vcedit:
            return viewControllerEdit
        case .vcrsyncparameters:
            return viewControllerRsyncParameters
        case .vcsidebar:
            return viewcontrollerSideBar
        case .vcrsynccommand:
            return viewcontrollerrsynccommand
        }
    }

    func setvcref(viewcontroller: ViewController, nsviewcontroller: NSViewController?) {
        switch viewcontroller {
        case .vctabmain:
            viewControllertabMain = nsviewcontroller
        case .vcloggdata:
            viewControllerLoggData = nsviewcontroller
        case .vcnewconfigurations:
            viewControllerNewConfigurations = nsviewcontroller
        case .vcschedule:
            viewControllertabSchedule = nsviewcontroller
        case .vcrestore:
            viewControllerRestore = nsviewcontroller
        case .vcssh:
            viewControllerSsh = nsviewcontroller
        case .vcabout:
            viewControllerAbout = nsviewcontroller
        case .vcprogressview:
            viewControllerProgressView = nsviewcontroller
        case .vcquickbackup:
            viewControllerQuickbackup = nsviewcontroller
        case .vcremoteinfo:
            viewControllerRemoteInfo = nsviewcontroller
        case .vcsnapshot:
            viewControllerSnapshot = nsviewcontroller
        case .vcallprofiles:
            viewControllerAllProfiles = nsviewcontroller
        case .vcestimatingtasks:
            viewControllerEstimatingTasks = nsviewcontroller
        case .vcinfolocalremote:
            viewControllerInfoLocalRemote = nsviewcontroller
        case .vcalloutput:
            viewControllerAlloutput = nsviewcontroller
        case .vcedit:
            viewControllerEdit = nsviewcontroller
        case .vcrsyncparameters:
            viewControllerRsyncParameters = nsviewcontroller
        case .vcsidebar:
            viewcontrollerSideBar = nsviewcontroller
        case .vcrsynccommand:
            viewcontrollerrsynccommand = nsviewcontroller
        }
    }

    init() {
        synctasks = Set<String>()
        synctasks = [synchronize, snapshot, syncremote]
    }
}

enum DictionaryStrings: String {
    case localCatalog
    case profile
    case remoteCatalog
    case offsiteServer
    case task
    case backupID
    case daysID
    case dateExecuted
    case offsiteUsername
    case markdays
    case selectCellID
    case hiddenID
    case offsiteCatalog
    case dateStart
    case schedule
    case dateStop
    case resultExecuted
    case snapshotnum
    case snapdayoffweek
    case dateRun
    case executepretask
    case executeposttask
    case snapCellID
    case localCatalogCellID
    case offsiteCatalogCellID
    case offsiteUsernameID
    case offsiteServerCellID
    case backupIDCellID
    case runDateCellID
    case haltshelltasksonerror
    case taskCellID
    case parameter1
    case parameter2
    case parameter3
    case parameter4
    case parameter5
    case parameter6
    case parameter8
    case parameter9
    case parameter10
    case parameter11
    case parameter12
    case parameter13
    case parameter14
    case rsyncdaemon
    case sshport
    case snaplast
    case sshkeypathandidentityfile
    case pretask
    case posttask
    case executed
    case offsiteserver
    case version3Rsync
    case detailedlogging
    case rsyncPath
    case restorePath
    case marknumberofdayssince
    case pathrsyncosx
    case pathrsyncosxsched
    case minimumlogging
    case fulllogging
    case environment
    case environmentvalue
    case haltonerror
    case monitornetworkconnection
    case json
    case used
    case avail
    case availpercent
    case deleteCellID
    case remotecomputers
    case remoteusers
    case remotehome
    case catalogs
    case localhome
    case transferredNumber
    case sibling
    case parent
    case timetostart
    case start
    case snapshotCatalog
    case days
    case totalNumber
    case totalDirs
    case transferredNumberSizebytes
    case totalNumberSizebytes
    case newfiles
    case deletefiles
    case select
    case startsin
    case stopCellID
    case delta
    case completeCellID
    case inprogressCellID
    case profilename
    case index
    case ShellID
    case schedCellID
    case localhost
    case period
}
