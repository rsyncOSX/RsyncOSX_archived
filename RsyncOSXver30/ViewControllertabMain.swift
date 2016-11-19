//
//  ViewControllertabMain.swift
//  RsyncOSXver30
//  The Main ViewController.
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

// Protocol for doing a refresh of updated tableView
protocol RefreshtableViewBatch : class {
    func refreshInBatch()
}

// Protocols for instruction start/stop progressviewindicator
protocol StartStopProgressIndicatorViewBatch : class {
    func start()
    func stop()
    func complete()
}

// Protocol for dismiss a viewcontroller
// It is the presenting viewcontroller which is
// responsible to dismiss the viewcontroller
protocol DismissViewController : class {
    func dismiss_view(viewcontroller:NSViewController)
}

// Protocol when called when Process discovers
// Process termination and when Filehandler discover data
// Used in Process.
protocol UpdateProgress : class {
    func ProcessTermination()
    func FileHandler()
}

class ViewControllertabMain : NSViewController, Information, Abort, Count, RefreshtableViewtabMain, StartBatch, ReadConfigurationsAgain, RsyncUserParams, GetSelecetedIndex, NewSchedules, StartNextScheduledTask, DismissViewController, UpdateProgress, ScheduledJobInProgress, RsyncChanged, Connections, AddProfiles, newVersionDiscovered {

    // Protocol function used in Process().
    weak var processupdate_delegate:UpdateProgress?
    // Delegate function for doing a refresh of NSTableView in ViewControllerBatch
    weak var refresh_delegate:RefreshtableViewBatch?
    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicator_delegate:StartStopProgressIndicatorViewBatch?

    
    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet weak var working: NSProgressIndicator!
    // Displays the rsyncCommand
    @IBOutlet weak var rsyncCommand: NSTextField!
    // If On result of Dryrun is presented before
    // executing the real run
    @IBOutlet weak var showInfoDryrun: NSButton!
    // Outlet for showing if dryrun or not
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
    
    
    
    // REFERENCE VARIABLES
    
    // Reference to Process task
    private var process:Process?
    // Index to selected row, index is set when row is selected
    private var index:Int?
    // Getting output from rsync 
    private var output:outputProcess?
    // Holding max count 
    private var maxcount:Int = 0
    // HiddenID task, set when row is selected
    private var hiddenID:Int?
    // Reference to Schedules object
    fileprivate var schedules : ScheduleSortedAndExpand?
    // Bool if one or more remote server is offline
    // Used in testing if remote server is on/off-line
    fileprivate var serverOff:[Bool]?
    // Single task work queu
    private var workload:singleTask?
    
    // Schedules in progress
    private var scheduledJobInProgress:Bool = false
    // Ready for execute again
    private var ready:Bool = true
    // Can load profiles
    // Load profiles only when testing for connections are done.
    // Application crash if not
    private var loadProfileMenu:Bool = false
    
    // Information about rsync output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    lazy var ViewControllerInformation: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardInformationID")
            as! NSViewController
    }()
    
    // Progressbar process 
    // self.presentViewControllerAsSheet(self.ViewControllerProgress)
    lazy var ViewControllerProgress: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardProgressID")
            as! NSViewController
    }()
    
    // Batch process
    // self.presentViewControllerAsSheet(self.ViewControllerBatch)
    lazy var ViewControllerBatch: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardBatchID")
            as! NSViewController
    }()

    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    lazy var ViewControllerUserconfiguration: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardUserconfigID")
            as! NSViewController
    }()
    
    // Rsync userparams
    // self.presentViewControllerAsSheet(self.ViewControllerRsyncParams)
    lazy var ViewControllerRsyncParams: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardRsyncParamsID")
            as! NSViewController
    }()

    // New version window
    // self.presentViewControllerAsSheet(self.newVersionViewController)
    lazy var newVersionViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardnewVersionID")
            as! NSViewController
    }()
    
    // Edit
    // self.presentViewControllerAsSheet(self.editViewController)
    lazy var editViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardEditID")
            as! NSViewController
    }()
    
    // Profile
    // self.presentViewControllerAsSheet(self.ViewControllerProfile)
    lazy var ViewControllerProfile: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "ProfileID")
            as! NSViewController
    }()

    // ScheduledBackupInWorkID
    // self.presentViewControllerAsSheet(self.ViewControllerScheduledBackupInWork)
    lazy var ViewControllerScheduledBackupInWork: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "ScheduledBackupInWorkID")
            as! NSViewController
    }()
    
    // About
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var ViewControllerAbout: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "AboutID")
            as! NSViewController
    }()
    
    
    // Function for dismissing a presented view
    // - parameter viewcontroller: the viewcontroller to be dismissed
    func dismiss_view(viewcontroller:NSViewController) {
        self.dismissViewController(viewcontroller)
        GlobalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
    
    // PROTOCOL functions
    
    // Protocol Information
    // Get information from rsync output.
    func getInformation() -> [String] {
        if (self.output != nil) {
            if (self.workload == nil) {
                return self.output!.getOutputbatch()
            } else {
                return self.output!.getOutput()
            }
        } else {
            return [""]
        }
    }
    
    // Protocol Count, two functions maxCount and inprogressCount
    // Maxnumber of files counted
    func maxCount() -> Int {
        return self.maxcount
    }
    
    // Counting number of files
    // Function is called when Process discover FileHandler notification
    func inprogressCount() -> Int {
        return self.output!.getOutputCount()
    }
    
    // Protocol RefreshtableViewtabMain
    // Refresh tableView in main
    func refreshInMain() {
        // Create and read schedule objects again
        // Releasing previous allocation before creating new one
        self.schedules = nil
        self.schedules = ScheduleSortedAndExpand()
        GlobalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
    
    // Protocol StartBatch
    // Two functions runcBatch and abortOperations.
    // Functions are called from batchView.
    func runBatch() {
        // No scheduled opertaion in progress
        if (self.scheduledOperationInProgress() == false ) {
            if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
                // Just copy the work object.
                // The work object will be removed in Process termination
                let work = batchobject.nextBatchCopy()
                // Get the index if given hiddenID (in work.0)
                let index:Int = SharingManagerConfiguration.sharedInstance.getIndex(work.0)
                switch (work.1) {
                case 0:
                    if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                        self.indicator_delegate = pvc[0]
                        self.indicator_delegate?.start()
                    }
                    let arguments:[String] = SharingManagerConfiguration.sharedInstance.getrsyncArgumentOneConfiguration(index: index, argtype: .argdryRun)
                    let process = rsyncProcess(operation: false, tabMain: true, command : nil)
                    // Setting reference to process for Abort if requiered
                    process.executeProcess(arguments, output: self.output!)
                    self.process = process.getProcess()
                case 1:
                    let arguments:[String] = SharingManagerConfiguration.sharedInstance.getrsyncArgumentOneConfiguration(index: index, argtype: .arg)
                    let process = rsyncProcess(operation: false, tabMain: true, command : nil)
                    // Setting reference to process for Abort if requiered
                    process.executeProcess(arguments, output: self.output!)
                    self.process = process.getProcess()
                case -1:
                    if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                        self.indicator_delegate = pvc[0]
                        self.indicator_delegate?.complete()
                    }
                default : break
                }
            }
        } else {
            Alerts.showInfo("Scheduled operation in progress")
        }
    }
    
    func abortOperations() {
        // Terminates the running process
        self.showProcessInfo(what:8)
        if let process = self.process {
            process.terminate()
            self.index = nil
            self.working.stopAnimation(nil)
            self.schedules = nil
            self.process = nil
            self.workload = nil
            // Create workqueu and add abort
            self.workload = singleTask(task: .abort)
            self.setInfo(info: "Abort", color: NSColor.red)
            self.rsyncCommand.stringValue = ""
        } else {
            self.rsyncCommand.stringValue = "Selection out of range - aborting"
            self.process = nil
            self.workload = nil
            self.index = nil
        }
        if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
            // Empty queue in batchobject
            batchobject.abortOperations()
            // Set reference to batchdata = nil
            SharingManagerConfiguration.sharedInstance.deleteBatchData()
            self.schedules = nil
            self.process = nil
            self.workload = nil
            self.workload = singleTask(task: .abort)
            self.setInfo(info: "Abort", color: NSColor.red)
        }
    }
    
    func closeOperation() {
        self.process = nil
        self.workload = nil
        self.setInfo(info: "", color: NSColor.black)
    }
    
    // Protocol ReadConfigurationsAgain
    func readConfigurations() {
        SharingManagerConfiguration.sharedInstance.getAllConfigurationsandArguments()
        if (SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecount() > 0 ) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        // Read schedule objects again
        self.schedules = nil
        self.schedules = ScheduleSortedAndExpand()
        if (self.index != nil) {
            self.rsyncCommand.stringValue = Utils.sharedInstance.setRsyncCommandDisplay(index: self.index!, dryRun: true)
        }
    }

    // Protocol RsyncUserParams
    // Triggered when userparams are updated
    // Do a reread of all Configurations
    func rsyncuserparamsupdated() {
        self.readConfigurations()
        self.rsyncCommand.stringValue = Utils.sharedInstance.setRsyncCommandDisplay(index: self.index!, dryRun: true)
        self.rsyncparams.state = 0
    }
    
    // Protocol for sending index of row selected in table
    func getindex() -> Int {
        if (self.index != nil) {
            return self.index!
        } else {
            return -1
        }
    }
    
    // Protocol StartNextScheduledTask
    // Start next job
    func startProcess() {
        // Start any Scheduled job
        _ = ScheduleOperation()
    }
    
    // Protocol NewSchedules
    // Notfied if new schedules are added.
    // Create new schedule object. Old object is
    // released (deleted).
    func newSchedulesAdded() {
        self.schedules = nil
        self.schedules = ScheduleSortedAndExpand()
    }
    
    // Protocol ScheduledJobInProgress
    // Three functions start, notifyScheduledJob and complete, start and stop progressview
    // and set state on/off.
    func start() {
        GlobalMainQueue.async(execute: {() -> Void in
            self.scheduledJobInProgress = true
            self.scheduledJobworking.startAnimation(nil)
        })
    }
    
    func completed() {
        GlobalMainQueue.async(execute: {() -> Void in
            self.scheduledJobInProgress = false
            self.scheduledJobworking.stopAnimation(nil)
        })
    }
    
    func notifyScheduledJob(config: configuration?) {
        if (config == nil) {
            GlobalMainQueue.async(execute: {() -> Void in
                Alerts.showInfo("Scheduled backup DID not execute?")
            })
        } else {
            GlobalMainQueue.async(execute: {() -> Void in
                self.presentViewControllerAsSheet(self.ViewControllerScheduledBackupInWork)
            })
        }
    }
    
    // Protocol RsyncChanged
    // If row is selected an update rsync command in view
    func rsyncchanged() {
        if let index = self.index {
          self.rsyncCommand.stringValue = Utils.sharedInstance.setRsyncCommandDisplay(index: index, dryRun: true)
        }
    }
    
    // Protocol Connections
    // Function is called when testing of remote connections are compledet.
    // Function is just redrawing the mainTableView after getting info
    // about which remote servers are off/on line.
    // Remote servers offline are marked with red line in mainTableView
    func displayConnections() {
        self.serverOff = Utils.sharedInstance.gettestAllremoteserverConnections()
        GlobalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
    
    // Protocol AddProfile
    // Two functions newProfile() and enableProfileMenu()
    // Function is called from profiles when new or
    // default profiles is seleceted
    func newProfile() {
        weak var newProfile_delegate: AddProfiles?
        // By setting self.schedules = nil start jobs are restaret in ViewDidAppear
        self.schedules = nil
        self.loadProfileMenu = false
        self.ReReadConfigurationsAndSchedules()
        self.displayProfile()
        self.refreshInMain()
        // Reset in tabSchedule
        if let pvc = SharingManagerConfiguration.sharedInstance.ScheduleObjectMain as? ViewControllertabSchedule {
            newProfile_delegate = pvc
            newProfile_delegate?.newProfile()
        }
        // We have to start any Scheduled process again - if any
        self.startProcess()
        // Check all remote servers for connection
        Utils.sharedInstance.testAllremoteserverConnections()
    }
    
    func enableProfileMenu() {
        self.loadProfileMenu = true
        self.showProcessInfo(what: 7)
        GlobalMainQueue.async(execute: { () -> Void in
            self.displayProfile()
        })
    }
    
    // Protocol newVersionDiscovered
    // Notifies if new version is discovered
    func notifyNewVersion() {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.newVersionViewController)
        })
    }
    
    // BUTTONS AND ACTIONS
    
    @IBOutlet weak var edit: NSButton!
    @IBOutlet weak var rsyncparams: NSButton!
    @IBOutlet weak var delete: NSButton!
    
    // Menus as Radiobuttons for Edit functions in tabMainView
    @IBAction func Radiobuttons(_ sender: NSButton) {
        if (self.index != nil) {
            // rsync params
            if (self.rsyncparams.state == 1) {
                if (self.index != nil) {
                    GlobalMainQueue.async(execute: { () -> Void in
                        self.presentViewControllerAsSheet(self.ViewControllerRsyncParams)
                    })
                }
            // Edit task
            } else if (self.edit.state == 1) {
                if (self.index != nil) {
                    GlobalMainQueue.async(execute: { () -> Void in
                        self.presentViewControllerAsSheet(self.editViewController)
                    })
                }
            // Delete files
            } else if (self.delete.state == 1) {
                let answer = Alerts.dialogOKCancel("Delete selected task?", text: "Cancel or OK")
                if (answer) {
                    if (self.hiddenID != nil) {
                        // Delete Configurations and Schedules by hiddenID
                        SharingManagerConfiguration.sharedInstance.deleteConfigurationsByhiddenID(hiddenID: self.hiddenID!)
                        SharingManagerSchedule.sharedInstance.deleteSchedulesbyHiddenID(hiddenID: self.hiddenID!)
                        // Reading main Configurations and Schedule to memory
                        self.ReReadConfigurationsAndSchedules()
                        // And create a new Schedule object
                        // Just calling the protocol function
                        self.newSchedulesAdded()
                        self.hiddenID = nil
                        self.index = nil
                        self.refreshInMain()
                    }
                }
            }
        } else {
            self.rsyncCommand.stringValue = " ... Please select a task first ..."
        }
    }
    
    // Presenting Information from Rsync
    @IBAction func Information(_ sender: NSButton) {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerInformation)
        })
    }
    
    // Abort button
    @IBAction func Abort(_ sender: NSButton) {
        // abortOperations is the delegate function for 
        // aborting batch operations
        self.abortOperations()
        self.process = nil
    }

    // Userconfiguration button
    @IBAction func Userconfiguration(_ sender: NSButton) {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
        })
    }
    
    @IBAction func profiles(_ sender: NSButton) {
        if (self.loadProfileMenu == true) {
            self.showProcessInfo(what:6)
            GlobalMainQueue.async(execute: { () -> Void in
                self.presentViewControllerAsSheet(self.ViewControllerProfile)
            })
        } else {
            self.displayProfile()
        }
        
    }
    
    @IBAction func About (_ sender: NSButton) {
        self.presentViewControllerAsModalWindow(self.ViewControllerAbout)
    }
    

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        // Progress indicator
        self.working.usesThreadedAnimation = true
        self.scheduledJobworking.usesThreadedAnimation = true
        self.ReReadConfigurationsAndSchedules()
        // Setting reference to self, used when calling delegate functions
        SharingManagerConfiguration.sharedInstance.ViewObjectMain = self
        // Create a Schedules object
        // Start waiting for next Scheduled job (if any)
        self.schedules = ScheduleSortedAndExpand()
        self.startProcess()
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllertabMain.tableViewDoubleClick(sender:))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.loadProfileMenu = false
        self.showProcessInfo(what: 0)
        // Allow notify about Scheduled jobs
        SharingManagerConfiguration.sharedInstance.allowNotifyinMain = true
        self.setInfo(info: "", color: NSColor.black)
        // Setting reference to ViewController
        // Used to call delegate function from other class
        SharingManagerConfiguration.sharedInstance.ViewObjectMain = self
        if (SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecount() > 0 ) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        // Check all remote servers for connection
        Utils.sharedInstance.testAllremoteserverConnections()
        // Update rsync command in view i case changed 
        self.rsyncchanged()
        // Show which profile
        self.displayProfile()
        if (self.schedules == nil) {
            self.schedules = ScheduleSortedAndExpand()
        }
        self.ready = true
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        // Do not allow notify in Main
        SharingManagerConfiguration.sharedInstance.allowNotifyinMain = false
    }
    
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender:AnyObject) {
        if (SharingManagerConfiguration.sharedInstance.allowDoubleclick == true) {
            if (self.ready) {
                self.executeSingelTask()
            }
            self.ready = false
        }
    }

    
    // Execute SINGLE TASKS only
    // Start of executing SINGLE tasks
    // After start the function ProcessTermination()
    // which is triggered when a Process termination is
    // discovered, completes the task.
    @IBAction func executeTask(_ sender: NSButton) {
        if (self.ready) {
            self.executeSingelTask()
        }
        self.ready = false
    }
    
    // Because single task can be activated by double click from 
    // Table as well.
    private func executeSingelTask() {
        
        if (self.scheduledOperationInProgress() == false && SharingManagerConfiguration.sharedInstance.noRysync == false){
            if (self.workload == nil) {
                self.workload = singleTask()
            }
            let arguments:[String]?
            let process = rsyncProcess(operation: false, tabMain: true, command : nil)
            self.process = nil
            self.output = nil
            
            switch (self.workload!.readworking()) {
            case .estimate_singlerun:
                if let index = self.index {
                    self.working.startAnimation(nil)
                    self.showProcessInfo(what: 1)
                    arguments = SharingManagerConfiguration.sharedInstance.getrsyncArgumentOneConfiguration(index: index, argtype: .argdryRun)
                    self.output = outputProcess()
                    process.executeProcess(arguments!, output: self.output!)
                    self.process = process.getProcess()
                    self.setInfo(info: "Execute", color: NSColor.blue)
                }
            case .execute_singlerun:
                self.showProcessInfo(what: 2)
                if let index = self.index {
                    GlobalMainQueue.async(execute: { () -> Void in
                        self.presentViewControllerAsSheet(self.ViewControllerProgress)
                    })
                    arguments = SharingManagerConfiguration.sharedInstance.getrsyncArgumentOneConfiguration(index: index, argtype: .arg)
                    self.output = outputProcess()
                    process.executeProcess(arguments!, output: self.output!)
                    self.process = process.getProcess()
                    self.setInfo(info: "", color: NSColor.black)
                }
            case .abort:
                self.workload = nil
                self.setInfo(info: "Abort", color: NSColor.red)
            case .empty:
                self.workload = nil
                self.setInfo(info: "Estimate", color: NSColor.blue)
            default:
                self.workload = nil
                self.setInfo(info: "Estimate", color: NSColor.blue)
                break
            }
        } else {
            self.noRsync()
        }
    }
    
    private func setInfo(info:String, color:NSColor) {
        self.dryRunOrRealRun.stringValue = info
        self.dryRunOrRealRun.textColor = color
    
    }
    
    // Execute BATCH TASKS only
    // Start of BATCH tasks.
    // After start the function ProcessTermination()
    // which is triggered when a Process termination is
    // discovered, takes care of next task according to
    // status and next work in batchOperations which
    // also includes a queu of work.
    @IBAction func executeBatch(_ sender: NSButton) {
        
        if (self.scheduledOperationInProgress() == false && SharingManagerConfiguration.sharedInstance.noRysync == false){
            self.workload = nil
            self.workload = singleTask(task: .batchrun)
            self.setInfo(info: "Batchrun", color: NSColor.blue)
            // Create the output object for rsync
            self.output = nil
            self.output = outputProcess()
            // Get all Configs marked for batch
            let configs = SharingManagerConfiguration.sharedInstance.getConfigurationsBatch()
            let batchObject = batchOperations(batchtasks: configs)
            // Set the reference to batchData object in SharingManagerConfiguration
            SharingManagerConfiguration.sharedInstance.setbatchDataQueue(batchdata: batchObject)
            GlobalMainQueue.async(execute: { () -> Void in
                self.presentViewControllerAsSheet(self.ViewControllerBatch)
            })
        } else {
            self.noRsync()
        }
    }
    
    private func noRsync() {
        if (SharingManagerConfiguration.sharedInstance.noRysync == true) {
            if let rsync = SharingManagerConfiguration.sharedInstance.rsyncPath {
                Alerts.showInfo("ERROR: no rsync in " + rsync)
            }
        } else {
            Alerts.showInfo("Scheduled operation in progress")
        }
    }

    // True if scheduled task in progress
    private func scheduledOperationInProgress() -> Bool {
        var scheduleInProgress:Bool?
        if (self.schedules != nil) {
            scheduleInProgress = self.schedules!.getScheduledOperationInProgress()
        } else {
            scheduleInProgress = false
        }
        if (scheduleInProgress == false && self.scheduledJobInProgress == false){
            return false
        } else {
            return true
        }
    }
    
    
    // Reread bot Configurations and Schedules from persistent store to memory
    private func ReReadConfigurationsAndSchedules() {
        // Reading main Configurations to memory
        SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        SharingManagerConfiguration.sharedInstance.getAllConfigurationsandArguments()
        // Read all Scheduled data
        SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        // Read all scheduled data
        SharingManagerSchedule.sharedInstance.getAllSchedules()
    }

    // Delegate functions called from the Process object
    // Protocol UpdateProgress two functions, ProcessTermination() and FileHandler()
    
    func ProcessTermination() {
        
        self.ready = true
        
        // Making sure no nil pointer execption
        if let workload = self.workload {
            
            if (workload.readworking() != .batchrun) {
                
                // Pop topmost element of work queue
                switch (self.workload!.working()) {
                    
                case .estimate_singlerun:
                    
                    // Stopping the working (estimation) progress indicator
                    self.working.stopAnimation(nil)
                    // Getting and setting max file to transfer
                    self.setmaxNumbersOfFilesToTransfer()
                    // If showInfoDryrun is on present result of dryrun automatically
                    if (self.showInfoDryrun.state == 1) {
                        GlobalMainQueue.async(execute: { () -> Void in
                            self.presentViewControllerAsSheet(self.ViewControllerInformation)
                        })
                    }
                    
                case .execute_singlerun:
                    
                    if let pvc2 = self.presentedViewControllers as? [ViewControllerProgressProcess] {
                        if (pvc2.count > 0) {
                            self.processupdate_delegate = pvc2[0]
                            self.processupdate_delegate?.ProcessTermination()
                        }
                    }
                    // If showInfoDryrun is on present result of dryrun automatically
                    if (self.showInfoDryrun.state == 1) {
                        GlobalMainQueue.async(execute: { () -> Void in
                            self.presentViewControllerAsSheet(self.ViewControllerInformation)
                        })
                    }
                    self.showProcessInfo(what: 4)
                    SharingManagerConfiguration.sharedInstance.setCurrentDateonConfiguration(self.index!)
                    SharingManagerSchedule.sharedInstance.addScheduleResultManuel(self.hiddenID!, result: self.output!.statistics(numberOfFiles: self.transferredNumber.stringValue)[0])
                    
                case .abort:
                    self.abortOperations()
                    self.workload = nil
                    
                case .empty:
                    self.workload = nil
                    
                default:
                    self.workload = nil
                    break
                }
            } else {
                // We are in batch
                self.inBatchwork()
            }
        }
    }
    
    private func inBatchwork() {
        // Take care of batchRun activities
        if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
            // Remove the first worker object
            let work = batchobject.nextBatchRemove()
            // get numbers from dry-run
            // Getting and setting max file to transfer
            self.setmaxNumbersOfFilesToTransfer()
            // Setting maxcount of files in object
            batchobject.setEstimated(numberOfFiles: self.maxcount)
            // 0 is estimationrun, 1 is real run
            switch (work.1) {
            case 0:
                // Do a refresh of NSTableView in ViewControllerBatch
                // Stack of ViewControllers
                if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                    self.refresh_delegate = pvc[0]
                    self.indicator_delegate = pvc[0]
                    self.refresh_delegate?.refreshInBatch()
                    self.indicator_delegate?.stop()
                }
                self.showProcessInfo(what: 1)
                self.runBatch()
            case 1:
                self.maxcount = self.output!.getOutputCount()
                // Update files in work
                batchobject.updateInProcess(numberOfFiles: self.maxcount)
                batchobject.setCompleted()
                self.output!.copySummarizedResultBatch(numberOfFiles: self.transferredNumber.stringValue)
                if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                    self.refresh_delegate = pvc[0]
                    self.indicator_delegate = pvc[0]
                    self.refresh_delegate?.refreshInBatch()
                }
                // Set date on Configuration
                let index = SharingManagerConfiguration.sharedInstance.getIndex(work.0)
                let hiddenID = SharingManagerConfiguration.sharedInstance.gethiddenID(index: index)
                SharingManagerConfiguration.sharedInstance.setCurrentDateonConfiguration(index)
                SharingManagerSchedule.sharedInstance.addScheduleResultManuel(hiddenID, result: self.output!.statistics(numberOfFiles: self.transferredNumber.stringValue)[0])
                // Reset counter before next run
                self.output!.removeObjectsOutput()
                self.showProcessInfo(what: 2)
                self.runBatch()
            default :
                break
            }
        }
    }
    
    func FileHandler() {
        self.showProcessInfo(what: 5)
        if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
            let work = batchobject.nextBatchCopy()
            if work.1 == 1 {
                // Real work is done
                self.maxcount = self.output!.getOutputCount()
                batchobject.updateInProcess(numberOfFiles: self.maxcount)
                // Refresh view in Batchwindow
                if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                    self.refresh_delegate = pvc[0]
                    self.refresh_delegate?.refreshInBatch()
                }
            }
        } else {
            // Refresh ProgressView single run
            if let pvc2 = self.presentedViewControllers as? [ViewControllerProgressProcess] {
                if (pvc2.count > 0) {
                    self.processupdate_delegate = pvc2[0]
                    self.processupdate_delegate?.FileHandler()
                }
            }
        }
    }
    
    //  End delegate functions Process object
    
    // Function for setting max files to be copied
    // Function is called in ProcessTermination()
    private func setmaxNumbersOfFilesToTransfer () {
        // Getting max count
        self.showProcessInfo(what: 3)
        if (self.output!.getTransferredNumbers(numbers: .totalNumber) > 0) {
            self.setNumbers(setvalues: true)
            if (self.output!.getTransferredNumbers(numbers: .transferredNumber) > 0) {
                self.maxcount = self.output!.getTransferredNumbers(numbers: .transferredNumber)
            } else {
                self.maxcount = self.output!.getOutputCount()
            }
        } else {
            self.maxcount = self.output!.getOutputCount()
        }
    }
    
    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    private func setNumbers (setvalues : Bool) {
        if (setvalues) {
            self.transferredNumber.stringValue = NumberFormatter.localizedString(from: NSNumber(value: self.output!.getTransferredNumbers(numbers: .transferredNumber)), number: NumberFormatter.Style.decimal)
            self.transferredNumberSizebytes.stringValue = NumberFormatter.localizedString(from: NSNumber(value: self.output!.getTransferredNumbers(numbers: .transferredNumberSizebytes)), number: NumberFormatter.Style.decimal)
            self.totalNumber.stringValue = NumberFormatter.localizedString(from: NSNumber(value: self.output!.getTransferredNumbers(numbers: .totalNumber)), number: NumberFormatter.Style.decimal)
            self.totalNumberSizebytes.stringValue = NumberFormatter.localizedString(from: NSNumber(value: self.output!.getTransferredNumbers(numbers: .totalNumberSizebytes)), number: NumberFormatter.Style.decimal)
            self.totalDirs.stringValue = NumberFormatter.localizedString(from: NSNumber(value: self.output!.getTransferredNumbers(numbers: .totalDirs)), number: NumberFormatter.Style.decimal)
        } else {
            self.transferredNumber.stringValue = ""
            self.transferredNumberSizebytes.stringValue = ""
            self.totalNumber.stringValue = ""
            self.totalNumberSizebytes.stringValue = ""
            self.totalDirs.stringValue = ""
        }
    }
    
    // Function for setting profile
    private func displayProfile() {
        
        guard (self.loadProfileMenu == true) else {
            self.profilInfo.stringValue = "Profile: please wait..."
            self.profilInfo.textColor = NSColor.blue
            return
        }
        
        if let profile = SharingManagerConfiguration.sharedInstance.getProfile() {
            self.profilInfo.stringValue = "Profile: " + profile
            self.profilInfo.textColor = NSColor.blue
        } else {
            self.profilInfo.stringValue = "Profile: default"
            self.profilInfo.textColor = NSColor.black
        }
        
    }
    
    // Function for setting allowDouble click
    internal func displayAllowDoubleclick() {
        if (SharingManagerConfiguration.sharedInstance.allowDoubleclick == true) {
            self.allowDoubleclick.stringValue = "Double click: YES"
            self.allowDoubleclick.textColor = NSColor.blue
        } else {
            self.allowDoubleclick.stringValue = "Double click: NO"
            self.allowDoubleclick.textColor = NSColor.black
        }
    }
    
    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        if (self.ready == false) {
            self.abortOperations()
        }
        self.ready = true
        let myTableViewFromNotification = notification.object as! NSTableView
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.rsyncCommand.stringValue = Utils.sharedInstance.setRsyncCommandDisplay(index: index, dryRun: true)
            self.index = index
            self.hiddenID = SharingManagerConfiguration.sharedInstance.gethiddenID(index: index)
            // Reset output
            self.output = nil
            // Clear numbers from dryrun
            self.setNumbers(setvalues: false)
            self.workload = nil
            self.setInfo(info: "Estimate", color: NSColor.blue)
            self.process = nil
        } else {
            self.abortOperations()
        }
    }
    
    // Just for updating process info
    private func showProcessInfo(what:Int) {
        GlobalMainQueue.async(execute: { () -> Void in
            switch what {
            case 1:
                self.processInfo.stringValue = "Estimating"
            case 2:
                self.processInfo.stringValue = "Executing"
            case 3:
                self.processInfo.stringValue = "Set max number"
            case 4:
                self.processInfo.stringValue = "Logging run"
            case 5:
                self.processInfo.stringValue = "Count files"
            case 6:
                self.processInfo.stringValue = "Change profile"
            case 7:
                self.processInfo.stringValue = "Profiles enabled"
            case 8:
                self.processInfo.stringValue = "Abort"
            default:
                self.processInfo.stringValue = ""
                break
            }
        })
    }

}

extension ViewControllertabMain : NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecount()
    }
}

extension ViewControllertabMain : NSTableViewDelegate {
    
    // Function to test for remote server available or not
    // Used in tableview delegate
    private func testRow(_ row:Int) -> Bool {
        if let serverOff = self.serverOff {
            if (row < serverOff.count) {
                return serverOff[row]
            } else {
                return false
            }
        }
        return false
    }
    
    
    // TableView delegates
    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        if row > SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecount() - 1 {
            return nil
        }
        let object : NSDictionary = SharingManagerConfiguration.sharedInstance.getConfigurationsDataSource()![row]
        var text:String?
        var schedule :Bool = false
        let hiddenID:Int = SharingManagerConfiguration.sharedInstance.getConfigurations()[row].hiddenID
        if SharingManagerSchedule.sharedInstance.hiddenIDinSchedule(hiddenID) {
            text = object[tableColumn!.identifier] as? String
            if (text == "backup" || text == "restore") {
                schedule = true
            }
        }
        if ((tableColumn!.identifier) == "batchCellID") {
            return object[tableColumn!.identifier] as? Int!
        } else {
            var number:Int = 0
            if let obj = self.schedules {
                number = obj.numberOfFutureSchedules(hiddenID)
            }
            if (schedule && number > 0) {
                let returnstr = text! + " (" + String(number) + ")"
                return returnstr
            } else {
                if (self.testRow(row)) {
                    text = object[tableColumn!.identifier] as? String
                    let attributedString = NSMutableAttributedString(string:(text!))
                    let range = (text! as NSString).range(of: text!)
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.red, range: range)
                    return attributedString
                } else {
                    return object[tableColumn!.identifier] as? String
                }
            }
        }
    }
    
    // Toggling batch
    @objc(tableView:setObjectValue:forTableColumn:row:) func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if (SharingManagerConfiguration.sharedInstance.getConfigurations()[row].task == "backup") {
            SharingManagerConfiguration.sharedInstance.setBatchYesNo(row)
        }
    }
    
}


