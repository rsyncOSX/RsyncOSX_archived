//
//  ViewControllertabMain.swift
//  RsyncOSXver30
//  The Main ViewController.
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable file_length type_body_length line_length

import Foundation
import Cocoa

// Protocol for start,stop, complete progressviewindicator
protocol StartStopProgressIndicator: class {
    func start()
    func stop()
    func complete()
}

// Protocol for either completion of work or update progress when Process discovers a
// process termination and when filehandler discover data
protocol UpdateProgress: class {
    func processTermination()
    func fileHandler()
}

protocol ViewOutputDetails: class {
    func reloadtable()
    func appendnow() -> Bool
    func getalloutput() -> [String]
    func disableallinfobutton()
    func enableallinfobutton()
}

class ViewControllertabMain: NSViewController, ReloadTable, Deselect, Coloractivetask, VcMain, Delay, Fileerrormessage {

    // Configurations object
    var configurations: Configurations?
    var schedules: Schedules?
    // Reference to the single taskobject
    var singletask: SingleTask?
    // Reference to batch taskobject
    var batchtaskObject: BatchTask?
    var tools: Tools?
    // Delegate function getting batchTaskObject
    weak var batchObjectDelegate: GetNewBatchTask?
    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var workinglabel: NSTextField!
    // Displays the rsyncCommand
    @IBOutlet weak var rsyncCommand: NSTextField!
    // If On result of Dryrun is presented before
    // executing the real run
    @IBOutlet weak var dryRunOrRealRun: NSTextField!
    // Progressbar scheduled task
    @IBOutlet weak var scheduledJobworking: NSProgressIndicator!
    @IBOutlet weak var scheduleJobworkinglabel: NSTextField!
    // number of files to be transferred
    @IBOutlet weak var transferredNumber: NSTextField!
    // size of files to be transferred
    @IBOutlet weak var transferredNumberSizebytes: NSTextField!
    // total number of files in remote volume
    @IBOutlet weak var totalNumber: NSTextField!
    // total size of files in remote volume
    @IBOutlet weak var totalNumberSizebytes: NSTextField!
    // total number of directories remote volume
    @IBOutlet weak var totalDirs: NSTextField!
    // Showing info about profile
    @IBOutlet weak var profilInfo: NSTextField!
    // Showing info about double clik or not
    // Just showing process info
    @IBOutlet weak var processInfo: NSTextField!
    // New files
    @IBOutlet weak var newfiles: NSTextField!
    // Delete files
    @IBOutlet weak var deletefiles: NSTextField!
    @IBOutlet weak var rsyncversionshort: NSTextField!
    @IBOutlet weak var backupdryrun: NSButton!
    @IBOutlet weak var restoredryrun: NSButton!
    @IBOutlet weak var verifydryrun: NSButton!

    // Reference to Process task
    var process: Process?
    // Index to selected row, index is set when row is selected
    var index: Int?
    // Getting output from rsync 
    var outputprocess: OutputProcess?
    // Getting output from batchrun
    var outputbatch: OutputBatch?
    // Dynamic view of output
    var dynamicappend: Bool = false
    weak var dynamicreloadoutputDelegate: Reloadandrefresh?
    // HiddenID task, set when row is selected
    var hiddenID: Int?
    // Reference to Schedules object
    var schedulesortedandexpanded: ScheduleSortedAndExpand?
    // Bool if one or more remote server is offline
    // Used in testing if remote server is on/off-line
    var serverOff: [Bool]?
    // Schedules in progress
    var scheduledJobInProgress: Bool = false
    // Ready for execute again
    var readyforexecution: Bool = true
    // Can load profiles
    // Load profiles only when testing for connections are done.
    // Application crash if not
    var loadProfileMenu: Bool = false
    // Which kind of task
    var processtermination: ProcessTermination?
    // Keep track of all errors
    var outputerrors: OutputErrors?
    // Update view estimating
    weak var estimateupdateDelegate: Updateestimating?
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var pathtorsyncosxschedbutton: NSButton!
    @IBOutlet weak var menuappisrunning: NSButton!
    @IBOutlet weak var allinfobutton: NSButton!

    @IBAction func rsyncosxsched(_ sender: NSButton) {
        let pathtorsyncosxschedapp: String = ViewControllerReference.shared.pathrsyncosxsched! + ViewControllerReference.shared.namersyncosssched
        NSWorkspace.shared.open(URL(fileURLWithPath: pathtorsyncosxschedapp))
        self.pathtorsyncosxschedbutton.isEnabled = false
        NSApp.terminate(self)
    }

    @IBAction func restore(_ sender: NSButton) {
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            self.tools!.noRsync()
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == "backup" ||
            self.configurations!.getConfigurations()[self.index!].task == "snapshot" else {
                self.info(num: 7)
                return
        }
        self.processtermination = .restore
        self.presentViewControllerAsSheet(self.restoreViewController!)
    }

    func info(num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "Select a task...."
        case 2:
            self.info.stringValue = "Possible error logging..."
        case 3:
            self.info.stringValue = "No rsync in path..."
        case 4:
            self.info.stringValue = "⌘A to abort or wait..."
        case 5:
             self.info.stringValue = "Menu app is running..."
        case 6:
            self.info.stringValue = "This is a combined task, execute by ⌘R..."
        case 7:
            self.info.stringValue = "Only valid for backup and snapshot tasks..."
        case 8:
            self.info.stringValue = "No rclone config found..."
        default:
            self.info.stringValue = ""
        }
    }

    @IBAction func infoonetask(_ sender: NSButton) {
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            self.tools!.noRsync()
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == "backup" ||
            self.configurations!.getConfigurations()[self.index!].task == "snapshot" else {
                self.info(num: 7)
                return
        }
        self.processtermination = .infosingletask
        self.presentViewControllerAsSheet(self.viewControllerInformationLocalRemote!)
    }

    @IBAction func totinfo(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            self.tools!.noRsync()
            return
        }
        self.processtermination = .remoteinfotask
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerRemoteInfo!)
        })
    }

    @IBAction func quickbackup(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            self.tools!.noRsync()
            return
        }
        self.openquickbackup()
    }

    @IBAction func edit(_ sender: NSButton) {
        self.reset()
        if self.index != nil {
            globalMainQueue.async(execute: { () -> Void in
                self.presentViewControllerAsSheet(self.editViewController!)
            })
        } else {
            self.info(num: 1)
        }
    }

    @IBAction func rsyncparams(_ sender: NSButton) {
        self.reset()
        if self.index != nil {
            globalMainQueue.async(execute: { () -> Void in
                self.presentViewControllerAsSheet(self.viewControllerRsyncParams!)
            })
        } else {
            self.info(num: 1)
        }
    }

    @IBAction func delete(_ sender: NSButton) {
        self.reset()
        guard self.hiddenID != nil else {
            self.info(num: 1)
            return
        }
        let answer = Alerts.dialogOKCancel("Delete selected task?", text: "Cancel or OK")
        if answer {
            if self.hiddenID != nil {
                // Delete Configurations and Schedules by hiddenID
                self.configurations!.deleteConfigurationsByhiddenID(hiddenID: self.hiddenID!)
                self.schedules!.deletescheduleonetask(hiddenID: self.hiddenID!)
                self.deselect()
                self.hiddenID = nil
                self.index = nil
                self.reloadtabledata()
                // Reset in tabSchedule
                self.reloadtable(vcontroller: .vctabschedule)
                self.reloadtable(vcontroller: .vcsnapshot)
            }
        }
    }

    func reset() {
        self.outputprocess = nil
        self.setNumbers(outputprocess: nil)
        self.setInfo(info: "Estimate", color: .blue)
        self.process = nil
        self.singletask = nil
    }

    @IBOutlet weak var TCPButton: NSButton!
    @IBAction func TCP(_ sender: NSButton) {
        self.TCPButton.isEnabled = false
        self.loadProfileMenu = false
        self.displayProfile()
        self.tools!.testAllremoteserverConnections()
    }

    // Presenting Information from Rsync
    @IBAction func information(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerInformation!)
        })
    }

    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.abortOperations()
            self.process = nil
        })
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    // Selecting profiles
    @IBAction func profiles(_ sender: NSButton) {
        if self.loadProfileMenu == true {
            self.showProcessInfo(info: .changeprofile)
            globalMainQueue.async(execute: { () -> Void in
                self.presentViewControllerAsSheet(self.viewControllerProfile!)
            })
        } else {
            self.displayProfile()
        }
    }

    // Logg records
    @IBAction func loggrecords(_ sender: NSButton) {
        self.configurations!.allowNotifyinMain = true
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerScheduleDetails!)
        })
    }

    // Selecting About
    @IBAction func about (_ sender: NSButton) {
        self.presentViewControllerAsModalWindow(self.viewControllerAbout!)
    }

    // Selecting automatic backup
    @IBAction func automaticbackup (_ sender: NSButton) {
        self.automaticbackup()
    }

    @IBAction func executetasknow(_ sender: NSButton) {
        self.processtermination = .singlequicktask
        guard ViewControllerReference.shared.norsync == false else {
            self.tools!.noRsync()
            return
        }
        guard self.scheduledJobInProgress == false else {
            self.info(num: 4)
            return
        }
        guard self.hiddenID != nil else {
            self.info(num: 1)
            return
        }
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == "backup" ||
            self.configurations!.getConfigurations()[self.index!].task == "snapshot" ||
        self.configurations!.getConfigurations()[self.index!].task == "combined" else {
                return
        }
        if self.configurations!.getConfigurations()[self.index!].task == "combined" {
            self.processtermination = .combinedtask
            self.working.startAnimation(nil)
            _ = Combined(profile: self.configurations!.getConfigurations()[self.index!].rcloneprofile, index: self.index!)
        } else {
            self.executetasknow()
        }
    }

    func executetasknow() {
        self.processtermination = .singlequicktask
        let now: Date = Date()
        let dateformatter = Tools().setDateformat()
        let task: NSDictionary = [
            "start": now,
            "hiddenID": self.hiddenID!,
            "dateStart": dateformatter.date(from: "01 Jan 1900 00:00")!,
            "schedule": "manuel"]
        ViewControllerReference.shared.scheduledTask = task
        _ = OperationFactory()
    }

    func automaticbackup() {
        self.processtermination = .automaticbackup
        self.configurations?.remoteinfotaskworkqueue = RemoteInfoTaskWorkQueue()
        self.presentViewControllerAsSheet(self.viewControllerEstimating!)
        self.estimateupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcestimatingtasks) as? ViewControllerEstimatingTasks
    }

    // Function for display rsync command
    @IBAction func showrsynccommand(_ sender: NSButton) {
        self.showrsynccommandmainview()
    }

    // Display correct rsync command in view
    func showrsynccommandmainview() {
        if let index = self.index {
            guard index <= self.configurations!.getConfigurations().count else { return }
            if self.backupdryrun.state == .on {
                self.rsyncCommand.stringValue = self.tools!.displayrsynccommand(index: index, display: .synchronize)
            } else if self.restoredryrun.state == .on {
                self.rsyncCommand.stringValue = self.tools!.displayrsynccommand(index: index, display: .restore)
            } else {
                self.rsyncCommand.stringValue = self.tools!.displayrsynccommand(index: index, display: .verify)
            }
        } else {
            self.rsyncCommand.stringValue = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sleepandwakenotifications()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.working.usesThreadedAnimation = true
        self.scheduledJobworking.usesThreadedAnimation = true
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabmain, nsviewcontroller: self)
        _ = RsyncVersionString()
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllertabMain.tableViewDoubleClick(sender:))
        self.backupdryrun.state = .on
        self.loadProfileMenu = true
        // configurations and schedules
        self.createandreloadconfigurations()
        self.createandreloadschedules()
        self.startfirstcheduledtask()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.scheduledJobInProgress == false else {
            self.scheduledJobworking.startAnimation(nil)
            self.scheduleJobworkinglabel.isHidden = false
            return
        }
        self.showProcessInfo(info: .blank)
        // Allow notify about Scheduled jobs
        self.configurations!.allowNotifyinMain = true
        self.setInfo(info: "", color: .black)
        if self.configurations!.configurationsDataSourcecount() > 0 {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        self.rsyncischanged()
        self.displayProfile()
        self.readyforexecution = true
        if self.tools == nil { self.tools = Tools()}
        self.info(num: 0)
        self.delayWithSeconds(0.5) {
            self.enablemenuappbutton()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        // Do not allow notify in Main
        self.configurations!.allowNotifyinMain = false
        self.dynamicappend = false
    }

    func enablemenuappbutton() {
        globalMainQueue.async(execute: { () -> Void in
            let running = Running()
            guard running.enablemenuappbutton() == true else {
                self.pathtorsyncosxschedbutton.isEnabled = false
                if running.menuappnoconfig == false {
                    self.menuappisrunning.image = #imageLiteral(resourceName: "green")
                    self.info(num: 5)
                }
                return
            }
            self.pathtorsyncosxschedbutton.isEnabled = true
            self.menuappisrunning.image = #imageLiteral(resourceName: "red")
        })
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        if self.readyforexecution {
            self.executeSingleTask()
        }
        self.readyforexecution = false
    }

    // Single task can be activated by double click from table
    func executeSingleTask() {
        self.processtermination = .singletask
        guard self.scheduledJobInProgress == false else {
            self.info(num: 4)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            self.tools!.noRsync()
            return
        }
        guard self.index != nil else {
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == "backup" ||
            self.configurations!.getConfigurations()[self.index!].task == "snapshot" ||
            self.configurations!.getConfigurations()[self.index!].task == "restore" else {
                self.info(num: 6)
                return
        }
        self.batchtaskObject = nil
        guard self.singletask != nil else {
            // Dry run
            self.singletask = SingleTask(index: self.index!)
            self.singletask?.executeSingleTask()
            // Set reference to singleTask object
            self.configurations!.singleTask = self.singletask
            return
        }
        // Real run
        self.singletask?.executeSingleTask()
    }

    // Execute BATCH TASKS only
    @IBAction func executeBatch(_ sender: NSButton) {
        self.processtermination = .batchtask
        guard self.scheduledJobInProgress == false else {
            self.info(num: 4)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            self.tools!.noRsync()
            return
        }
        self.singletask = nil
        self.setNumbers(outputprocess: nil)
        self.deselect()
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerBatch!)
        })
    }

    // Function for setting profile
    func displayProfile() {
        weak var localprofileinfo: SetProfileinfo?
        weak var localprofileinfo2: SetProfileinfo?
        guard self.loadProfileMenu == true else {
            self.profilInfo.stringValue = "Profile: please wait..."
            self.profilInfo.textColor = .blue
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.profilInfo.stringValue = "Profile: " + profile
            self.profilInfo.textColor = .blue
        } else {
            self.profilInfo.stringValue = "Profile: default"
            self.profilInfo.textColor = .black
        }
        localprofileinfo = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
        localprofileinfo2 = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations ) as? ViewControllerNewConfigurations
        localprofileinfo?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        localprofileinfo2?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        self.TCPButton.isEnabled = true
        self.showrsynccommandmainview()
    }

    // when row is selected
    // setting which table row is selected, force new estimation
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard self.scheduledJobInProgress == false else { return }
        // If change row during estimation
        if self.process != nil {
            self.abortOperations()
        }
        // If change row after estimation, force new estimation
        if self.readyforexecution == false {
            self.abortOperations()
        }
        self.readyforexecution = true
        self.backupdryrun.state = .on
        self.info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.hiddenID = self.configurations!.gethiddenID(index: index)
            self.outputprocess = nil
            self.outputbatch = nil
            self.setNumbers(outputprocess: nil)
        } else {
            self.index = nil
        }
        self.process = nil
        self.singletask = nil
        self.setInfo(info: "Estimate", color: .blue)
        self.showProcessInfo(info: .blank)
        self.showrsynccommandmainview()
        self.reloadtabledata()
        self.configurations!.allowNotifyinMain = true
    }

    func createandreloadschedules() {
        self.process = nil
        guard self.configurations != nil else {
            self.schedules = Schedules(profile: nil)
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.schedules = nil
            self.schedules = Schedules(profile: profile)
        } else {
            self.schedules = nil
            self.schedules = Schedules(profile: nil)
        }
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        ViewControllerReference.shared.scheduledTask = self.schedulesortedandexpanded?.firstscheduledtask()
    }

    func createandreloadconfigurations() {
        guard self.configurations != nil else {
            self.configurations = Configurations(profile: nil, viewcontroller: self)
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.configurations = nil
            self.configurations = Configurations(profile: profile, viewcontroller: self)
        } else {
            self.configurations = nil
            self.configurations = Configurations(profile: nil, viewcontroller: self)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    @objc func onWakeNote(note: NSNotification) {
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        ViewControllerReference.shared.scheduledTask = self.schedulesortedandexpanded?.firstscheduledtask()
        self.startfirstcheduledtask()
    }

    @objc func onSleepNote(note: NSNotification) {
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        ViewControllerReference.shared.timerTaskWaiting?.invalidate()
    }

    private func sleepandwakenotifications() {
        NSWorkspace.shared.notificationCenter.addObserver( self, selector: #selector(onWakeNote(note:)),
                                                           name: NSWorkspace.didWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver( self, selector: #selector(onSleepNote(note:)),
                                                           name: NSWorkspace.willSleepNotification, object: nil)
    }
}
