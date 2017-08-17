//
//  ViewControllertabMain.swift
//  RsyncOSXver30
//  The Main ViewController.
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar file_length cyclomatic_complexity line_length type_body_length

import Foundation
import Cocoa

// Protocols for instruction start/stop progressviewindicator
protocol StartStopProgressIndicator: class {
    func start()
    func stop()
    func complete()
}

// Protocol for dismiss a viewcontroller
// It is the presenting viewcontroller which is
// responsible to dismiss the viewcontroller
protocol DismissViewController: class {
    func dismiss_view(viewcontroller: NSViewController)
}

// Protocol for either completion of work or update progress when Process discovers a
// process termination and when filehandler discover data
protocol UpdateProgress: class {
    func processTermination()
    func fileHandler()
}

// Protocol for deselecting rowtable
protocol deselectRowTable: class {
    func deselectRow()
}

// Protocol for reporting file errors
protocol ReportErrorInMain: class {
    func fileerror(errorstr: String)
}

class ViewControllertabMain: NSViewController {

    // Reference to the single taskobject
    var singletask: NewSingleTask?
    // Reference to batch taskobject
    var batchtask: NewBatchTask?
    var tools: Tools?

    // Protocol function used in Process().
    weak var processupdateDelegate: UpdateProgress?
    // Delegate function for doing a refresh of NSTableView in ViewControllerBatch
    weak var refreshDelegate: RefreshtableView?
    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicatorDelegate: StartStopProgressIndicator?
    // Delegate function getting batchTaskObject
    weak var batchObjectDelegate: getNewBatchTask?

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
    @IBOutlet weak var allowDoubleclick: NSTextField!
    // Just showing process info
    @IBOutlet weak var processInfo: NSTextField!
    // New files
    @IBOutlet weak var newfiles: NSTextField!
    // Delete files
    @IBOutlet weak var deletefiles: NSTextField!

    // REFERENCE VARIABLES

    // Reference to Process task
    fileprivate var process: Process?
    // Index to selected row, index is set when row is selected
    fileprivate var index: Int?
    // Getting output from rsync 
    fileprivate var output: OutputProcess?
    // Getting output from batchrun
    fileprivate var outputbatch: OutputBatch?
    // HiddenID task, set when row is selected
    fileprivate var hiddenID: Int?
    // Reference to Schedules object
    fileprivate var schedules: ScheduleSortedAndExpand?
    // Bool if one or more remote server is offline
    // Used in testing if remote server is on/off-line
    fileprivate var serverOff: Array<Bool>?

    // Schedules in progress
    fileprivate var scheduledJobInProgress: Bool = false
    // Ready for execute again
    fileprivate var ready: Bool = true
    // Can load profiles
    // Load profiles only when testing for connections are done.
    // Application crash if not
    fileprivate var loadProfileMenu: Bool = false

    // Information about rsync output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    lazy var viewControllerInformation: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardInformationID"))
        as? NSViewController)!
    }()

    // Progressbar process 
    // self.presentViewControllerAsSheet(self.ViewControllerProgress)
    lazy var viewControllerProgress: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardProgressID"))
            as? NSViewController)!
    }()

    // Batch process
    // self.presentViewControllerAsSheet(self.ViewControllerBatch)
    lazy var viewControllerBatch: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardBatchID"))
            as? NSViewController)!
    }()

    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    lazy var viewControllerUserconfiguration: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardUserconfigID"))
            as? NSViewController)!
    }()

    // Rsync userparams
    // self.presentViewControllerAsSheet(self.ViewControllerRsyncParams)
    lazy var viewControllerRsyncParams: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardRsyncParamsID"))
            as? NSViewController)!
    }()

    // New version window
    // self.presentViewControllerAsSheet(self.newVersionViewController)
    lazy var newVersionViewController: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardnewVersionID"))
            as? NSViewController)!
    }()

    // Edit
    // self.presentViewControllerAsSheet(self.editViewController)
    lazy var editViewController: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardEditID"))
            as? NSViewController)!
    }()

    // Profile
    // self.presentViewControllerAsSheet(self.ViewControllerProfile)
    lazy var viewControllerProfile: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ProfileID"))
            as? NSViewController)!
    }()

    // ScheduledBackupInWorkID
    // self.presentViewControllerAsSheet(self.ViewControllerScheduledBackupInWork)
    lazy var viewControllerScheduledBackupInWork: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ScheduledBackupInWorkID"))
            as? NSViewController)!
    }()

    // About
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var viewControllerAbout: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AboutID"))
            as? NSViewController)!
    }()

    // BUTTONS AND ACTIONS

    @IBOutlet weak var edit: NSButton!
    @IBOutlet weak var rsyncparams: NSButton!
    @IBOutlet weak var delete: NSButton!

    // Menus as Radiobuttons for Edit functions in tabMainView
    @IBAction func radiobuttons(_ sender: NSButton) {

        // Reset output
        self.output = nil
        // Clear numbers from dryrun
        self.setNumbers(output: nil)
        self.setInfo(info: "Estimate", color: .blue)
        self.process = nil

        if self.index != nil {
            // rsync params
            if self.rsyncparams.state == .on {
                if self.index != nil {
                    globalMainQueue.async(execute: { () -> Void in
                        self.presentViewControllerAsSheet(self.viewControllerRsyncParams)
                    })
                }
            // Edit task
            } else if self.edit.state == .on {
                if self.index != nil {
                    globalMainQueue.async(execute: { () -> Void in
                        self.presentViewControllerAsSheet(self.editViewController)
                    })
                }
            // Delete files
            } else if self.delete.state == .on {
                let answer = Alerts.dialogOKCancel("Delete selected task?", text: "Cancel or OK")
                if answer {
                    if self.hiddenID != nil {
                        // Delete Configurations and Schedules by hiddenID
                        Configurations.shared.deleteConfigurationsByhiddenID(hiddenID: self.hiddenID!)
                        Schedules.shared.deletechedule(hiddenID: self.hiddenID!)
                        // Reading main Configurations and Schedule to memory
                        // self.reReadConfigurationsAndSchedules()
                        // And create a new Schedule object
                        // Just calling the protocol function
                        self.newSchedulesAdded()
                        self.deselectRow()
                        self.hiddenID = nil
                        self.index = nil
                        self.refresh()
                    }
                }
                self.delete.state = .off
            }
        } else {
            self.rsyncCommand.stringValue = " ... Please select a task first ..."
            self.delete.state = .off
            self.rsyncparams.state = .off
            self.edit.state = .off
        }
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
            self.presentViewControllerAsSheet(self.viewControllerInformation)
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
            self.presentViewControllerAsSheet(self.viewControllerUserconfiguration)
        })
    }

    // Selecting profiles
    @IBAction func profiles(_ sender: NSButton) {
        if self.loadProfileMenu == true {
            self.showProcessInfo(info:.changeprofile)
            globalMainQueue.async(execute: { () -> Void in
                self.presentViewControllerAsSheet(self.viewControllerProfile)
            })
        } else {
            self.displayProfile()
        }

    }

    // Selecting About
    @IBAction func about (_ sender: NSButton) {
        self.presentViewControllerAsModalWindow(self.viewControllerAbout)
    }

    // Function for display rsync command
    // Either --dry-run or real run
    @IBOutlet weak var displayDryRun: NSButton!
    @IBOutlet weak var displayRealRun: NSButton!
    @IBAction func displayRsyncCommand(_ sender: NSButton) {
        self.setRsyncCommandDisplay()
    }

    // Display correct rsync command in view
    fileprivate func setRsyncCommandDisplay() {
        if let index = self.index {
            guard index <= Configurations.shared.getConfigurations().count else {
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

    // Initial functions viewDidLoad and viewDidAppear
    // Leaving view viewDidDisappear

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        // Progress indicator
        self.working.usesThreadedAnimation = true
        self.scheduledJobworking.usesThreadedAnimation = true
        self.readConfigurationsAndSchedules()
        // Setting reference to self, used when calling delegate functions
        Configurations.shared.viewControllertabMain = self
        // Create a Schedules object
        // Start waiting for next Scheduled job (if any)
        self.schedules = ScheduleSortedAndExpand()
        self.startProcess()
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllertabMain.tableViewDoubleClick(sender:))
        // Defaults to display dryrun command
        self.displayDryRun.state = .on
        self.tools = Tools()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.loadProfileMenu = false
        self.showProcessInfo(info: .blank)
        // Allow notify about Scheduled jobs
        Configurations.shared.allowNotifyinMain = true
        self.setInfo(info: "", color: .black)
        // Setting reference to ViewController
        // Used to call delegate function from other class
        Configurations.shared.viewControllertabMain = self
        if Configurations.shared.configurationsDataSourcecount() > 0 {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        // Update rsync command in view i case changed
        self.rsyncchanged()
        // Show which profile
        self.loadProfileMenu = true
        self.displayProfile()
        if self.schedules == nil {
            self.schedules = ScheduleSortedAndExpand()
        }
        self.ready = true
        self.displayAllowDoubleclick()
        if self.tools == nil { self.tools = Tools()}

    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        // Do not allow notify in Main
        Configurations.shared.allowNotifyinMain = false
    }

    // True if scheduled task in progress
    func scheduledOperationInProgress() -> Bool {
        var scheduleInProgress: Bool?
        if self.schedules != nil {
            scheduleInProgress = self.schedules!.getScheduledOperationInProgress()
        } else {
            scheduleInProgress = false
        }
        if scheduleInProgress == false && self.scheduledJobInProgress == false {
            return false
        } else {
            return true
        }
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        if Configurations.shared.allowDoubleclick == true {
            if self.ready {
                self.executeSingleTask()
            }
            self.ready = false
        }
    }

    // Single task can be activated by double click from table
    private func executeSingleTask() {
        guard scheduledOperationInProgress() == false else {
            Alerts.showInfo("Scheduled operation in progress")
            return
        }
        guard Configurations.shared.norsync == false else {
            self.tools!.noRsync()
            return
        }
        guard self.index != nil else {
            return
        }
        self.batchtask = nil
        guard self.singletask != nil else {
            // Dry run
            self.singletask = NewSingleTask(index: self.index!)
            self.singletask?.executeSingleTask()
            // Set reference to singleTask object
            Configurations.shared.singleTask = self.singletask
            return
        }
        // Real run
        self.singletask?.executeSingleTask()
    }

    // Execute BATCH TASKS only
    @IBAction func executeBatch(_ sender: NSButton) {
        guard scheduledOperationInProgress() == false else {
            Alerts.showInfo("Scheduled operation in progress")
            return
        }
        guard Configurations.shared.norsync == false else {
            self.tools!.noRsync()
            return
        }
        self.singletask = nil
        self.setNumbers(output: nil)
        self.batchtask = NewBatchTask()
        // Present batch view
        self.batchtask?.presentBatchView()
    }

    // Reread bot Configurations and Schedules from persistent store to memory
    fileprivate func readConfigurationsAndSchedules() {
        // Reading main Configurations to memory
        Configurations.shared.setDataDirty(dirty: true)
        Configurations.shared.readAllConfigurationsAndArguments()
        // Read all Scheduled data again
        Configurations.shared.setDataDirty(dirty: true)
        Schedules.shared.readAllSchedules()
    }

    // Function for setting profile
    fileprivate func displayProfile() {
        guard self.loadProfileMenu == true else {
            self.profilInfo.stringValue = "Profile: please wait..."
            self.profilInfo.textColor = .blue
            return
        }
        if let profile = Configurations.shared.getProfile() {
            self.profilInfo.stringValue = "Profile: " + profile
            self.profilInfo.textColor = .blue
        } else {
            self.profilInfo.stringValue = "Profile: default"
            self.profilInfo.textColor = .black
        }
        self.TCPButton.isEnabled = true
        self.setRsyncCommandDisplay()
    }

    // Function for setting allowDouble click
    internal func displayAllowDoubleclick() {
        if Configurations.shared.allowDoubleclick == true {
            self.allowDoubleclick.stringValue = "Double click on row to execute task"
            self.allowDoubleclick.textColor = .blue
        } else {
            self.allowDoubleclick.stringValue = "Double click: NO (enable in Configuration)"
            self.allowDoubleclick.textColor = .red
        }
    }

    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        if self.ready == false {
            self.abortOperations()
        }
        self.ready = true
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.hiddenID = Configurations.shared.gethiddenID(index: index)
            // Reset output
            self.output = nil
            self.outputbatch = nil
            // Clear numbers from dryrun
            self.setNumbers(output: nil)
        } else {
            self.index = nil
        }
        self.process = nil
        self.singletask = nil
        self.batchtask = nil
        self.setInfo(info: "Estimate", color: .blue)
        self.setRsyncCommandDisplay()
    }

    func readConfigurations() {
        if Configurations.shared.configurationsDataSourcecount() > 0 {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        // Read schedule objects again
        self.schedules = nil
        self.schedules = ScheduleSortedAndExpand()
        self.setRsyncCommandDisplay()
    }
}

// Extensions

extension ViewControllertabMain : NSTableViewDataSource {

    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Configurations.shared.configurationsDataSourcecount()
    }
}

extension ViewControllertabMain : NSTableViewDelegate {

    // Function to test for remote server available or not, used in tableview delegate
    private func testRow(_ row: Int) -> Bool {
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
    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row > Configurations.shared.configurationsDataSourcecount() - 1 {
            return nil
        }
        let object: NSDictionary = Configurations.shared.getConfigurationsDataSource()![row]
        var text: String?
        var schedule: Bool = false
        let hiddenID: Int = Configurations.shared.getConfigurations()[row].hiddenID
        if Schedules.shared.hiddenIDinSchedule(hiddenID) {
            text = object[tableColumn!.identifier] as? String
            if text == "backup" || text == "restore" {
                schedule = true
            }
        }
        if tableColumn!.identifier.rawValue == "batchCellID" {
            return object[tableColumn!.identifier] as? Int!
        } else {
            var number: Int = 0
            if let obj = self.schedules {
                number = obj.numberOfFutureSchedules(hiddenID)
            }
            if schedule && number > 0 {
                let returnstr = text! + " (" + String(number) + ")"
                return returnstr
            } else {
                if self.testRow(row) {
                    text = object[tableColumn!.identifier] as? String
                    let attributedString = NSMutableAttributedString(string:(text!))
                    let range = (text! as NSString).range(of: text!)
                    attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: NSColor.red, range: range)
                    return attributedString
                } else {
                    return object[tableColumn!.identifier] as? String
                }
            }
        }
    }

    // Toggling batch
    @objc(tableView:setObjectValue:forTableColumn:row:) func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if Configurations.shared.getConfigurations()[row].task == "backup" {
            Configurations.shared.setBatchYesNo(row)
        }
        self.singletask = nil
        self.setInfo(info: "Estimate", color: .blue)
    }
}

// Get output from rsync command
extension ViewControllertabMain: Information {

    // Get information from rsync output.
    func getInformation() -> Array<String> {
        if self.outputbatch != nil {
            return self.outputbatch!.getOutput()
        } else if self.output != nil {
            return self.output!.getOutput()
        } else {
            return [""]
        }
    }
}

// Scheduled task are changed, read schedule again og redraw table
extension ViewControllertabMain: RefreshtableView {

    // Refresh tableView in main
    func refresh() {
        // Create and read schedule objects again
        // Releasing previous allocation before creating new one
        self.schedules = nil
        self.schedules = ScheduleSortedAndExpand()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

// Parameters to rsync is changed
extension ViewControllertabMain: RsyncUserParams {

    // Do a reread of all Configurations
    func rsyncuserparamsupdated() {
        self.readConfigurations()
        self.setRsyncCommandDisplay()
        self.rsyncparams.state = .off
    }
}

// Get index of selected row
extension ViewControllertabMain: GetSelecetedIndex {

    func getindex() -> Int? {
        return self.index
    }
}

// Next scheduled job is started, if any
extension ViewControllertabMain: StartNextScheduledTask {

    // Start next job
    func startProcess() {
        // Start any Scheduled job
        _ = ScheduleOperation()
    }
}

// New profile is loaded.
extension ViewControllertabMain: AddProfiles {

    // Function is called from profiles when new or default profiles is seleceted
    func newProfile(new: Bool) {
        weak var newProfileDelegate: AddProfiles?
        self.schedules = nil
        self.loadProfileMenu = false
        // Reset any queue of work
        // Reset numbers
        self.process = nil
        self.output = nil
        self.outputbatch = nil
        self.setRsyncCommandDisplay()
        self.setInfo(info: "Estimate", color: .blue)
        self.setNumbers(output: nil)
        guard new == false else {
            // A new and empty profile is created
            Schedules.shared.destroySchedule()
            Configurations.shared.destroyConfigurations()
            // Reset in tabSchedule
            if let pvc = Configurations.shared.viewControllertabSchedule as? ViewControllertabSchedule {
                newProfileDelegate = pvc
                newProfileDelegate?.newProfile(new: true)
            }
            self.refresh()
            return
        }
        // Reset in tabSchedule
        if let pvc = Configurations.shared.viewControllertabSchedule as? ViewControllertabSchedule {
            newProfileDelegate = pvc
            newProfileDelegate?.newProfile(new: false)
        }
        // Read configurations and Scheduledata
        self.readConfigurationsAndSchedules()
        // Make sure loading profile
        self.loadProfileMenu = true
        self.displayProfile()
        self.refresh()
        // We have to start any Scheduled process again - if any
        self.startProcess()
    }

    func enableProfileMenu() {
        self.loadProfileMenu = true
        self.showProcessInfo(info: .profilesenabled)
        globalMainQueue.async(execute: { () -> Void in
            self.displayProfile()
        })
    }
}

// A scheduled task is executed
extension ViewControllertabMain: ScheduledJobInProgress {

    func start() {
        globalMainQueue.async(execute: {() -> Void in
            self.scheduledJobInProgress = true
            self.scheduledJobworking.startAnimation(nil)
        })
    }

    func completed() {
        globalMainQueue.async(execute: {() -> Void in
            self.scheduledJobInProgress = false
            self.scheduledJobworking.stopAnimation(nil)
        })
    }

    func notifyScheduledJob(config: Configuration?) {
        if config == nil {
            globalMainQueue.async(execute: {() -> Void in
                Alerts.showInfo("Scheduled backup DID not execute?")
            })
        } else {
            globalMainQueue.async(execute: {() -> Void in
                self.presentViewControllerAsSheet(self.viewControllerScheduledBackupInWork)
            })
        }
    }
}

// New scheduled task entered. Delete old one and
// calculated new object (queue)
extension ViewControllertabMain: NewSchedules {

    // Create new schedule object. Old object is released (deleted).
    func newSchedulesAdded() {
        self.schedules = nil
        self.schedules = ScheduleSortedAndExpand()
    }
}

// Rsync path is changed, update displayed rsync command
extension ViewControllertabMain: RsyncChanged {
    // If row is selected an update rsync command in view
    func rsyncchanged() {
        // Update rsync command in display
        self.setRsyncCommandDisplay()
    }
}

// Check for remote connections, reload table
// when completed.
extension ViewControllertabMain: Connections {
    // Function is called when testing of remote connections are compledet.
    // Function is just redrawing the mainTableView after getting info
    // about which remote servers are off/on line.
    // Remote servers offline are marked with red line in mainTableView
    func displayConnections() {
        // Only do a reload if we are in the main view
        guard Configurations.shared.allowNotifyinMain == true else {
            return
        }
        self.serverOff = self.tools!.gettestAllremoteserverConnections()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

// Uuups, new version is discovered
extension ViewControllertabMain: newVersionDiscovered {
    // Notifies if new version is discovered
    func notifyNewVersion() {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.newVersionViewController)
        })
    }
}

// Dismisser for sheets
extension ViewControllertabMain: DismissViewController {
    // Function for dismissing a presented view
    // - parameter viewcontroller: the viewcontroller to be dismissed
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
        // Reset radiobuttons
        self.edit.state = .off
        self.rsyncparams.state = .off
        self.loadProfileMenu = true
        self.singletask = nil
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
            self.displayProfile()
        })
    }
}

// Called when either a terminatopn of Process is
// discovered or data is availiable in the filehandler
// See file rsyncProcess.swift.
extension ViewControllertabMain: UpdateProgress {

    // Delegate functions called from the Process object
    // Protocol UpdateProgress two functions, ProcessTermination() and FileHandler()

    func processTermination() {
        self.ready = true
        // NB: must check if single run or batch run
        if let singletask = self.singletask {
            self.output = singletask.output
            self.process = singletask.process
            singletask.processTermination()
        } else {
            // Batch run
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                // If abort in batchview just bail out and terminate. The
                // Process Termination is caused by terminate the Process task
                guard pvc.count > 0 else {
                    return
                }
                self.batchObjectDelegate = pvc[0]
                self.batchtask = self.batchObjectDelegate?.getTaskObject()
            }
            self.output = self.batchtask!.output
            self.process = self.batchtask!.process
            self.batchtask!.processTermination()
        }
    }

    // Function is triggered when Process outputs data in filehandler
    // Process is either in singleRun or batchRun
    func fileHandler() {
        self.showProcessInfo(info: .countfiles)
        if self.batchtask != nil {
            // Batch run
            if let batchobject = Configurations.shared.getBatchdataObject() {
                let work = batchobject.nextBatchCopy()
                if work.1 == 1 {
                    // Real work is done, must set reference to Process object in case of Abort
                    self.process = self.batchtask!.process
                    batchobject.updateInProcess(numberOfFiles: self.batchtask!.output!.getMaxcount())
                    // Refresh view in Batchwindow
                    if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                        self.refreshDelegate = pvc[0]
                        self.refreshDelegate?.refresh()
                    }
                }
            }
        } else {
        // Single task run
            guard self.singletask != nil else {
                return
            }
            self.output = self.singletask!.output
            self.process = self.singletask!.process
            if let pvc2 = self.presentedViewControllers as? [ViewControllerProgressProcess] {
                if pvc2.count > 0 {
                    self.processupdateDelegate = pvc2[0]
                    self.processupdateDelegate?.fileHandler()
                }
            }
        }
    }
}

// Deselect a row
extension ViewControllertabMain: deselectRowTable {
    // deselect a row after row is deleted
    func deselectRow() {
        guard self.index != nil else {
            return
        }
        self.mainTableView.deselectRow(self.index!)
    }
}

// If rsync throws any error
extension ViewControllertabMain: RsyncError {
    func rsyncerror() {
        // Set on or off in user configuration
        if Configurations.shared.rsyncerror {
            globalMainQueue.async(execute: { () -> Void in
                self.setInfo(info: "Error", color: .red)
                self.showProcessInfo(info: .error)
                self.setRsyncCommandDisplay()
                // Abort any operations
                if let process = self.process {
                    process.terminate()
                    self.process = nil
                }
                // Either error in single task or batch task
                if self.singletask != nil {
                    self.singletask!.error()
                }
                if self.batchtask != nil {
                    self.batchtask!.error()
                }
            })
        }
    }
}

// If, for any reason, handling files or directory throws an error
extension ViewControllertabMain: ReportErrorInMain {
    func fileerror(errorstr: String) {
        globalMainQueue.async(execute: { () -> Void in
            self.setInfo(info: "Error", color: .red)
            self.showProcessInfo(info: .error)
            // Dump the errormessage in rsynccommand field
            self.rsyncCommand.stringValue = errorstr
        })
    }
}

// Abort task from progressview
extension ViewControllertabMain: AbortOperations {

    // Abort any task, either single- or batch task
    func abortOperations() {
        // Terminates the running process
        self.showProcessInfo(info:.abort)
        if let process = self.process {
            process.terminate()
            self.index = nil
            self.working.stopAnimation(nil)
            self.schedules = nil
            self.process = nil
            // Create workqueu and add abort
            self.setInfo(info: "Abort", color: .red)
            self.rsyncCommand.stringValue = ""
        } else {
            self.working.stopAnimation(nil)
            self.rsyncCommand.stringValue = "Selection out of range - aborting"
            self.process = nil
            self.index = nil
        }
        if let batchobject = Configurations.shared.getBatchdataObject() {
            // Empty queue in batchobject
            batchobject.abortOperations()
            // Set reference to batchdata = nil
            Configurations.shared.deleteBatchData()
            self.schedules = nil
            self.process = nil
            self.setInfo(info: "Abort", color: .red)
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

extension ViewControllertabMain:SingleTask {

    // Just for updating process info
    func showProcessInfo(info: DisplayProcessInfo) {
        globalMainQueue.async(execute: { () -> Void in
            switch info {
            case .estimating:
                self.processInfo.stringValue = "Estimate"
            case .executing:
                self.processInfo.stringValue = "Execute"
            case .setmaxNumber:
                self.processInfo.stringValue = "Set max number"
            case .loggingrun:
                self.processInfo.stringValue = "Logging run"
            case .countfiles:
                self.processInfo.stringValue = "Count files"
            case .changeprofile:
                self.processInfo.stringValue = "Change profile"
            case .profilesenabled:
                self.processInfo.stringValue = "Profiles enabled"
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
            self.presentViewControllerAsSheet(self.viewControllerProgress)
        })
    }

    func presentViewInformation(output: OutputProcess) {
        self.output = output
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerInformation)
        })
    }

    func terminateProgressProcess() {
        if let pvc2 = self.presentedViewControllers as? [ViewControllerProgressProcess] {
            if pvc2.count > 0 {
                self.processupdateDelegate = pvc2[0]
                self.processupdateDelegate?.processTermination()
            }
        }
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

    func singleTaskAbort(process: Process?) {
        self.process = process
        self.abortOperations()
    }

    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    func setNumbers(output: OutputProcess?) {

        globalMainQueue.async(execute: { () -> Void in
            self.showProcessInfo(info: .setmaxNumber)
            guard output != nil else {
                self.transferredNumber.stringValue = ""
                self.transferredNumberSizebytes.stringValue = ""
                self.totalNumber.stringValue = ""
                self.totalNumberSizebytes.stringValue = ""
                self.totalDirs.stringValue = ""
                self.newfiles.stringValue = ""
                self.deletefiles.stringValue = ""
                return
            }
            let number = Numbers(output: output!.getOutput())
            number.setNumbers()
            self.transferredNumber.stringValue = NumberFormatter.localizedString(from:NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumber)), number: NumberFormatter.Style.decimal)
            self.transferredNumberSizebytes.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumberSizebytes)), number: NumberFormatter.Style.decimal)
            self.totalNumber.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumber)), number: NumberFormatter.Style.decimal)
            self.totalNumberSizebytes.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumberSizebytes)), number: NumberFormatter.Style.decimal)
            self.totalDirs.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalDirs)), number: NumberFormatter.Style.decimal)
            self.newfiles.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .new)), number: NumberFormatter.Style.decimal)
            self.deletefiles.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .delete)), number: NumberFormatter.Style.decimal)
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

extension ViewControllertabMain: BatchTask {

    func presentViewBatch() {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerBatch)
        })
    }

    func progressIndicatorViewBatch(operation: BatchViewProgressIndicator) {
        switch operation {
        case .stop:
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                self.indicatorDelegate = pvc[0]
                self.refreshDelegate = pvc[0]
                self.indicatorDelegate?.stop()
                self.refreshDelegate?.refresh()
            }
        case .start:
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                self.indicatorDelegate = pvc[0]
                self.indicatorDelegate?.start()
            }
        case .complete:
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                self.indicatorDelegate = pvc[0]
                self.indicatorDelegate?.complete()
            }
        case .refresh:
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                self.refreshDelegate = pvc[0]
                self.refreshDelegate?.refresh()
            }
        }
    }

    func setOutputBatch(outputbatch: OutputBatch?) {
        self.outputbatch = outputbatch
    }
}
