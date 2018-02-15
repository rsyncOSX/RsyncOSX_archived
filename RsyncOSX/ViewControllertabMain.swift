//
//  ViewControllertabMain.swift
//  RsyncOSXver30
//  The Main ViewController.
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable file_length type_body_length cyclomatic_complexity line_length

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

class ViewControllertabMain: NSViewController, ReloadTable, Deselect, Coloractivetask, VcMain, Delay {

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
    @IBOutlet weak var statuslight: NSImageView!
    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet weak var working: NSProgressIndicator!
    // Displays the rsyncCommand
    @IBOutlet weak var rsyncCommand: NSTextField!
    // If On result of Dryrun is presented before
    // executing the real run
    @IBOutlet weak var dryRunOrRealRun: NSTextField!
    // Progressbar scheduled task
    @IBOutlet weak var scheduledJobworking: NSProgressIndicator!
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

    // Reference to Process task
    private var process: Process?
    // Index to selected row, index is set when row is selected
    private var index: Int?
    // Getting output from rsync 
    private var outputprocess: OutputProcess?
    // Getting output from batchrun
    private var outputbatch: OutputBatch?
    // HiddenID task, set when row is selected
    private var hiddenID: Int?
    // Reference to Schedules object
    private var schedulesortedandexpanded: ScheduleSortedAndExpand?
    private var infoschedulessorted: InfoScheduleSortedAndExpand?
    // Bool if one or more remote server is offline
    // Used in testing if remote server is on/off-line
    private var serverOff: [Bool]?
    // Schedules in progress
    private var scheduledJobInProgress: Bool = false
    // Ready for execute again
    private var readyforexecution: Bool = true
    // Can load profiles
    // Load profiles only when testing for connections are done.
    // Application crash if not
    private var loadProfileMenu: Bool = false
    // Which kind of task
    private var processtermination: ProcessTermination?
    // remote info tasks
    private var remoteinfotask: RemoteInfoTaskWorkQueue?
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var pathtorsyncosxschedbutton: NSButton!

    @IBAction func rsyncosxsched(_ sender: NSButton) {
        let pathtorsyncosxschedapp: String = ViewControllerReference.shared.pathrsyncosxsched! + "/" + ViewControllerReference.shared.namersyncosssched
        NSWorkspace.shared.open(URL(fileURLWithPath: pathtorsyncosxschedapp))
        self.pathtorsyncosxschedbutton.isEnabled = false
        NSApp.terminate(self)
    }

    private func info (num: Int) {
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
        default:
            self.info.stringValue = ""
        }
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

    private func reset() {
        self.outputprocess = nil
        self.setNumbers(outputprocess: nil)
        self.setInfo(info: "Estimate", color: .blue)
        self.statuslight.image = #imageLiteral(resourceName: "yellow")
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
        // abortOperations is the delegate function for 
        // aborting batch operations
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
            self.configurations!.getConfigurations()[self.index!].task == "snapshot" else { return }
        let now: Date = Date()
        let dateformatter = Tools().setDateformat()
        let task: NSDictionary = [
            "start": now,
            "hiddenID": self.hiddenID!,
            "dateStart": dateformatter.date(from: "01 Jan 1900 00:00") as Date!,
            "schedule": "manuel"]
        ViewControllerReference.shared.scheduledTask = task
        _ = OperationFactory()
    }

    // Function for display rsync command
    // Either --dry-run or real run
    @IBOutlet weak var displayDryRun: NSButton!
    @IBOutlet weak var displayRealRun: NSButton!
    @IBAction func displayRsyncCommand(_ sender: NSButton) {
        self.setRsyncCommandDisplay()
    }

    // Display correct rsync command in view
    private func setRsyncCommandDisplay() {
        if let index = self.index {
            guard index <= self.configurations!.getConfigurations().count else {
                return
            }
            if self.displayDryRun.state == .on {
                self.rsyncCommand.stringValue = self.tools!.rsyncpathtodisplay(index: index, dryRun: true)
            } else {
                self.rsyncCommand.stringValue = self.tools!.rsyncpathtodisplay(index: index, dryRun: false)
            }
        } else {
            self.rsyncCommand.stringValue = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.working.usesThreadedAnimation = true
        self.scheduledJobworking.usesThreadedAnimation = true
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabmain, nsviewcontroller: self)
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllertabMain.tableViewDoubleClick(sender:))
        self.displayDryRun.state = .on
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
            return
        }
        self.showProcessInfo(info: .blank)
        // Allow notify about Scheduled jobs
        self.configurations!.allowNotifyinMain = true
        self.setInfo(info: "", color: .black)
        self.statuslight.image = #imageLiteral(resourceName: "yellow")
        if self.configurations!.configurationsDataSourcecount() > 0 {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        self.rsyncchanged()
        self.displayProfile()
        self.readyforexecution = true
        if self.tools == nil { self.tools = Tools()}
        self.info(num: 0)
        self.delayWithSeconds(0.5) {
            self.checkforrunning()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        // Do not allow notify in Main
        self.configurations!.allowNotifyinMain = false
    }

    private func checkforrunning() {
        globalMainQueue.async(execute: { () -> Void in
            guard Running().rsyncOSXschedisrunning == false else {
                self.pathtorsyncosxschedbutton.isEnabled = false
                self.info(num: 5)
                return
            }
            if ViewControllerReference.shared.pathrsyncosxsched != nil {
                self.pathtorsyncosxschedbutton.isEnabled = true
            } else {
                self.pathtorsyncosxschedbutton.isEnabled = false
            }
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
    private func executeSingleTask() {
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
    private func displayProfile() {
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
        self.setRsyncCommandDisplay()
    }

    // when row is selected
    // setting which table row is selected, force new estimation
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard self.scheduledJobInProgress == false else {
            return
        }
        // If change row during estimation
        if self.process != nil {
            self.abortOperations()
        }
        // If change row after estimation, force new estimation
        if self.readyforexecution == false {
            self.abortOperations()
        }
        self.readyforexecution = true
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
        self.statuslight.image = #imageLiteral(resourceName: "yellow")
        self.showProcessInfo(info: .blank)
        self.setRsyncCommandDisplay()
        self.reloadtabledata()
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
        self.infoschedulessorted = InfoScheduleSortedAndExpand(sortedandexpanded: self.schedulesortedandexpanded)
        self.schedules?.scheduledTasks = self.schedulesortedandexpanded?.firstscheduledtask()
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
}

extension ViewControllertabMain: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configurations?.configurationsDataSourcecount() ?? 0
    }
}

extension ViewControllertabMain: NSTableViewDelegate, Attributedestring {
    // Function to test for remote server available or not, used in tableview delegate
    private func testTCP(_ row: Int) -> Bool {
        if let serverOff = self.serverOff {
            if row < serverOff.count {
                return serverOff[row]
            } else {
                return false
            }
        }
        return false
    }

    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row > self.configurations!.configurationsDataSourcecount() - 1 { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSource()![row]
        var celltext: String?
        let hiddenID: Int = self.configurations!.getConfigurations()[row].hiddenID
        let markdays: Bool = self.configurations!.getConfigurations()[row].markdays
        celltext = object[tableColumn!.identifier] as? String
        if tableColumn!.identifier.rawValue == "batchCellID" {
            return object[tableColumn!.identifier] as? Int!
        } else if markdays == true && tableColumn!.identifier.rawValue == "daysID" {
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
        } else if self.testTCP(row) {
            guard celltext != nil else {return nil}
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .left)
        } else if tableColumn!.identifier.rawValue == "offsiteServerCellID", ((object[tableColumn!.identifier] as? String)?.isEmpty)! {
            return "localhost"
        } else if tableColumn!.identifier.rawValue == "schedCellID" {
            if let obj = self.schedulesortedandexpanded {
                if obj.numberoftasks(hiddenID).0 > 0 {
                    if obj.numberoftasks(hiddenID).1 > 3600 {
                        return #imageLiteral(resourceName: "yellow")
                    } else {
                        return #imageLiteral(resourceName: "green")
                    }
                }
            }
        } else if tableColumn!.identifier.rawValue == "statCellID" {
            if row == self.index {
                if self.scheduledJobInProgress == true {
                    return #imageLiteral(resourceName: "green")
                }
                if self.singletask == nil {
                    return #imageLiteral(resourceName: "yellow")
                } else {
                    return #imageLiteral(resourceName: "green")
                }
            }
        } else {
            return object[tableColumn!.identifier] as? String
        }
        return nil
    }

    // Toggling batch
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if self.process != nil {
            self.abortOperations()
        }
        if self.configurations!.getConfigurations()[row].task == "backup" ||
           self.configurations!.getConfigurations()[row].task == "snapshot" {
            self.configurations!.setBatchYesNo(row)
        }
        self.singletask = nil
        self.batchtaskObject = nil
        self.setInfo(info: "Estimate", color: .blue)
        self.statuslight.image = #imageLiteral(resourceName: "yellow")
    }
}

// Get output from rsync command
extension ViewControllertabMain: Information {
    // Get information from rsync output.
    func getInformation() -> [String] {
        if self.outputbatch != nil {
            return self.outputbatch!.getOutput()
        } else if self.outputprocess != nil {
            return self.outputprocess!.trimoutput(trim: .two)!
        } else {
            return [""]
        }
    }
}

// Scheduled task are changed, read schedule again og redraw table
extension ViewControllertabMain: Reloadandrefresh {
    // Refresh tableView in main
    func reloadtabledata() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

// Parameters to rsync is changed
extension ViewControllertabMain: RsyncUserParams {
    // Do a reread of all Configurations
    func rsyncuserparamsupdated() {
        self.setRsyncCommandDisplay()
    }
}

// Get index of selected row
extension ViewControllertabMain: GetSelecetedIndex {
    func getindex() -> Int? {
        return self.index
    }
}

// New profile is loaded.
extension ViewControllertabMain: NewProfile {
    // Function is called from profiles when new or default profiles is seleceted
    func newProfile(profile: String?) {
        self.process = nil
        self.outputprocess = nil
        self.outputbatch = nil
        self.singletask = nil
        self.setNumbers(outputprocess: nil)
        self.setRsyncCommandDisplay()
        self.setInfo(info: "Estimate", color: .blue)
        self.statuslight.image = #imageLiteral(resourceName: "yellow")
        self.setNumbers(outputprocess: nil)
        self.deselect()
        // Read configurations and Scheduledata
        self.configurations = self.createconfigurationsobject(profile: profile)
        self.schedules = self.createschedulesobject(profile: profile)
        // Make sure loading profile
        self.loadProfileMenu = true
        self.displayProfile()
        self.reloadtabledata()
        // Reset in tabSchedule
        self.reloadtable(vcontroller: .vctabschedule)
        self.deselectrowtable(vcontroller: .vctabschedule)
        self.reloadtable(vcontroller: .vcsnapshot)
        // We have to start any Scheduled process again - if any
        self.startfirstcheduledtask()
    }

    func enableProfileMenu() {
        self.loadProfileMenu = true
        globalMainQueue.async(execute: { () -> Void in
            self.displayProfile()
        })
    }
}

// A scheduled task is executed
extension ViewControllertabMain: ScheduledTaskWorking {
    func start() {
        globalMainQueue.async(execute: {() -> Void in
            self.scheduledJobInProgress = true
            self.scheduledJobworking.startAnimation(nil)
        })
    }

    func completed() {
        globalMainQueue.async(execute: {() -> Void in
            self.scheduledJobInProgress = false
            self.info(num: 1)
            self.scheduledJobworking.stopAnimation(nil)
        })
    }

    func notifyScheduledTask(config: Configuration?) {
        if self.configurations!.allowNotifyinMain {
            if config == nil {
                globalMainQueue.async(execute: {() -> Void in
                    Alerts.showInfo("Scheduled backup DID not execute?")
                })
            } else {
                if self.processtermination == nil {
                    self.processtermination = .singlequicktask
                }
                if self.processtermination! != .quicktask {
                    globalMainQueue.async(execute: {() -> Void in
                        self.presentViewControllerAsSheet(self.viewControllerScheduledBackupInWork!)
                    })
                }
            }
        }
    }
}

// Rsync path is changed, update displayed rsync command
extension ViewControllertabMain: RsyncChanged {
    // If row is selected an update rsync command in view
    func rsyncchanged() {
        // Update rsync command in display
        self.setRsyncCommandDisplay()
        self.verifyrsync()
        // Setting shortstring
        self.rsyncversionshort.stringValue = ViewControllerReference.shared.rsyncversionshort ?? ""
    }
}

// Check for remote connections, reload table when completed.
extension ViewControllertabMain: Connections {
    // Remote servers offline are marked with red line in mainTableView
    func displayConnections() {
        // Only do a reload if we are in the main view
        guard self.configurations!.allowNotifyinMain == true else {
            return
        }
        self.loadProfileMenu = true
        self.serverOff = self.tools!.gettestAllremoteserverConnections()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

// Uuups, new version is discovered
extension ViewControllertabMain: NewVersionDiscovered {
    // Notifies if new version is discovered
    func notifyNewVersion() {
        if self.configurations!.allowNotifyinMain {
            globalMainQueue.async(execute: { () -> Void in
                self.presentViewControllerAsSheet(self.newVersionViewController!)
            })
        }
    }
}

// Dismisser for sheets
extension ViewControllertabMain: DismissViewController {
    // Function for dismissing a presented view
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
        // Reset radiobuttons
        self.loadProfileMenu = true
        self.remoteinfotask = nil
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
            self.displayProfile()
        })
        self.showProcessInfo(info: .blank)
        self.verifyrsync()
        if viewcontroller == ViewControllerReference.shared.getvcref(viewcontroller: .vcquickbackup) {
            self.configurations!.allowNotifyinMain = true
        }
    }
}

// Called when either a terminatopn of Process is
// discovered or data is availiable in the filehandler
// See file rsyncProcess.swift.
extension ViewControllertabMain: UpdateProgress {

    // Delegate functions called from the Process object
    // Protocol UpdateProgress two functions, ProcessTermination() and FileHandler()
    func processTermination() {
        self.readyforexecution = true
        if self.processtermination == nil {
            self.processtermination = .singlequicktask
        }
        switch self.processtermination! {
        case .singletask:
            guard self.singletask != nil else { return }
            self.outputprocess = self.singletask!.outputprocess
            self.process = self.singletask!.process
            self.singletask!.processTermination()
        case .batchtask:
            // Batch run
            self.batchObjectDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
            self.batchtaskObject = self.batchObjectDelegate?.getbatchtaskObject()
            guard self.batchtaskObject != nil else { return }
            self.outputprocess = self.batchtaskObject!.outputprocess
            self.process = self.batchtaskObject!.process
            self.batchtaskObject!.processTermination()
        case .quicktask:
            guard ViewControllerReference.shared.completeoperation != nil else { return }
            ViewControllerReference.shared.completeoperation!.finalizeScheduledJob(outputprocess: self.outputprocess)
            // After logging is done set reference to object = nil
            ViewControllerReference.shared.completeoperation = nil
            weak var processterminationDelegate: UpdateProgress?
            processterminationDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcquickbackup) as? ViewControllerQuickBackup
            processterminationDelegate?.processTermination()
        case .singlequicktask:
            guard ViewControllerReference.shared.completeoperation != nil else { return }
            ViewControllerReference.shared.completeoperation!.finalizeScheduledJob(outputprocess: self.outputprocess)
            // After logging is done set reference to object = nil
            ViewControllerReference.shared.completeoperation = nil
            // Kick off next task
            self.startfirstcheduledtask()
        case .remoteinfotask:
            guard self.remoteinfotask != nil else { return }
            self.remoteinfotask?.processTermination()
        }
    }

    // Function is triggered when Process outputs data in filehandler
    // Process is either in singleRun or batchRun
    func fileHandler() {
        if self.processtermination == nil {
            self.processtermination = .singlequicktask
        }
        switch self.processtermination! {
        case .singletask:
            guard self.singletask != nil else { return }
            weak var localprocessupdateDelegate: UpdateProgress?
            localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess
            self.outputprocess = self.singletask!.outputprocess
            self.process = self.singletask!.process
            localprocessupdateDelegate?.fileHandler()
        case .batchtask:
            guard self.batchtaskObject != nil else { return }
            if let batchobject = self.configurations!.getbatchQueue() {
                let work = batchobject.nextBatchCopy()
                if work.1 == 1 {
                    // Real work is done, must set reference to Process object in case of Abort
                    self.process = self.batchtaskObject!.process
                    batchobject.updateInProcess(numberOfFiles: self.batchtaskObject!.outputprocess!.count())
                    // Refresh view in Batchwindow
                    self.reloadtable(vcontroller: .vcbatch)
                }
            }
        case .quicktask:
            weak var localprocessupdateDelegate: UpdateProgress?
            localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcquickbackup) as? ViewControllerQuickBackup
            localprocessupdateDelegate?.fileHandler()
        case .singlequicktask:
            return
        case .remoteinfotask:
            return
        }
    }
}

// Deselect a row
extension ViewControllertabMain: DeselectRowTable {
    // deselect a row after row is deleted
    func deselect() {
        guard self.index != nil else { return }
        self.mainTableView.deselectRow(self.index!)
    }
}

// If rsync throws any error
extension ViewControllertabMain: RsyncError {
    func rsyncerror() {
        // Set on or off in user configuration
        globalMainQueue.async(execute: { () -> Void in
            self.setInfo(info: "Error", color: .red)
            self.statuslight.image = #imageLiteral(resourceName: "red")
            self.showProcessInfo(info: .error)
            self.setRsyncCommandDisplay()
            self.deselect()
            // Abort any operations
            if let process = self.process {
                process.terminate()
                self.process = nil
            }
            // Either error in single task or batch task
            if self.singletask != nil {
                self.singletask!.error()
            }
            if self.batchtaskObject != nil {
                self.batchtaskObject!.error()
            }
        })
    }
}

// If, for any reason, handling files or directory throws an error
extension ViewControllertabMain: Fileerror {
    func fileerror(errorstr: String, errortype: Fileerrortype ) {
        globalMainQueue.async(execute: { () -> Void in
            if errortype == .openlogfile {
                self.rsyncCommand.stringValue = Filerrors(errortype: errortype).errordescription()
            } else {
                self.setInfo(info: "Error", color: .red)
                self.statuslight.image = #imageLiteral(resourceName: "red")
                self.showProcessInfo(info: .error)
                self.rsyncCommand.stringValue = Filerrors(errortype: errortype).errordescription() + "\n" + errorstr
            }
        })
    }
}

// Abort task from progressview
extension ViewControllertabMain: AbortOperations {
    // Abort any task, either single- or batch task
    func abortOperations() {
        // Terminates the running process
        self.showProcessInfo(info: .abort)
        if let process = self.process {
            process.terminate()
            self.index = nil
            self.working.stopAnimation(nil)
            self.process = nil
            // Create workqueu and add abort
            self.setInfo(info: "Abort", color: .red)
            self.statuslight.image = #imageLiteral(resourceName: "red")
            self.rsyncCommand.stringValue = ""
        } else {
            self.working.stopAnimation(nil)
            self.rsyncCommand.stringValue = "Selection out of range - aborting"
            self.process = nil
            self.index = nil
        }
        if let batchobject = self.configurations!.getbatchQueue() {
            // Empty queue in batchobject
            batchobject.abortOperations()
            // Set reference to batchdata = nil
            self.configurations!.deleteBatchData()
            self.process = nil
            self.setInfo(info: "Abort", color: .red)
            self.statuslight.image = #imageLiteral(resourceName: "red")
        }
    }
}

// Extensions from here are used in either newSingleTask or newBatchTask

extension ViewControllertabMain: StartStopProgressIndicatorSingleTask {
    func startIndicator() {
        self.working.startAnimation(nil)
    }

    func stopIndicator() {
        self.working.stopAnimation(nil)
    }
}

extension ViewControllertabMain: SingleTaskProgress {
    func getProcessReference(process: Process) {
        self.process = process
    }

    // Just for updating process info
    func showProcessInfo(info: DisplayProcessInfo) {
        globalMainQueue.async(execute: { () -> Void in
            switch info {
            case .estimating:
                self.processInfo.stringValue = "Estimating"
                self.statuslight.image = #imageLiteral(resourceName: "green")
            case .executing:
                self.processInfo.stringValue = "Executing"
            case .loggingrun:
                self.processInfo.stringValue = "Logging run"
            case .changeprofile:
                self.processInfo.stringValue = "Change profile"
            case .abort:
                self.processInfo.stringValue = "Abort"
            case .error:
                self.processInfo.stringValue = "Rsync error"
            case .blank:
                self.processInfo.stringValue = ""
            }
        })
    }

    func presentViewProgress() {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerProgress!)
        })
    }

    func presentViewInformation(outputprocess: OutputProcess) {
        self.outputprocess = outputprocess
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerInformation!)
        })
    }

    func terminateProgressProcess() {
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess
        localprocessupdateDelegate?.processTermination()
    }

    func setInfo(info: String, color: ColorInfo) {
        switch color {
        case .red:
            self.dryRunOrRealRun.textColor = .red
        case .black:
            self.dryRunOrRealRun.textColor = .black
        case .blue:
            self.dryRunOrRealRun.textColor = .blue
        }
        self.dryRunOrRealRun.stringValue = info
    }

    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    func setNumbers(outputprocess: OutputProcess?) {
        globalMainQueue.async(execute: { () -> Void in
            guard outputprocess != nil else {
                self.transferredNumber.stringValue = ""
                self.transferredNumberSizebytes.stringValue = ""
                self.totalNumber.stringValue = ""
                self.totalNumberSizebytes.stringValue = ""
                self.totalDirs.stringValue = ""
                self.newfiles.stringValue = ""
                self.deletefiles.stringValue = ""
                return
            }
            let remoteinfotask = RemoteInfoTask(outputprocess: outputprocess)
            self.transferredNumber.stringValue = remoteinfotask.transferredNumber!
            self.transferredNumberSizebytes.stringValue = remoteinfotask.transferredNumberSizebytes!
            self.totalNumber.stringValue = remoteinfotask.totalNumber!
            self.totalNumberSizebytes.stringValue = remoteinfotask.totalNumberSizebytes!
            self.totalDirs.stringValue = remoteinfotask.totalDirs!
            self.newfiles.stringValue = remoteinfotask.newfiles!
            self.deletefiles.stringValue = remoteinfotask.deletefiles!
        })
    }

    // Returns number set from dryrun to use in logging run 
    // after a real run. Logging is in newSingleTask object.
    func gettransferredNumber() -> String {
        return self.transferredNumber.stringValue
    }

    func gettransferredNumberSizebytes() -> String {
        return self.transferredNumberSizebytes.stringValue
    }

}

extension ViewControllertabMain: BatchTaskProgress {
    func progressIndicatorViewBatch(operation: BatchViewProgressIndicator) {
        let localindicatorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
        switch operation {
        case .stop:
            localindicatorDelegate?.stop()
            self.reloadtable(vcontroller: .vcbatch)
        case .start:
            localindicatorDelegate?.start()
        case .complete:
            localindicatorDelegate?.complete()
        case .refresh:
            self.reloadtable(vcontroller: .vcbatch)
        }
    }

    func setOutputBatch(outputbatch: OutputBatch?) {
        self.outputbatch = outputbatch
    }
}

extension ViewControllertabMain: GetConfigurationsObject {
    func getconfigurationsobject() -> Configurations? {
        guard self.configurations != nil else { return nil }
        // Update alle userconfigurations
        self.configurations!.operation = ViewControllerReference.shared.operation
        return self.configurations
    }

    func createconfigurationsobject(profile: String?) -> Configurations? {
        self.configurations = nil
        self.configurations = Configurations(profile: profile, viewcontroller: self)
        return self.configurations
    }

    // After a write, a reload is forced.
    func reloadconfigurationsobject() {
        // If batchtask keep configuration object
        self.batchtaskObject = self.batchObjectDelegate?.getbatchtaskObject()
        guard self.batchtaskObject == nil else {
            // Batchtask, check if task is completed
            guard self.configurations!.getbatchQueue()?.completedBatch() == false else {
                self.createandreloadconfigurations()
                return
            }
            return
        }
        self.createandreloadconfigurations()
    }
}

extension ViewControllertabMain: GetSchedulesObject {
    func reloadschedulesobject() {
        // If batchtask scedules object
        guard self.batchtaskObject == nil else {
            // Batchtask, check if task is completed
            guard self.configurations!.getbatchQueue()?.completedBatch() == false else {
                self.createandreloadschedules()
                return
            }
            return
        }
        self.createandreloadschedules()
    }

    func getschedulesobject() -> Schedules? {
        return self.schedules
    }

    func createschedulesobject(profile: String?) -> Schedules? {
        self.schedules = nil
        self.schedules = Schedules(profile: profile)
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.infoschedulessorted = InfoScheduleSortedAndExpand(sortedandexpanded: self.schedulesortedandexpanded)
        self.schedules?.scheduledTasks = self.schedulesortedandexpanded?.firstscheduledtask()
        ViewControllerReference.shared.scheduledTask = self.schedulesortedandexpanded?.firstscheduledtask()
        return self.schedules
    }
}

extension  ViewControllertabMain: GetHiddenID {
    func gethiddenID() -> Int? {
        return self.hiddenID
    }
}

extension ViewControllertabMain: Verifyrsync {
    internal func verifyrsync() {
        if ViewControllerReference.shared.norsync == true {
            self.info(num: 3)
        } else {
            self.info(num: 0)
        }
    }
}

extension ViewControllertabMain: ErrorOutput {
    func erroroutput() {
        self.info(num: 2)
    }
}

extension ViewControllertabMain: Createandreloadconfigurations {
    // func reateandreloadconfigurations()
}

extension ViewControllertabMain: Sendprocessreference {
    func sendoutputprocessreference(outputprocess: OutputProcess?) {
        self.outputprocess = outputprocess
    }

    func sendprocessreference(process: Process?) {
        self.process = process
    }
}

extension ViewControllertabMain: StartNextTask {
    func startfirstcheduledtask() {
        // Cancel any schedeuled tasks first
        ViewControllerReference.shared.timerTaskWaiting?.invalidate()
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        _ = OperationFactory(factory: self.configurations!.operation)
    }
}

extension ViewControllertabMain: SetRemoteInfo {
    func setremoteinfo(remoteinfotask: RemoteInfoTaskWorkQueue?) {
        self.remoteinfotask = remoteinfotask
    }

}

extension ViewControllertabMain: OpenQuickBackup {
    func openquickbackup() {
        self.processtermination = .quicktask
        self.configurations!.allowNotifyinMain = false
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerQuickBackup!)
        })
    }
}

extension ViewControllertabMain: Count {
    func maxCount() -> Int {
        guard self.outputprocess != nil else { return 0 }
        return self.outputprocess!.getMaxcount()
    }

    func inprogressCount() -> Int {
        guard self.outputprocess != nil else { return 0 }
        return self.outputprocess!.count()
    }
}

extension ViewControllertabMain: Reloadsortedandrefresh {
    func reloadsortedandrefreshtabledata() {
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstcheduledtask()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}
