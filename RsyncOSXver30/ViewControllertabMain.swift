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

// Protocol when a Scehduled job is starting and stopping
// USed to informed the presenting viewcontroller about what
// is going on
protocol ScheduledJobInProgress : class {
    func start()
    func completed()
}

class ViewControllertabMain : NSViewController, Information, Abort, Count, RefreshtableViewtabMain, StartBatch, ReadConfigurationsAgain, RsyncUserParams, SendSelecetedIndex, NewSchedules, StartNextScheduledTask, DismissViewController, UpdateProgress, ScheduledJobInProgress, RsyncChanged, Connections, AddProfiles {

    // Protocol function used in Process().
    weak var process_update:UpdateProgress?
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
    
    // STATE VARIABLES
    
    // Schedules in progress
    private var scheduledJobInProgress:Bool = false
    // In batcrun or not
    private var inbatchRun:Bool = false
    // True if abort is choosed
    private var abort:Bool = false
    // If task is estimated
    private var estimated:Bool = false
    
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

    

    // Function for dismissing a presented view
    // - parameter viewcontroller: the viewcontroller to be dismissed
    func dismiss_view(viewcontroller:NSViewController) {
        self.dismissViewController(viewcontroller)
        GlobalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
    
    // Protocol Information
    func getInformation() -> NSMutableArray {
        if (self.output != nil) {
            if (self.inbatchRun) {
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
    
    // Counting number of files so far
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
                    let process = rsyncProcess(notification: false, tabMain: true, command : nil)
                    // Setting reference to process for Abort if requiered
                    process.executeProcess(arguments, output: self.output!)
                    self.process = process.getProcess()
                case 1:
                    let arguments:[String] = SharingManagerConfiguration.sharedInstance.getrsyncArgumentOneConfiguration(index: index, argtype: .arg)
                    let process = rsyncProcess(notification: false, tabMain: true, command : nil)
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
        self.abortProcess()
        // If batchwindow closes during process - all jobs are aborted
        if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
            // Have to set self.index = nil here
            self.index = nil
            batchobject.abortOperations()
            // Set reference to batchdata = nil
            SharingManagerConfiguration.sharedInstance.deleteBatchData()
        }
    }
    
    func closeOperation() {
        self.resetflags()
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
    // Called from NSOperation ONLY
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
    // TWo functions start and complete, start and stop progressview
    // and set state on/off.
    func start() {
        self.scheduledJobInProgress = true
        self.scheduledJobworking.startAnimation(nil)
    }
    
    func completed() {
        self.scheduledJobInProgress = false
        self.scheduledJobworking.stopAnimation(nil)
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
    
    // Procol Protocols
    // Function is called from profiles when new or
    // default profiles is seleceted
    func newProfile() {
        self.ReReadConfigurationsAndSchedules()
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
        self.abortOperations()
        self.abort = true
        self.resetflags()
    }

    // Userconfiguration button
    @IBAction func Userconfiguration(_ sender: NSButton) {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
        })
    }
    
    @IBAction func profiles(_ sender: NSButton) {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerProfile)
        })
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
        // Box to show is dryrun or realrun next
        self.dryRunOrRealRun.stringValue = "estimate"
        // Create a Schedules object
        // Start waiting for next Scheduled job (if any)
        self.schedules = ScheduleSortedAndExpand()
        self.startProcess()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // check for new version, if true present download
        if (SharingManagerConfiguration.sharedInstance.URLnewVersion != nil) {
            if (SharingManagerConfiguration.sharedInstance.remindernewVersion == false) {
                GlobalMainQueue.async(execute: { () -> Void in
                    self.presentViewControllerAsSheet(self.newVersionViewController)
                })
            }
        }
        // Setting reference to ViewController
        // Used to call delegate function from other class
        SharingManagerConfiguration.sharedInstance.ViewObjectMain = self
        if (SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecount() > 0 ) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        // Test all remote servers for connection
        Utils.sharedInstance.testAllremoteserverConnections()
        // Update rsync command in view i case changed 
        self.rsyncchanged()
        // Show which profile
        self.displayProfile()
    }
    
    
    // Execute SINGLE TASKS only
    // Start of executing SINGLE tasks
    // After start the function ProcessTermination()
    // which is triggered when a Process termination is
    // discovered, completes the task.
    @IBAction func executeTask(_ sender: NSButton) {
        if (self.scheduledOperationInProgress() == false){
            self.inbatchRun = false
            if (self.process == nil && self.index != nil) {
                let process = rsyncProcess(notification: false, tabMain: true, command : nil)
                let arguments:[String]?
                if (self.estimated == false) {
                    // Start the working progress indicator
                    self.working.startAnimation(nil)
                    arguments = SharingManagerConfiguration.sharedInstance.getrsyncArgumentOneConfiguration(index: self.index!, argtype: .argdryRun)
                } else {
                    // Present taskbar progress
                    GlobalMainQueue.async(execute: { () -> Void in
                        self.presentViewControllerAsSheet(self.ViewControllerProgress)
                    })
                    arguments = SharingManagerConfiguration.sharedInstance.getrsyncArgumentOneConfiguration(index: self.index!, argtype: .arg)
                }
                // Flip estimated
                if (self.estimated == true) {
                    self.estimated = false
                } else {
                    self.estimated = true
                }
                // Create two objects for doing the real work.
                // the output object and the process object
                self.output = outputProcess()
                process.executeProcess(arguments!, output: self.output!)
                self.process = process.getProcess()
                self.abort = false
            } else {
            }
        } else {
            Alerts.showInfo("Scheduled operation in progress")
        }
    }
    
    // Execute BATCH TASKS only
    // Start of BATCH tasks.
    // After start the function ProcessTermination()
    // which is triggered when a Process termination is
    // discovered, takes care of next task according to
    // status and next work in batchOperations which
    // also includes a queu of work.
    @IBAction func executeBatch(_ sender: NSButton) {
        if (self.scheduledOperationInProgress() == false){
            // Create the output object for rsync
            self.output = nil
            self.output = outputProcess()
            // Set in batchRun
            self.inbatchRun = true
            // Get all Configs marked for batch
            let configs = SharingManagerConfiguration.sharedInstance.getConfigurationsBatch()
            let batchObject = batchOperations(batchtasks: configs)
            // Set the reference to batchData object in SharingManagerConfiguration
            SharingManagerConfiguration.sharedInstance.setbatchDataQueue(batchdata: batchObject)
            GlobalMainQueue.async(execute: { () -> Void in
                self.presentViewControllerAsSheet(self.ViewControllerBatch)
            })
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
    
    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = notification.object as! NSTableView
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.rsyncCommand.stringValue = Utils.sharedInstance.setRsyncCommandDisplay(index: index, dryRun: true)
            self.index = index
            self.hiddenID = SharingManagerConfiguration.sharedInstance.gethiddenID(index: index)
            // Reset estimated
            self.estimated = false
            // Reset output
            self.output = nil
            self.dryRunOrRealRun.stringValue = "estimate"
            // Clear numbers from dryrun
            self.setNumbers(setvalues: false)
        } else {
            self.index = nil
            self.hiddenID = nil
        }
    }
    
    // Reset and abort
    
    // Abort ongoing process and set schedules
    private func abortProcess() {
        if let process = self.process {
            process.terminate()
            self.working.stopAnimation(nil)
            self.schedules = nil
            self.process = nil
        }
    }
    
    // Reset flags to enable a real run after estimate run
    private func resetflags() {
        self.process = nil
        // if abort flag is set then reset abort flag
        if self.abort == true {
            self.abort = false
        }
        // Informal only
        if (self.dryRunOrRealRun.stringValue == "estimate") {
            self.dryRunOrRealRun.stringValue = "execute"
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
        // If task is aborted dont do anything
        if (self.abort == false) {
            // Check if in Batcrun or not
            if (self.inbatchRun == false ) {
                if let pvc2 = self.presentedViewControllers as? [ViewControllerProgressProcess] {
                    if (pvc2.count > 0) {
                        self.process_update = pvc2[0]
                        self.process_update?.ProcessTermination()
                    }
                }
                // Stopping the working progress indicator
                // Be prepared for next work
                self.working.stopAnimation(nil)
                // Getting max count
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
                // Estimated was TRUE but was set FALSE just before the real task was executed
                // Do an update of memory and the function is notifying when an refresh of table
                // is done. We have JUST completed an estimation run.
                if (self.estimated == false && self.abort == false) {
                    SharingManagerConfiguration.sharedInstance.setCurrentDateonConfiguration(self.index!)
                    SharingManagerSchedule.sharedInstance.addScheduleResultManuel(self.hiddenID!, result: self.output!.statistics(numberOfFiles: self.transferredNumber.stringValue)[0])
                }
                // If showInfoDryrun is on present result of dryrun automatically
                if (self.showInfoDryrun.state == 1) {
                    GlobalMainQueue.async(execute: { () -> Void in
                        self.presentViewControllerAsSheet(self.ViewControllerInformation)
                    })
                }
                // Resetting state values for next run which is a execute run
                self.resetflags()
            } else {
                // Take care of batchRun activities
                if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
                    // Remove the first worker object
                    let work = batchobject.nextBatchRemove()
                    // get numbers from dry-run
                    // Getting max count
                    if (self.output!.getTransferredNumbers(numbers: .totalNumber) > 0) {
                        if (self.output!.getTransferredNumbers(numbers: .transferredNumber) > 0) {
                            self.maxcount = self.output!.getTransferredNumbers(numbers: .transferredNumber)
                        } else {
                            self.maxcount = self.output!.getOutputCount()
                        }
                    }
                    self.setNumbers(setvalues: true)
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
                        self.runBatch()
                    case 1:
                        self.maxcount = self.output!.getOutputCount()
                        // Update files in work
                        batchobject.updateInProcess(numberOfFiles: self.maxcount)
                        batchobject.setCompleted()
                        self.output?.copySummarizedResultBatch(numberOfFiles: self.transferredNumber.stringValue)
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
                        self.runBatch()
                    default :
                        break
                    }
                }
            }
        }
    }
    
    func FileHandler() {
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
                    self.process_update = pvc2[0]
                    self.process_update?.FileHandler()
                }
            }
        }
    }
    
    //  End delegate functions Process object
    
    
    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    private func setNumbers (setvalues : Bool) {
        if (setvalues) {
            self.transferredNumber.stringValue = String(self.output!.getTransferredNumbers(numbers: .transferredNumber))
            self.transferredNumberSizebytes.stringValue = String(self.output!.getTransferredNumbers(numbers: .transferredNumberSizebytes))
            self.totalNumber.stringValue = String(self.output!.getTransferredNumbers(numbers: .totalNumber))
            self.totalNumberSizebytes.stringValue = String(self.output!.getTransferredNumbers(numbers: .totalNumberSizebytes))
            self.totalDirs.stringValue = String(self.output!.getTransferredNumbers(numbers: .totalDirs))
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
        if let profile = SharingManagerConfiguration.sharedInstance.getProfile() {
            self.profilInfo.stringValue = "Profile : " + profile
        } else {
            self.profilInfo.stringValue = "Profile : default"
        }
        
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
        let object : NSMutableDictionary = SharingManagerConfiguration.sharedInstance.getConfigurationsDataSource()![row]
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
                // if (self.remoteserverOff == false) {
                //   return object[tableColumn!.identifier] as? String
                //} else {
                    if (self.testRow(row)) {
                        text = object[tableColumn!.identifier] as? String
                        let attributedString = NSMutableAttributedString(string:(text!))
                        let range = (text! as NSString).range(of: text!)
                        attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.red, range: range)
                        return attributedString
                    } else {
                        return object[tableColumn!.identifier] as? String
                    }
                // }
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


