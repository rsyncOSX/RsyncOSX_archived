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
    func enableappend()
    func disableappend()
}

protocol AllProfileDetails: class {
    func enablereloadallprofiles()
    func disablereloadallprofiles()
}

class ViewControllertabMain: NSViewController, ReloadTable, Deselect, VcMain, Delay, FileerrorMessage {

    // Configurations object
    var configurations: Configurations?
    var schedules: Schedules?
    // Reference to the single taskobject
    var singletask: SingleTask?
    // Reference to batch taskobject
    var batchtasks: BatchTask?
    var tcpconnections: TCPconnections?
    // Delegate function getting batchTaskObject
    weak var batchtasksDelegate: GetNewBatchTask?
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
    // Dynamic view of output
    var dynamicappend: Bool = false
    // HiddenID task, set when row is selected
    var hiddenID: Int?
    // Reference to Schedules object
    var schedulesortedandexpanded: ScheduleSortedAndExpand?
    // Bool if one or more remote server is offline
    // Used in testing if remote server is on/off-line
    var serverOff: [Bool]?
    // Ready for execute again
    var readyforexecution: Bool = true
    // Can load profiles
    // Load profiles only when testing for connections are done.
    // Application crash if not
    var loadProfileMenu: Bool = false
    // Keep track of all errors
    var outputerrors: OutputErrors?
    // used in updating tableview
    var setbatchyesno: Bool = false
    // Allprofiles view presented
    var allprofilesview: Bool = false
    // Delegate for refresh allprofiles if changes in profiles
    weak var allprofiledetailsDelegate: ReloadTableAllProfiles?
    // Infoobject
    var information: Info?

    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var pathtorsyncosxschedbutton: NSButton!
    @IBOutlet weak var menuappisrunning: NSButton!

    @IBAction func rsyncosxsched(_ sender: NSButton) {
        let pathtorsyncosxschedapp: String = ViewControllerReference.shared.pathrsyncosxsched! + ViewControllerReference.shared.namersyncosssched
        NSWorkspace.shared.open(URL(fileURLWithPath: pathtorsyncosxschedapp))
        self.pathtorsyncosxschedbutton.isEnabled = false
        NSApp.terminate(self)
    }

    @IBAction func restore(_ sender: NSButton) {
        guard self.index != nil else {
            self.info.stringValue = self.information!.info(num: 1)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.snapshot else {
                self.info.stringValue = self.information!.info(num: 7)
                return
        }
        self.configurations!.processtermination = .restore
        self.presentAsSheet(self.restoreViewController!)
    }

    @IBAction func infoonetask(_ sender: NSButton) {
        guard self.index != nil else {
            self.info.stringValue = self.information!.info(num: 1)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.snapshot else {
                self.info.stringValue = self.information!.info(num: 7)
                return
        }
        self.configurations!.processtermination = .infosingletask
        self.presentAsSheet(self.viewControllerInformationLocalRemote!)
    }

    @IBAction func totinfo(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        self.configurations!.processtermination = .remoteinfotask
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        })
    }

    @IBAction func quickbackup(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        self.openquickbackup()
    }

    @IBAction func edit(_ sender: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info.stringValue = self.information!.info(num: 1)
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.editViewController!)
        })
    }

    @IBAction func rsyncparams(_ sender: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info.stringValue = self.information!.info(num: 1)
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRsyncParams!)
        })
    }

    @IBAction func delete(_ sender: NSButton) {
        self.reset()
        guard self.hiddenID != nil else {
            self.info.stringValue = self.information!.info(num: 1)
            return
        }
        let question: String = NSLocalizedString("Delete selected task?", comment: "Execute")
        let text: String = NSLocalizedString("Cancel or Delete", comment: "Execute")
        let dialog: String = NSLocalizedString("Delete", comment: "Execute")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
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
        self.process = nil
        self.singletask = nil
    }

    @IBOutlet weak var TCPButton: NSButton!
    @IBAction func TCP(_ sender: NSButton) {
        self.TCPButton.isEnabled = false
        self.loadProfileMenu = false
        self.displayProfile()
        self.tcpconnections = TCPconnections()
        self.tcpconnections?.testAllremoteserverConnections()
    }

    // Presenting Information from Rsync
    @IBAction func information(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerInformation!)
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
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    // Selecting profiles
    @IBAction func profiles(_ sender: NSButton) {
        if self.loadProfileMenu == true {
            globalMainQueue.async(execute: { () -> Void in
                self.presentAsSheet(self.viewControllerProfile!)
            })
        } else {
            self.displayProfile()
        }
    }

    // Logg records
    @IBAction func loggrecords(_ sender: NSButton) {
        self.configurations!.allowNotifyinMain = true
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerScheduleDetails!)
        })
    }

    // Selecting About
    @IBAction func about (_ sender: NSButton) {
        self.presentAsModalWindow(self.viewControllerAbout!)
    }

    // Selecting automatic backup
    @IBAction func automaticbackup (_ sender: NSButton) {
        self.configurations!.processtermination = .automaticbackup
        self.configurations?.remoteinfotaskworkqueue = RemoteInfoTaskWorkQueue(inbatch: false)
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func executetasknow(_ sender: NSButton) {
        self.configurations!.processtermination = .singlequicktask
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.hiddenID != nil else {
            self.info.stringValue = self.information!.info(num: 1)
            return
        }
        guard self.index != nil else {
            self.info.stringValue = self.information!.info(num: 1)
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.snapshot else {
                return
        }
        self.executetasknow()
    }

    func executetasknow() {
        guard self.index != nil  else { return }
        self.configurations!.processtermination = .singlequicktask
        self.working.startAnimation(nil)
        let arguments = self.configurations!.arguments4rsync(index: self.index!, argtype: .arg)
        self.outputprocess = OutputProcess()
        let process = Rsync(arguments: arguments)
        process.executeProcess(outputprocess: self.outputprocess)
        self.process = process.getProcess()
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
                self.rsyncCommand.stringValue = Displayrsyncpath(index: index, display: .synchronize).displayrsyncpath ?? ""
            } else if self.restoredryrun.state == .on {
                self.rsyncCommand.stringValue = Displayrsyncpath(index: index, display: .restore).displayrsyncpath ?? ""
            } else {
                self.rsyncCommand.stringValue = Displayrsyncpath(index: index, display: .verify).displayrsyncpath ?? ""
            }
        } else {
            self.rsyncCommand.stringValue = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.working.usesThreadedAnimation = true
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabmain, nsviewcontroller: self)
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllertabMain.tableViewDoubleClick(sender:))
        self.backupdryrun.state = .on
        self.loadProfileMenu = true
        // configurations and schedules
        self.createandreloadconfigurations()
        self.createandreloadschedules()
        self.information = Info()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if ViewControllerReference.shared.initialstart == 0 {
            self.view.window?.center()
            ViewControllerReference.shared.initialstart = 1
        }
        ViewControllerReference.shared.activetab = .vctabmain
        self.configurations!.allowNotifyinMain = true
        if self.configurations!.configurationsDataSourcecount() > 0 {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        self.rsyncischanged()
        self.displayProfile()
        self.readyforexecution = true
        if self.tcpconnections == nil { self.tcpconnections = TCPconnections()}
        self.info.stringValue = self.information!.info(num: 0)
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
            guard ViewControllerReference.shared.executescheduledtasksmenuapp == true else {
                self.pathtorsyncosxschedbutton.isEnabled = false
                return
            }
            let running = Running()
            guard running.enablemenuappbutton == true else {
                self.pathtorsyncosxschedbutton.isEnabled = false
                if running.menuappnoconfig == false {
                    self.menuappisrunning.image = #imageLiteral(resourceName: "green")
                    self.info.stringValue = self.information!.info(num: 5)
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
        self.configurations!.processtermination = .singletask
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.index != nil else { return }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.snapshot
            else {
                self.info.stringValue = self.information!.info(num: 6)
                return
        }
        self.batchtasks = nil
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
        self.configurations!.processtermination = .estimatebatchtask
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        self.singletask = nil
        self.setNumbers(outputprocess: nil)
        self.deselect()
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerBatch!)
        })
    }

    // Function for setting profile
    func displayProfile() {
        weak var localprofileinfo: SetProfileinfo?
        weak var localprofileinfo2: SetProfileinfo?
        guard self.loadProfileMenu == true else {
            self.profilInfo.stringValue = NSLocalizedString("Profile: please wait...", comment: "Execute")
            self.profilInfo.textColor = .white
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.profilInfo.stringValue = NSLocalizedString("Profile:", comment: "Execute ") + " " + profile
            self.profilInfo.textColor = .white
        } else {
            self.profilInfo.stringValue = NSLocalizedString("Profile:", comment: "Execute ") + " default"
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
        self.seterrorinfo(info: "")
        // If change row during estimation
        if self.process != nil { self.abortOperations() }
        // If change row after estimation, force new estimation
        if self.readyforexecution == false { self.abortOperations() }
        self.readyforexecution = true
        self.backupdryrun.state = .on
        self.info.stringValue = self.information!.info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.hiddenID = self.configurations!.gethiddenID(index: index)
            self.outputprocess = nil
            self.setNumbers(outputprocess: nil)
        } else {
            self.index = nil
        }
        self.process = nil
        self.singletask = nil
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
        ViewControllerReference.shared.quickbackuptask = self.schedulesortedandexpanded?.firstscheduledtask()
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
        if self.allprofilesview {
             self.allprofiledetailsDelegate?.reloadtable()
        }
    }
}
