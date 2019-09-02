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

class ViewControllerMain: NSViewController, ReloadTable, Deselect, VcMain, Delay, FileerrorMessage, Setcolor {

    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var workinglabel: NSTextField!
    // Displays the rsyncCommand
    @IBOutlet weak var rsyncCommand: NSTextField!
    // If On result of Dryrun is presented before
    // executing the real run
    @IBOutlet weak var errorinfo: NSTextField!
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
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var pathtorsyncosxschedbutton: NSButton!
    @IBOutlet weak var menuappisrunning: NSButton!

    // Reference to Configurations and Schedules object
    var configurations: Configurations?
    var schedules: Schedules?
    // Reference to the taskobjects
    var singletask: SingleTask?
    var executebatch: ExecuteBatch?
    var executetasknow: ExecuteTaskNow?
    var tcpconnections: TCPconnections?
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
    // Can load profiles
    // Load profiles only when testing for connections are done.
    // Application crash if not
    var loadProfileMenu: Bool = false
    // Keep track of all errors
    var outputerrors: OutputErrors?
    // Allprofiles view presented
    var allprofilesview: Bool = false
    // Delegate for refresh allprofiles if changes in profiles
    weak var allprofiledetailsDelegate: ReloadTableAllProfiles?

    @IBAction func rsyncosxsched(_ sender: NSButton) {
        let pathtorsyncosxschedapp: String = ViewControllerReference.shared.pathrsyncosxsched! + ViewControllerReference.shared.namersyncosssched
        NSWorkspace.shared.open(URL(fileURLWithPath: pathtorsyncosxschedapp))
        self.pathtorsyncosxschedbutton.isEnabled = false
        NSApp.terminate(self)
    }

    @IBAction func restore(_ sender: NSButton) {
        guard self.index != nil else {
            self.info.stringValue = Infoexecute().info(num: 1)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.snapshot else {
                self.info.stringValue = Infoexecute().info(num: 7)
                return
        }
        self.presentAsSheet(self.restoreViewController!)
    }

    @IBAction func infoonetask(_ sender: NSButton) {
        guard self.index != nil else {
            self.info.stringValue = Infoexecute().info(num: 1)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.snapshot else {
                self.info.stringValue = Infoexecute().info(num: 7)
                return
        }
        self.presentAsSheet(self.viewControllerInformationLocalRemote!)
    }

    @IBAction func totinfo(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
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
            self.info.stringValue = Infoexecute().info(num: 1)
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.editViewController!)
        })
    }

    @IBAction func rsyncparams(_ sender: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info.stringValue = Infoexecute().info(num: 1)
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRsyncParams!)
        })
    }

    @IBAction func delete(_ sender: NSButton) {
        self.reset()
        guard self.hiddenID != nil else {
            self.info.stringValue = Infoexecute().info(num: 1)
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
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func executetasknow(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.hiddenID != nil else {
            self.info.stringValue = Infoexecute().info(num: 1)
            return
        }
        guard self.index != nil else {
            self.info.stringValue = Infoexecute().info(num: 1)
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.snapshot else {
                return
        }
        self.executetasknow = ExecuteTaskNow(index: self.index!)
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
        self.mainTableView.doubleAction = #selector(ViewControllerMain.tableViewDoubleClick(sender:))
        self.backupdryrun.state = .on
        self.loadProfileMenu = true
        // configurations and schedules
        self.createandreloadconfigurations()
        self.createandreloadschedules()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if ViewControllerReference.shared.initialstart == 0 {
            self.view.window?.center()
            ViewControllerReference.shared.initialstart = 1
        }
        if self.configurations!.configurationsDataSourcecount() > 0 {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        self.rsyncischanged()
        self.displayProfile()
        self.info.stringValue = Infoexecute().info(num: 0)
        self.delayWithSeconds(0.5) {
            self.enablemenuappbutton()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.dynamicappend = false
    }

    func reset() {
        self.outputprocess = nil
        self.process = nil
        self.singletask = nil
        self.executebatch = nil
        self.setNumbers(outputprocess: nil)
    }

    func enablemenuappbutton() {
        globalMainQueue.async(execute: { () -> Void in
            let running = Running()
            guard running.enablemenuappbutton == true else {
                self.pathtorsyncosxschedbutton.isEnabled = false
                if running.menuappnoconfig == false {
                    self.menuappisrunning.image = #imageLiteral(resourceName: "green")
                    self.info.stringValue = Infoexecute().info(num: 5)
                }
                return
            }
            self.pathtorsyncosxschedbutton.isEnabled = true
            self.menuappisrunning.image = #imageLiteral(resourceName: "red")
        })
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
         self.executeSingleTask()
    }

    // Single task can be activated by double click from table
    func executeSingleTask() {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.index != nil else { return }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.snapshot
            else {
                self.info.stringValue = Infoexecute().info(num: 6)
                return
        }
        guard self.singletask != nil else {
            // Dry run
            self.singletask = SingleTask(index: self.index!)
            self.singletask?.executeSingleTask()
            return
        }
        // Real run
        self.singletask?.executeSingleTask()
    }

    // Execute batche tasks, only from main view
    @IBAction func executeBatch(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
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
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.profilInfo.stringValue = NSLocalizedString("Profile:", comment: "Execute ") + " " + profile
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .white)
        } else {
            self.profilInfo.stringValue = NSLocalizedString("Profile:", comment: "Execute ") + " default"
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .green)
        }
        localprofileinfo = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
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
        self.backupdryrun.state = .on
        self.info.stringValue = Infoexecute().info(num: 0)
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
    }

    func createandreloadconfigurations() {
        guard self.configurations != nil else {
            self.configurations = Configurations(profile: nil)
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.configurations = nil
            self.configurations = Configurations(profile: profile)
        } else {
            self.configurations = nil
            self.configurations = Configurations(profile: nil)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        if self.allprofilesview {
             self.allprofiledetailsDelegate?.reloadtable()
        }
    }
}
