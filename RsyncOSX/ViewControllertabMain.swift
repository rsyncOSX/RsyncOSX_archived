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
    func dismiss_view(viewcontroller:NSViewController)
}

// Protocol for either completion of work or update progress when Process discovers a
// process termination and when filehandler discover data
protocol UpdateProgress: class {
    func ProcessTermination()
    func FileHandler()
}

// Protocol for deselecting rowtable
protocol deselectRowTable: class {
    func deselectRow()
}

// Protocol for reporting file errors
protocol ReportErrorInMain: class {
    func fileerror(errorstr:String)
}

class ViewControllertabMain: NSViewController {
    
    // Reference to the single taskobject
    var singletask:newSingleTask?
    // Reference to batch taskobject
    var batchtask:newBatchTask?

    // Protocol function used in Process().
    weak var processupdate_delegate:UpdateProgress?
    // Delegate function for doing a refresh of NSTableView in ViewControllerBatch
    weak var refresh_delegate:RefreshtableView?
    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicator_delegate:StartStopProgressIndicator?
    // Delegate function getting batchTaskObject
    weak var batchObject_delegate:getNewBatchTask?
    
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
    // New files
    @IBOutlet weak var newfiles: NSTextField!
    // Delete files
    @IBOutlet weak var deletefiles: NSTextField!
    
    
    // REFERENCE VARIABLES
    
    // Reference to Process task
    fileprivate var process:Process?
    // Index to selected row, index is set when row is selected
    fileprivate var index:Int?
    // Getting output from rsync 
    fileprivate var output:outputProcess?
    // Getting output from batchrun
    fileprivate var outputbatch:outputBatch?
    // Holding max count 
    fileprivate var maxcount:Int = 0
    // HiddenID task, set when row is selected
    fileprivate var hiddenID:Int?
    // Reference to Schedules object
    fileprivate var schedules : ScheduleSortedAndExpand?
    // Bool if one or more remote server is offline
    // Used in testing if remote server is on/off-line
    fileprivate var serverOff:Array<Bool>?
    // Single task work queu
    fileprivate var workload:singleTaskWorkQueu?
    
    // Schedules in progress
    fileprivate var scheduledJobInProgress:Bool = false
    // Ready for execute again
    fileprivate var ready:Bool = true
    // Can load profiles
    // Load profiles only when testing for connections are done.
    // Application crash if not
    fileprivate var loadProfileMenu:Bool = false
    
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
    
    
    // BUTTONS AND ACTIONS
    
    @IBOutlet weak var edit: NSButton!
    @IBOutlet weak var rsyncparams: NSButton!
    @IBOutlet weak var delete: NSButton!
    
    // Menus as Radiobuttons for Edit functions in tabMainView
    @IBAction func Radiobuttons(_ sender: NSButton) {
        
        // Reset output
        self.output = nil
        // Clear numbers from dryrun
        self.setNumbers(output: nil)
        self.workload = nil
        self.setInfo(info: "Estimate", color: .blue)
        self.process = nil
        
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
                        self.deselectRow()
                        self.hiddenID = nil
                        self.index = nil
                        self.refresh()
                    }
                }
                self.delete.state = NSOffState
            }
        } else {
            self.rsyncCommand.stringValue = " ... Please select a task first ..."
            self.delete.state = NSOffState
            self.rsyncparams.state = NSOffState
            self.edit.state = NSOffState
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
        GlobalMainQueue.async(execute: { () -> Void in
            self.abortOperations()
            self.process = nil
        })
    }

    // Userconfiguration button
    @IBAction func Userconfiguration(_ sender: NSButton) {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
        })
    }
    
    // Selecting profiles
    @IBAction func profiles(_ sender: NSButton) {
        if (self.loadProfileMenu == true) {
            self.showProcessInfo(info:.Change_profile)
            GlobalMainQueue.async(execute: { () -> Void in
                self.presentViewControllerAsSheet(self.ViewControllerProfile)
            })
        } else {
            self.displayProfile()
        }
        
    }
    
    // Selecting About
    @IBAction func About (_ sender: NSButton) {
        self.presentViewControllerAsModalWindow(self.ViewControllerAbout)
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
        if (self.displayDryRun.state == NSOnState) {
            if let index = self.index {
                self.rsyncCommand.stringValue = Utils.sharedInstance.setRsyncCommandDisplay(index: index, dryRun: true)
            } else {
                self.rsyncCommand.stringValue = ""
            }
        } else {
            if let index = self.index {
                self.rsyncCommand.stringValue = Utils.sharedInstance.setRsyncCommandDisplay(index: index, dryRun: false)
            } else {
                self.rsyncCommand.stringValue = ""
            }
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
        self.ReReadConfigurationsAndSchedules()
        // Setting reference to self, used when calling delegate functions
        SharingManagerConfiguration.sharedInstance.ViewControllertabMain = self
        // Create a Schedules object
        // Start waiting for next Scheduled job (if any)
        self.schedules = ScheduleSortedAndExpand()
        self.startProcess()
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllertabMain.tableViewDoubleClick(sender:))
        // Defaults to display dryrun command
        self.displayDryRun.state = NSOnState
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.loadProfileMenu = false
        self.showProcessInfo(info: .Blank)
        // Allow notify about Scheduled jobs
        SharingManagerConfiguration.sharedInstance.allowNotifyinMain = true
        self.setInfo(info: "", color: .black)
        // Setting reference to ViewController
        // Used to call delegate function from other class
        SharingManagerConfiguration.sharedInstance.ViewControllertabMain = self
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
        self.displayAllowDoubleclick()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        // Do not allow notify in Main
        SharingManagerConfiguration.sharedInstance.allowNotifyinMain = false
        if (self.workload == nil) {
            self.workload = singleTaskWorkQueu()
        }
        // If a process is running keep it running
        guard self.process == nil else {
            return
        }
        self.reset()
    }
    
    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender:AnyObject) {
        if (SharingManagerConfiguration.sharedInstance.allowDoubleclick == true) {
            if (self.ready) {
                self.executeSingleTask()
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
            self.executeSingleTask()
        }
        self.ready = false
    }
    
    // Single task can be activated by double click from table
    private func executeSingleTask() {
        
        guard self.index != nil else {
            return
        }
        
        self.batchtask = nil
        
        guard self.singletask != nil else {
            // Dry run
            self.singletask = newSingleTask(index: self.index!)
            self.singletask?.executeSingleTask()
            return
        }
        // Real run
        self.singletask?.executeSingleTask()
    }
    
    
    // Execute BATCH TASKS only
    @IBAction func executeBatch(_ sender: NSButton) {
        self.singletask = nil
        self.batchtask = newBatchTask()
        self.batchtask?.executeBatch()
    }
    
    // Reread bot Configurations and Schedules from persistent store to memory
    fileprivate func ReReadConfigurationsAndSchedules() {
        // Reading main Configurations to memory
        SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        SharingManagerConfiguration.sharedInstance.readAllConfigurationsAndArguments()
        // Read all Scheduled data again
        SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        SharingManagerSchedule.sharedInstance.readAllSchedules()
    }
    
    //  End delegate functions Process object
    
    // Function for setting max files to be transferred
    // Function is called in self.ProcessTermination()
    fileprivate func setmaxNumbersOfFilesToTransfer() {
        
        let number = Numbers(output: self.output!.getOutput())
        number.setNumbers()
        
        // Getting max count
        self.showProcessInfo(info: .Set_max_Number)
        if (number.getTransferredNumbers(numbers: .totalNumber) > 0) {
            self.setNumbers(output: self.output)
            if (number.getTransferredNumbers(numbers: .transferredNumber) > 0) {
                self.maxcount = number.getTransferredNumbers(numbers: .transferredNumber)
            } else {
                self.maxcount = self.output!.getMaxcount()
            }
        } else {
            self.maxcount = self.output!.getMaxcount()
        }
    }
    
    // Function for setting profile
    fileprivate func displayProfile() {
        
        guard (self.loadProfileMenu == true) else {
            self.profilInfo.stringValue = "Profile: please wait..."
            self.profilInfo.textColor = .blue
            return
        }
        
        if let profile = SharingManagerConfiguration.sharedInstance.getProfile() {
            self.profilInfo.stringValue = "Profile: " + profile
            self.profilInfo.textColor = .blue
        } else {
            self.profilInfo.stringValue = "Profile: default"
            self.profilInfo.textColor = .black
        }
        
    }
    
    // Function for setting allowDouble click
    internal func displayAllowDoubleclick() {
        if (SharingManagerConfiguration.sharedInstance.allowDoubleclick == true) {
            self.allowDoubleclick.stringValue = "Double click: YES"
            self.allowDoubleclick.textColor = .blue
        } else {
            self.allowDoubleclick.stringValue = "Double click: NO"
            self.allowDoubleclick.textColor = .black
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
            self.index = index
            self.hiddenID = SharingManagerConfiguration.sharedInstance.gethiddenID(index: index)
            // Reset output
            self.output = nil
            self.outputbatch = nil
            // Clear numbers from dryrun
            self.setNumbers(output: nil)
            self.workload = nil
        } else {
            self.index = nil
        }
        self.process = nil
        
        self.singletask = nil
        
        self.setInfo(info: "Estimate", color: .blue)
        self.setRsyncCommandDisplay()
    }
    
    // Reset workqueue
    fileprivate func reset() {
        self.workload = nil
        self.process = nil
        self.output = nil
        self.setRsyncCommandDisplay()
    }
    
    // Abort any task, either single- or batch task
    func abortOperations() {
        // Terminates the running process
        self.showProcessInfo(info:.Abort)
        if let process = self.process {
            process.terminate()
            self.index = nil
            self.working.stopAnimation(nil)
            self.schedules = nil
            self.process = nil
            self.workload = nil
            // Create workqueu and add abort
            self.workload = singleTaskWorkQueu(task: .abort)
            self.setInfo(info: "Abort", color: .red)
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
            self.workload = singleTaskWorkQueu(task: .abort)
            self.setInfo(info: "Abort", color: .red)
        }
    }

}


// Extensions

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

// Get output from rsync command
extension ViewControllertabMain: Information {
    
    // Get information from rsync output.
    func getInformation() -> Array<String> {
        
        if (self.outputbatch != nil) {
            return self.outputbatch!.getOutput()
        } else if (self.output != nil) {
            return self.output!.getOutput()
        } else {
            return [""]
        }
    }
    
}

// Counting
extension ViewControllertabMain: Count {
    
    // Maxnumber of files counted
    func maxCount() -> Int {
        return self.maxcount
    }
    
    // Counting number of files
    // Function is called when Process discover FileHandler notification
    func inprogressCount() -> Int {
        return self.output!.getOutputCount()
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
        GlobalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}


// Configuration to task is changed, reread configurations again
extension ViewControllertabMain: ReadConfigurationsAgain {
    
    func readConfigurations() {
        SharingManagerConfiguration.sharedInstance.readAllConfigurationsAndArguments()
        if (SharingManagerConfiguration.sharedInstance.ConfigurationsDataSourcecount() > 0 ) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        // Read schedule objects again
        self.schedules = nil
        self.schedules = ScheduleSortedAndExpand()
        self.setRsyncCommandDisplay()
    }
    
}


// Parameters to rsync is changed
extension ViewControllertabMain: RsyncUserParams {
    
    // Do a reread of all Configurations
    func rsyncuserparamsupdated() {
        self.readConfigurations()
        self.setRsyncCommandDisplay()
        self.rsyncparams.state = 0
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
    
    // Function is called from profiles when new or
    // default profiles is seleceted
    func newProfile(new : Bool) {
        weak var newProfile_delegate: AddProfiles?
        // By setting self.schedules = nil start jobs are restaret in ViewDidAppear
        self.schedules = nil
        self.loadProfileMenu = false
        
        // Reset any queue of work
        // Reset numbers
        self.workload = nil
        self.process = nil
        self.output = nil
        self.outputbatch = nil
        self.setRsyncCommandDisplay()
        self.setInfo(info: "Estimate", color: .blue)
        self.setNumbers(output: nil)
        
        guard (new == false) else {
            // A new and empty profile is created
            SharingManagerSchedule.sharedInstance.destroySchedule()
            SharingManagerConfiguration.sharedInstance.destroyConfigurations()
            // Reset in tabSchedule
            if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabSchedule as? ViewControllertabSchedule {
                newProfile_delegate = pvc
                newProfile_delegate?.newProfile(new: true)
            }
            self.refresh()
            return
        }
        
        // Reset in tabSchedule
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabSchedule as? ViewControllertabSchedule {
            newProfile_delegate = pvc
            newProfile_delegate?.newProfile(new: false)
        }
        // Must unload Schedule data before new Profile is loaded.
        // This is due to a glitch in design in 
        // SharingManagerSchedule.sharedInstance.getAllSchedules()
        // If no new Schedules in profile exists old Schedules are 
        // kept in memory. Force a clean of old Schedules before read 
        // Schedules for new profile.
        SharingManagerSchedule.sharedInstance.destroySchedule()
        // Read configurations and Scheduledata
        self.ReReadConfigurationsAndSchedules()
        self.displayProfile()
        // Do a refresh of tableView
        self.refresh()
        // We have to start any Scheduled process again - if any
        self.startProcess()
        // Check all remote servers for connection
        Utils.sharedInstance.testAllremoteserverConnections()
    }
    
    func enableProfileMenu() {
        self.loadProfileMenu = true
        self.showProcessInfo(info: .Profiles_enabled)
        GlobalMainQueue.async(execute: { () -> Void in
            self.displayProfile()
        })
    }

}


// A scheduled task is executed
extension ViewControllertabMain: ScheduledJobInProgress {
    
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
}

// New scheduled task entered. Delete old one and
// calculated new object (queue)
extension ViewControllertabMain: NewSchedules {
    // Create new schedule object. Old object is
    // released (deleted).
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
        self.serverOff = Utils.sharedInstance.gettestAllremoteserverConnections()
        GlobalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

// Uuups, new version is discovered
extension ViewControllertabMain: newVersionDiscovered {
    // Notifies if new version is discovered
    func notifyNewVersion() {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.newVersionViewController)
        })
    }
}


// Dismisser for sheets
extension ViewControllertabMain: DismissViewController {
    // Function for dismissing a presented view
    // - parameter viewcontroller: the viewcontroller to be dismissed
    func dismiss_view(viewcontroller:NSViewController) {
        self.dismissViewController(viewcontroller)
        // Reset radiobuttons
        self.edit.state = NSOffState
        self.rsyncparams.state = NSOffState
        GlobalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

// Called when either a terminatopn of Process is
// discovered or data is availiable in the filehandler
// See file rsyncProcess.swift.
extension ViewControllertabMain: UpdateProgress {
    
    // Delegate functions called from the Process object
    // Protocol UpdateProgress two functions, ProcessTermination() and FileHandler()
    
    func ProcessTermination() {
        self.ready = true
        // NB: must check if single run or batch run
        if let singletask = self.singletask {
            self.output = singletask.output
            singletask.ProcessTermination()
            
        } else  {
            // Batch run
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                self.batchObject_delegate = pvc[0]
                self.batchtask = self.batchObject_delegate?.getTaskObject()
            }
            self.output = self.batchtask!.output
            self.batchtask!.inBatchwork()
        }
        
    }
    
    // Function is triggered when Process outputs data in filehandler
    // Process is either in singleRun or batchRun
    func FileHandler() {
        self.showProcessInfo(info: .Count_files)
        if self.batchtask != nil {
            if let batchobject = SharingManagerConfiguration.sharedInstance.getBatchdataObject() {
                let work = batchobject.nextBatchCopy()
                if work.1 == 1 {
                    // Real work is done
                    batchobject.updateInProcess(numberOfFiles: self.batchtask!.output!.getMaxcount())
                    // Refresh view in Batchwindow
                    if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                        self.refresh_delegate = pvc[0]
                        self.refresh_delegate?.refresh()
                    }
                }
        } else if self.singletask != nil {
                // Refresh ProgressView single run
                if let pvc2 = self.presentedViewControllers as? [ViewControllerProgressProcess] {
                    if (pvc2.count > 0) {
                        self.processupdate_delegate = pvc2[0]
                        self.processupdate_delegate?.FileHandler()
                    }
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
        if (SharingManagerConfiguration.sharedInstance.rsyncerror) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.setInfo(info: "Error", color: .red)
                self.showProcessInfo(info: .Error)
                self.setRsyncCommandDisplay()
                // Abort any operations
                if let process = self.process {
                    process.terminate()
                    self.process = nil
                }
                guard (self.workload != nil) else {
                    return
                }
                self.workload!.error()
            })
        }
    }
}

// If, for any reason, handling files or directory throws an error
extension ViewControllertabMain: ReportErrorInMain {
    func fileerror(errorstr:String) {
        GlobalMainQueue.async(execute: { () -> Void in
            self.setInfo(info: "Error", color: .red)
            self.showProcessInfo(info: .Error)
            // Dump the errormessage in rsynccommand field
            self.rsyncCommand.stringValue = errorstr
        })
    }
}

// Abort task from progressview
extension ViewControllertabMain: AbortOperations {
    
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
    func showProcessInfo(info:displayProcessInfo) {
        GlobalMainQueue.async(execute: { () -> Void in
            switch info {
            case .Estimating:
                self.processInfo.stringValue = "Estimating"
            case .Executing:
                self.processInfo.stringValue = "Executing"
            case .Set_max_Number:
                self.processInfo.stringValue = "Set max number"
            case .Logging_run:
                self.processInfo.stringValue = "Logging run"
            case .Count_files:
                self.processInfo.stringValue = "Count files"
            case .Change_profile:
                self.processInfo.stringValue = "Change profile"
            case .Profiles_enabled:
                self.processInfo.stringValue = "Profiles enabled"
            case .Abort:
                self.processInfo.stringValue = "Abort"
            case .Error:
                self.processInfo.stringValue = "Rsync error"
            case .Blank:
                self.processInfo.stringValue = ""
            }
        })
    }
    
    func presentViewProgress() {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerProgress)
        })
    }
    
    func presentViewInformation(output: outputProcess) {
        self.output = output
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerInformation)
        })
        
    }
    
    func terminateProgressProcess() {
        if let pvc2 = self.presentedViewControllers as? [ViewControllerProgressProcess] {
            if (pvc2.count > 0) {
                self.processupdate_delegate = pvc2[0]
                self.processupdate_delegate?.ProcessTermination()
            }
        }
    }
    
    func setInfo(info:String, color:colorInfo) {
        
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
    
    func singleTaskAbort(process:Process?) {
        self.process = process
        self.abortOperations()
    }
    
    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    func setNumbers(output:outputProcess?) {
        
        GlobalMainQueue.async(execute: { () -> Void in
            
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
            
            self.transferredNumber.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumber)), number: NumberFormatter.Style.decimal)
            self.transferredNumberSizebytes.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumberSizebytes)), number: NumberFormatter.Style.decimal)
            self.totalNumber.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumber)), number: NumberFormatter.Style.decimal)
            self.totalNumberSizebytes.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumberSizebytes)), number: NumberFormatter.Style.decimal)
            self.totalDirs.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalDirs)), number: NumberFormatter.Style.decimal)
            self.newfiles.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .new)), number: NumberFormatter.Style.decimal)
            self.deletefiles.stringValue = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .delete)), number: NumberFormatter.Style.decimal)
        })
        
    }
    
    // Function for setting max files to be transferred
    // Function is called in self.ProcessTermination()
    func setmaxNumbersOfFilesToTransfer(output : outputProcess?) {
        
        guard output != nil else {
            return
        }
        
        let number = Numbers(output: output!.getOutput())
        number.setNumbers()
        
        // Getting max count
        self.showProcessInfo(info: .Set_max_Number)
        if (number.getTransferredNumbers(numbers: .totalNumber) > 0) {
            self.setNumbers(output: output)
            if (number.getTransferredNumbers(numbers: .transferredNumber) > 0) {
                self.maxcount = number.getTransferredNumbers(numbers: .transferredNumber)
            } else {
                self.maxcount = output!.getMaxcount()
            }
        } else {
            self.maxcount = output!.getMaxcount()
        }
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
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerBatch)
        })
    }
    
    func progressIndicatorViewBatch(operation: batchViewProgressIndicator) {
        switch operation {
        case .stop:
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                self.indicator_delegate = pvc[0]
                self.refresh_delegate = pvc[0]
                self.indicator_delegate?.stop()
                self.refresh_delegate?.refresh()
                
            }
        case .start:
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                self.indicator_delegate = pvc[0]
                self.indicator_delegate?.start()
            }
        case .complete:
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                self.indicator_delegate = pvc[0]
                self.indicator_delegate?.complete()
            }
            
        case .refresh:
            if let pvc = self.presentedViewControllers as? [ViewControllerBatch] {
                self.refresh_delegate = pvc[0]
                self.refresh_delegate?.refresh()
            }
            
        }
    }
}


