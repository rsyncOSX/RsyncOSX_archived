//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable type_body_length line_length

import Cocoa
import Foundation

protocol SetProfileinfo: AnyObject {
    func setprofile(profile: String?)
}

class ViewControllerMain: NSViewController, ReloadTable, Deselect, VcMain, Delay, Setcolor, Checkforrsync, Help, Connected {
    // Main tableview
    @IBOutlet var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var info: NSTextField!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

    // Reference to Configurations
    var configurations: Configurations?
    // Reference to the taskobjects
    var singletask: SingleTask?
    var executetasknow: ExecuteTaskNow?
    // Index to selected row, index is set when row is selected
    var localindex: Int?
    var lastindex: Int?
    // Indexes, multiple selection
    var indexset: IndexSet?
    var multipeselection: Bool = false
    // Getting output from rsync
    var outputprocess: OutputfromProcess?
    // Send messages to the sidebar
    weak var sidebaractionsDelegate: Sidebaractions?

    // Toolbar -  Find tasks and Execute backup
    @IBAction func automaticbackup(_: NSButton) {
        guard checkforrsync() == false else { return }
        guard SharedReference.shared.process == nil else { return }
        presentAsSheet(viewControllerEstimating!)
    }

    // Toolbar - Abort button
    @IBAction func abort(_: NSButton) {
        globalMainQueue.async { () in
            self.abortOperations()
        }
    }

    // Toolbar - Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        guard SharedReference.shared.process == nil else { return }
        presentAsModalWindow(viewControllerUserconfiguration!)
    }

    // Toolbar - Estimate and Quickbackup
    @IBAction func totinfo(_: NSButton) {
        guard checkforrsync() == false else { return }
        multipeselection = false
        globalMainQueue.async { () in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Toolbar - Multiple select and execute
    // Execute multipleselected tasks, only from main view
    @IBAction func executemultipleselectedindexes(_: NSButton) {
        guard checkforrsync() == false else { return }
        guard SharedReference.shared.process == nil else { return }
        guard indexset != nil else {
            info.stringValue = Infoexecute().info(num: 6)
            return
        }
        multipeselection = true
        globalMainQueue.async { () in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    @IBAction func executetasknow(_: NSButton) {
        guard SharedReference.shared.process == nil else { return }
        guard checkforrsync() == false else { return }
        guard localindex != nil else {
            info.stringValue = Infoexecute().info(num: 1)
            return
        }
        if let index = localindex {
            executetask(index: index)
        }
    }

    @IBAction func infoonetask(_: NSButton) {
        guard SharedReference.shared.process == nil else { return }
        guard localindex != nil else {
            info.stringValue = Infoexecute().info(num: 1)
            return
        }
        guard checkforrsync() == false else { return }
        if let index = localindex {
            if let task = configurations?.getConfigurations()?[index].task {
                guard SharedReference.shared.synctasks.contains(task) else {
                    info.stringValue = Infoexecute().info(num: 7)
                    return
                }
                presentAsSheet(viewControllerInformationLocalRemote!)
            }
        }
    }

    // Presenting Information from Rsync
    @IBAction func information(_: NSButton) {
        globalMainQueue.async { () in
            self.presentAsSheet(self.viewControllerInformation!)
        }
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        guard SharedReference.shared.process == nil else { return }
        presentAsModalWindow(viewControllerProfile!)
    }

    // Selecting About
    @IBAction func about(_: NSButton) {
        guard SharedReference.shared.process == nil else { return }
        presentAsModalWindow(viewControllerAbout!)
    }

    // All ouput
    @IBAction func alloutput(_: NSButton) {
        guard SharedReference.shared.process == nil else { return }
        presentAsModalWindow(viewControllerAllOutput!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        help()
    }

    @IBAction func delete(_: NSButton) {
        guard SharedReference.shared.process == nil else { return }
        delete()
    }

    @IBAction func rsyncosxsched(_: NSButton) {
        guard SharedReference.shared.enableschdules == true else { return }
        let running = Running()
        guard running.rsyncOSXschedisrunning == false else { return }
        guard running.verifyrsyncosxsched() == true else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: (SharedReference.shared.pathrsyncosxsched ?? "/Applications/") + SharedReference.shared.namersyncosssched))
        NSApp.terminate(self)
    }

    func executetask(index: Int?) {
        if let index = index {
            if let task = configurations?.getConfigurations()?[index].task {
                guard SharedReference.shared.synctasks.contains(task) else { return }
                if let config = configurations?.getConfigurations()?[index] {
                    info.stringValue = Infoexecute().info(num: 11)
                    info.textColor = setcolor(nsviewcontroller: self, color: .green)
                    if PreandPostTasks(config: config).executepretask || PreandPostTasks(config: config).executeposttask {
                        executetasknow = ExecuteTaskNowShellOut(index: index)
                    } else {
                        executetasknow = ExecuteTaskNow(index: index)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create base profile catalog
        CatalogProfile().createrootprofilecatalog()
        // Check on Apple Silicon
        let silicon = ProcessInfo().machineHardwareName?.contains("arm64") ?? false
        if silicon {
            SharedReference.shared.macosarm = true
        } else {
            SharedReference.shared.macosarm = false
        }
        // Must read userconfig when loading main view, view only load once
        // ReadUserConfigurationPLIST()
        ReadUserConfigurationJSON()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.allowsMultipleSelection = true
        working.usesThreadedAnimation = true
        SharedReference.shared.setvcref(viewcontroller: .vctabmain, nsviewcontroller: self)
        mainTableView.target = self
        mainTableView.doubleAction = #selector(ViewControllerMain.tableViewDoubleClick(sender:))
        // configurations
        configurations = Configurations(profile: nil)
        initpopupbutton()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // For sending messages to the sidebar
        sidebaractionsDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        sidebaractionsDelegate?.sidebaractions(action: .mainviewbuttons)
        if SharedReference.shared.initialstart == 0 {
            view.window?.center()
            SharedReference.shared.initialstart = 1
            Checkfornewversion()
        }
        if (configurations?.configurations?.count ?? 0) > 0 {
            if localindex == nil {
                globalMainQueue.async { () in
                    self.mainTableView.reloadData()
                }
            }
        }
        displayProfile()
        // Display first time use
        if SharedReference.shared.firsttime {
            let question: String = NSLocalizedString("Welcome to RsyncOSX", comment: "Main")
            let text: String = NSLocalizedString("There are some important info about the first time use of RsyncOSX", comment: "Main")
            let dialog: String = NSLocalizedString("Open", comment: "Main")
            let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
            if answer {
                NSWorkspace.shared.open(URL(string: Resources().getResource(resource: .firsttimeuse))!)
            }
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        multipeselection = false
    }

    func reset() {
        info.stringValue = ""
        // Close edit and parameters view if open
        if let view = SharedReference.shared.getvcref(viewcontroller: .vcrsyncparameters) as? ViewControllerRsyncParameters {
            weak var closeview: ViewControllerRsyncParameters?
            closeview = view
            closeview?.closeview()
        }
        if let view = SharedReference.shared.getvcref(viewcontroller: .vcedit) as? ViewControllerEdit {
            weak var closeview: ViewControllerEdit?
            closeview = view
            closeview?.closeview()
        }
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        executeSingleTask()
    }

    // Single task can be activated by double click from table
    func executeSingleTask() {
        guard checkforrsync() == false else { return }
        if let index = localindex {
            if let task = configurations?.getConfigurations()?[index].task {
                guard SharedReference.shared.synctasks.contains(task) else {
                    info.stringValue = Infoexecute().info(num: 6)
                    return
                }
                guard singletask != nil else {
                    // Dry run
                    info.stringValue = Infoexecute().info(num: 10)
                    info.textColor = setcolor(nsviewcontroller: self, color: .green)
                    singletask = SingleTask(index: index)
                    singletask?.synchronizesingletask()
                    return
                }
                // Real run
                info.stringValue = Infoexecute().info(num: 11)
                info.textColor = setcolor(nsviewcontroller: self, color: .green)
                singletask?.synchronizesingletask()
            }
        }
    }

    // Function for setting profile
    func displayProfile() {
        weak var localprofileinfo: SetProfileinfo?
        localprofileinfo = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        if let profile = configurations?.getProfile() {
            localprofileinfo?.setprofile(profile: profile)
        } else {
            localprofileinfo?.setprofile(profile: nil)
        }
    }

    func createandreloadconfigurations(profile: String?) {
        if let profile = profile {
            configurations = nil
            configurations = Configurations(profile: profile)
        } else {
            configurations = nil
            configurations = Configurations(profile: nil)
        }
        globalMainQueue.async { () in
            self.mainTableView.reloadData()
        }
    }

    func initpopupbutton() {
        var profilestrings: [String]?
        profilestrings = CatalogProfile().getcatalogsasstringnames()
        profilestrings?.insert(NSLocalizedString("Default profile", comment: "default profile"), at: 0)
        profilepopupbutton.removeAllItems()
        profilepopupbutton.addItems(withTitles: profilestrings ?? [])
        profilepopupbutton.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        var profile = profilepopupbutton.titleOfSelectedItem
        let selectedindex = profilepopupbutton.indexOfSelectedItem
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            profile = nil
        }
        profilepopupbutton.selectItem(at: selectedindex)
        if let profile = profile {
            configurations = nil
            configurations = Configurations(profile: profile)
        } else {
            configurations = nil
            configurations = Configurations(profile: nil)
        }
        singletask = nil
        info.stringValue = ""
        globalMainQueue.async { () in
            self.mainTableView.reloadData()
        }
        displayProfile()
    }

    @IBAction func checksynchronizedfiles(_: NSButton) {
        if let index = localindex {
            if let config = configurations?.getConfigurations()?[index] {
                guard config.task != SharedReference.shared.syncremote else {
                    info.stringValue = NSLocalizedString("Cannot verify a syncremote task...", comment: "Verify")
                    return
                }
                guard connected(config: config) == true else {
                    info.stringValue = NSLocalizedString("Seems not to be connected...", comment: "Verify")
                    return
                }
                let check = Checksynchronizedfiles(index: index)
                check.checksynchronizedfiles()
            }
        }
    }

    func delete() {
        guard SharedReference.shared.process == nil else { return }
        guard localindex != nil else {
            info.stringValue = Infoexecute().info(num: 1)
            return
        }
        if let index = localindex {
            deleterow(index: index)
        }
    }

    func deleterow(index: Int?) {
        if let index = index {
            if let hiddenID = configurations?.gethiddenID(index: index) {
                let question: String = NSLocalizedString("Delete selected task?", comment: "Execute")
                let text: String = NSLocalizedString("Cancel or Delete", comment: "Execute")
                let dialog: String = NSLocalizedString("Delete", comment: "Execute")
                let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
                if answer {
                    // Delete Configurations and Schedules by hiddenID
                    configurations?.deleteConfigurationsByhiddenID(hiddenID: hiddenID)
                    deselect()
                    reloadtabledata()
                }
            }
            reset()
            singletask = nil
        }
    }
}
