//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable type_body_length line_length file_length

import Cocoa
import Foundation

class ViewControllerMain: NSViewController, ReloadTable, Deselect, VcMain, Delay, ErrorMessage, Setcolor, Checkforrsync, Help {
    // Main tableview
    @IBOutlet var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var workinglabel: NSTextField!
    // Displays the rsyncCommand
    @IBOutlet var rsyncCommand: NSTextField!
    // If On result of Dryrun is presented before
    // executing the real run
    // number of files to be transferred
    @IBOutlet var transferredNumber: NSTextField!
    // size of files to be transferred
    @IBOutlet var transferredNumberSizebytes: NSTextField!
    // total number of files in remote volume
    @IBOutlet var totalNumber: NSTextField!
    // total size of files in remote volume
    @IBOutlet var totalNumberSizebytes: NSTextField!
    // total number of directories remote volume
    @IBOutlet var totalDirs: NSTextField!
    // Showing info about profile
    @IBOutlet var profilInfo: NSTextField!
    // New files
    @IBOutlet var newfiles: NSTextField!
    // Delete files
    @IBOutlet var deletefiles: NSTextField!
    @IBOutlet var rsyncversionshort: NSTextField!
    @IBOutlet var backupdryrun: NSButton!
    @IBOutlet var restoredryrun: NSButton!
    @IBOutlet var verifydryrun: NSButton!
    @IBOutlet var info: NSTextField!
    @IBOutlet var pathtorsyncosxschedbutton: NSButton!
    @IBOutlet var menuappisrunning: NSButton!
    @IBOutlet var profilepopupbutton: NSPopUpButton!
    @IBOutlet var errorinfo: NSTextField!
    @IBOutlet var jsonbutton: NSButton!

    // Reference to Configurations and Schedules object
    var configurations: Configurations?
    var schedules: Schedules?
    // Reference to the taskobjects
    var singletask: SingleTask?
    var executetasknow: ExecuteTaskNow?
    // Index to selected row, index is set when row is selected
    var index: Int?
    // Indexes, multiple selection
    var indexes: IndexSet?
    var multipeselection: Bool = false
    // Getting output from rsync
    var outputprocess: OutputProcess?
    // Reference to Schedules object
    var schedulesortedandexpanded: ScheduleSortedAndExpand?

    @IBAction func rsyncosxsched(_: NSButton) {
        let running = Running()
        guard running.rsyncOSXschedisrunning == false else {
            self.info.stringValue = Infoexecute().info(num: 5)
            self.info.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            return
        }
        guard running.verifyrsyncosxsched() == true else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: (ViewControllerReference.shared.pathrsyncosxsched ?? "/Applications/") + ViewControllerReference.shared.namersyncosssched))
        NSApp.terminate(self)
    }

    @IBAction func infoonetask(_: NSButton) {
        guard self.index != nil else {
            self.info.stringValue = Infoexecute().info(num: 1)
            return
        }
        guard self.checkforrsync() == false else { return }
        if let index = self.index {
            if let task = self.configurations?.getConfigurations()[index].task {
                guard ViewControllerReference.shared.synctasks.contains(task) else {
                    self.info.stringValue = Infoexecute().info(num: 7)
                    return
                }
                self.presentAsSheet(self.viewControllerInformationLocalRemote!)
            }
        }
    }

    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        if self.configurations?.setestimatedlistnil() == true {
            self.configurations?.remoteinfoestimation = nil
            self.configurations?.estimatedlist = nil
        }
        self.multipeselection = false
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    @IBAction func quickbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.configurations?.remoteinfoestimation = nil
        self.configurations?.estimatedlist = nil
        self.multipeselection = false
        self.openquickbackup()
    }

    @IBAction func delete(_: NSButton) {
        guard self.index != nil else {
            self.info.stringValue = Infoexecute().info(num: 1)
            return
        }
        if let index = self.index {
            if let hiddenID = self.configurations?.gethiddenID(index: index) {
                let question: String = NSLocalizedString("Delete selected task?", comment: "Execute")
                let text: String = NSLocalizedString("Cancel or Delete", comment: "Execute")
                let dialog: String = NSLocalizedString("Delete", comment: "Execute")
                let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
                if answer {
                    // Delete Configurations and Schedules by hiddenID
                    self.configurations?.deleteConfigurationsByhiddenID(hiddenID: hiddenID)
                    self.schedules?.deletescheduleonetask(hiddenID: hiddenID)
                    self.deselect()
                    self.reloadtabledata()
                    // Reset in tabSchedule
                    self.reloadtable(vcontroller: .vctabschedule)
                    self.reloadtable(vcontroller: .vcsnapshot)
                }
            }
            self.reset()
        }
    }

    @IBAction func TCP(_: NSButton) {
        self.configurations?.tcpconnections = TCPconnections()
        self.configurations?.tcpconnections?.testAllremoteserverConnections()
        self.displayProfile()
    }

    // Presenting Information from Rsync
    @IBAction func information(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerInformation!)
        }
    }

    // Abort button
    @IBAction func abort(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.abortOperations()
        }
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        if self.configurations?.tcpconnections?.connectionscheckcompleted ?? true {
            self.presentAsModalWindow(self.viewControllerProfile!)
        } else {
            self.displayProfile()
        }
    }

    // Selecting About
    @IBAction func about(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAbout!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    @IBAction func moveconfig(_: NSButton) {
        guard ViewControllerReference.shared.usenewconfigpath == false else { return }
        self.presentAsModalWindow(self.viewControllerMove!)
    }

    // Selecting automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        if self.configurations?.setestimatedlistnil() == true {
            self.configurations?.remoteinfoestimation = nil
            self.configurations?.estimatedlist = nil
        }
        self.multipeselection = false
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func executetasknow(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard self.index != nil else {
            self.info.stringValue = Infoexecute().info(num: 1)
            return
        }
        if let index = self.index {
            if let task = self.configurations?.getConfigurations()[index].task {
                guard ViewControllerReference.shared.synctasks.contains(task) else { return }
                if let config = self.configurations?.getConfigurations()[index] {
                    if PreandPostTasks(config: config).executepretask || PreandPostTasks(config: config).executeposttask {
                        self.executetasknow = ExecuteTaskNowShellOut(index: index)
                    } else {
                        self.executetasknow = ExecuteTaskNow(index: index)
                    }
                }
            }
        }
    }

    // Function for display rsync command
    @IBAction func showrsynccommand(_: NSButton) {
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
        // JSon test
        self.jsonbutton.isHidden = !ViewControllerReference.shared.json
        // Decide if:
        // 1: First time start, use new profilepath
        // 2: Old profilepath is copied to new, use new profilepath
        // 3: Use old profilepath
        // ViewControllerReference.shared.usenewconfigpath = true or false (default true)
        _ = Neworoldprofilepath()
        // Create base profile catalog
        CatalogProfile().createrootprofilecatalog()
        // Must read userconfig when loading main view, view only load once
        if let userconfiguration = PersistentStorageUserconfiguration().readuserconfiguration() {
            _ = Userconfiguration(userconfigRsyncOSX: userconfiguration)
        } else {
            _ = RsyncVersionString()
        }
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.mainTableView.allowsMultipleSelection = true
        self.working.usesThreadedAnimation = true
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabmain, nsviewcontroller: self)
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllerMain.tableViewDoubleClick(sender:))
        self.backupdryrun.state = .on
        // configurations and schedules
        self.createandreloadconfigurations()
        self.createandreloadschedules()
        self.pathtorsyncosxschedbutton.toolTip = NSLocalizedString("The menu app", comment: "Execute")
        self.initpopupbutton()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if ViewControllerReference.shared.initialstart == 0 {
            self.view.window?.center()
            ViewControllerReference.shared.initialstart = 1
            _ = Checkfornewversion()
        }
        if (self.configurations?.configurationsDataSource?.count ?? 0) > 0 {
            globalMainQueue.async { () -> Void in
                self.mainTableView.reloadData()
            }
        }
        self.rsyncischanged()
        self.displayProfile()
        self.delayWithSeconds(0.5) {
            self.menuappicons()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.multipeselection = false
        self.configurations?.remoteinfoestimation = nil
        self.configurations?.estimatedlist = nil
    }

    func reset() {
        self.singletask = nil
        self.setNumbers(outputprocess: nil)
        self.seterrorinfo(info: "")
        // Close edit and parameters view if open
        if let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcrsyncparameters) as? ViewControllerRsyncParameters {
            weak var closeview: ViewControllerRsyncParameters?
            closeview = view
            closeview?.closeview()
        }
        if let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcedit) as? ViewControllerEdit {
            weak var closeview: ViewControllerEdit?
            closeview = view
            closeview?.closeview()
        }
    }

    func menuappicons() {
        globalMainQueue.async { () -> Void in
            let running = Running()
            if running.rsyncOSXschedisrunning == true {
                self.menuappisrunning.image = #imageLiteral(resourceName: "green")
                self.info.stringValue = Infoexecute().info(num: 5)
                self.info.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            } else {
                self.menuappisrunning.image = #imageLiteral(resourceName: "red")
            }
        }
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        self.executeSingleTask()
    }

    // Single task can be activated by double click from table
    func executeSingleTask() {
        guard self.checkforrsync() == false else { return }
        if let index = self.index {
            if let task = self.configurations?.getConfigurations()[index].task {
                guard ViewControllerReference.shared.synctasks.contains(task) else {
                    self.info.stringValue = Infoexecute().info(num: 6)
                    return
                }
                guard self.singletask != nil else {
                    // Dry run
                    self.singletask = SingleTask(index: index)
                    self.singletask?.executesingletask()
                    return
                }
                // Real run
                self.singletask?.executesingletask()
            }
        }
    }

    // Execute multipleselected tasks, only from main view
    @IBAction func executemultipleselectedindexes(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard self.indexes != nil else {
            self.info.stringValue = Infoexecute().info(num: 6)
            return
        }
        self.multipeselection = true
        self.configurations?.remoteinfoestimation = nil
        self.configurations?.estimatedlist = nil
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Function for setting profile
    func displayProfile() {
        weak var localprofileinfo: SetProfileinfo?
        weak var localprofileinfo2: SetProfileinfo?
        guard self.configurations?.tcpconnections?.connectionscheckcompleted ?? true else {
            self.profilInfo.stringValue = NSLocalizedString("Profile: please wait...", comment: "Execute")
            return
        }
        if let profile = self.configurations?.getProfile() {
            self.profilInfo.stringValue = NSLocalizedString("Profile:", comment: "Execute ") + " " + profile
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .white)
        } else {
            self.profilInfo.stringValue = NSLocalizedString("Profile:", comment: "Execute ") + " default"
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .green)
        }
        localprofileinfo = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
        localprofileinfo2 = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
        localprofileinfo?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        localprofileinfo2?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        self.showrsynccommandmainview()
    }

    func createandreloadschedules() {
        guard self.configurations != nil else {
            self.schedules = Schedules(profile: nil)
            return
        }
        if let profile = self.configurations?.getProfile() {
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
        if let profile = self.configurations?.getProfile() {
            self.configurations = nil
            self.configurations = Configurations(profile: profile)
        } else {
            self.configurations = nil
            self.configurations = Configurations(profile: nil)
        }
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
        if let reloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcallprofiles) as? ViewControllerAllProfiles {
            reloadDelegate.reloadtable()
        }
    }

    func initpopupbutton() {
        var profilestrings: [String]?
        profilestrings = CatalogProfile().getcatalogsasstringnames()
        profilestrings?.insert(NSLocalizedString("Default profile", comment: "default profile"), at: 0)
        self.profilepopupbutton.removeAllItems()
        self.profilepopupbutton.addItems(withTitles: profilestrings ?? [])
        self.profilepopupbutton.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        var profile = self.profilepopupbutton.titleOfSelectedItem
        let selectedindex = self.profilepopupbutton.indexOfSelectedItem
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            profile = nil
        }
        self.profilepopupbutton.selectItem(at: selectedindex)
        _ = Selectprofile(profile: profile, selectedindex: selectedindex)
    }

    @IBAction func Json(_: NSButton) {
        var json: ReadWriteJSON?
        if let profile = self.configurations?.getProfile() {
            json = ReadWriteJSON(configurations: self.configurations?.configurations, profile: profile)

        } else {
            json = ReadWriteJSON(configurations: self.configurations?.configurations, profile: nil)
        }
        json?.writeJSONToPersistentStore()
        json?.readJSONFromPersistentStore()
    }
}
