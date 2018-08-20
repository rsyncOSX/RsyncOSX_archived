//
//  extensionsViewControllertabMain.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.05.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable file_length line_length cyclomatic_complexity function_body_length

import Foundation
import Cocoa

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
            return object[tableColumn!.identifier]
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
    }
}

// Get output from rsync command
extension ViewControllertabMain: Information {
    // Get information from rsync output.
    func getInformation() -> [String] {
        if self.outputbatch != nil {
            return self.outputbatch?.getOutput() ?? [""]
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
        self.presentrsynccommandtindisplay()
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
        self.serverOff = nil
        self.setNumbers(outputprocess: nil)
        self.presentrsynccommandtindisplay()
        self.setInfo(info: "Estimate", color: .blue)
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
            self.scheduleJobworkinglabel.isHidden = false
        })
    }

    func completed() {
        globalMainQueue.async(execute: {() -> Void in
            self.scheduledJobInProgress = false
            self.info(num: 1)
            self.scheduledJobworking.stopAnimation(nil)
            self.scheduleJobworkinglabel.isHidden = true
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
    func rsyncischanged() {
        // Update rsync command in display
        self.presentrsynccommandtindisplay()
        self.setinfoaboutrsync()
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
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
            self.displayProfile()
        })
        self.showProcessInfo(info: .blank)
        self.setinfoaboutrsync()
        if viewcontroller == ViewControllerReference.shared.getvcref(viewcontroller: .vcquickbackup) {
            self.configurations!.allowNotifyinMain = true
        }
    }
}

extension ViewControllertabMain: DismissViewEstimating {
    func dismissestimating(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
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
            guard self.configurations!.remoteinfotaskworkqueue != nil else { return }
            self.configurations!.remoteinfotaskworkqueue?.processTermination()
        case .infosingletask:
            weak var processterminationDelegate: UpdateProgress?
            processterminationDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcinfolocalremote) as? ViewControllerInformationLocalRemote
            processterminationDelegate?.processTermination()
        case .combinedtask:
            self.working.stopAnimation(nil)
            self.executetasknow()
        case .automaticbackup:
            guard self.configurations!.remoteinfotaskworkqueue != nil else { return }
            // compute alle estimates
            if self.configurations!.remoteinfotaskworkqueue!.stackoftasktobeestimated != nil {
                self.configurations!.remoteinfotaskworkqueue?.processTermination()
                self.estimateupdateDelegate?.updateProgressbar()
            } else {
                self.estimateupdateDelegate?.dismissview()
                self.configurations!.remoteinfotaskworkqueue?.processTermination()
                self.configurations!.remoteinfotaskworkqueue?.selectalltaskswithnumbers(deselect: false)
                self.configurations!.remoteinfotaskworkqueue?.setbackuplist()
                self.openquickbackup()
            }
        case .restore:
            weak var processterminationDelegate: UpdateProgress?
            processterminationDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
            processterminationDelegate?.processTermination()
        }
    }

    // Function is triggered when Process outputs data in filehandler
    // Process is either in singleRun or batchRun
    func fileHandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
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
            outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            if outputeverythingDelegate?.appendnow() ?? false {
                outputeverythingDelegate?.reloadtable()
            }
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
            outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            if outputeverythingDelegate?.appendnow() ?? false {
                outputeverythingDelegate?.reloadtable()
            }
        case .remoteinfotask:
            return
        case .infosingletask:
            return
        case .combinedtask:
            return
        case .automaticbackup:
            return
        case .restore:
            weak var localprocessupdateDelegate: UpdateProgress?
            localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
            localprocessupdateDelegate?.fileHandler()
            outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            if outputeverythingDelegate?.appendnow() ?? false {
                outputeverythingDelegate?.reloadtable()
            }
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
            self.showProcessInfo(info: .error)
            self.presentrsynccommandtindisplay()
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
    func errormessage(errorstr: String, errortype: Fileerrortype ) {
        globalMainQueue.async(execute: { () -> Void in
            if errortype == .openlogfile {
                self.rsyncCommand.stringValue = self.errordescription(errortype: errortype)
            } else {
                self.setInfo(info: "Error", color: .red)
                self.showProcessInfo(info: .error)
                self.rsyncCommand.stringValue = self.errordescription(errortype: errortype) + "\n" + errorstr
            }
        })
    }
}

// Abort task from progressview
extension ViewControllertabMain: AbortOperations {
    // Abort any task
    func abortOperations() {
        // Terminates the running process
        self.showProcessInfo(info: .abort)
        if let process = self.process {
            process.terminate()
            self.index = nil
            self.working.stopAnimation(nil)
            self.workinglabel.isHidden = true
            self.process = nil
            // Create workqueu and add abort
            self.setInfo(info: "Abort", color: .red)
            self.rsyncCommand.stringValue = ""
            if self.configurations!.remoteinfotaskworkqueue != nil && self.configurations?.estimatedlist != nil {
                self.estimateupdateDelegate?.dismissview()
            }
        } else {
            self.working.stopAnimation(nil)
            self.workinglabel.isHidden = true
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
        }
    }
}

// Extensions from here are used in either newSingleTask or newBatchTask

extension ViewControllertabMain: StartStopProgressIndicatorSingleTask {
    func startIndicator() {
        self.working.startAnimation(nil)
        self.workinglabel.isHidden = false
    }

    func stopIndicator() {
        self.working.stopAnimation(nil)
        self.workinglabel.isHidden = true
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
        ViewControllerReference.shared.scheduledTask = self.schedulesortedandexpanded?.firstscheduledtask()
        return self.schedules
    }
}

extension  ViewControllertabMain: GetHiddenID {
    func gethiddenID() -> Int? {
        return self.hiddenID
    }
}

extension ViewControllertabMain: Setinfoaboutrsync {
    internal func setinfoaboutrsync() {
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
    func getremoteinfo() -> RemoteInfoTaskWorkQueue? {
        return self.configurations!.remoteinfotaskworkqueue
    }

    func setremoteinfo(remoteinfotask: RemoteInfoTaskWorkQueue?) {
        self.configurations!.remoteinfotaskworkqueue = remoteinfotask
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

extension ViewControllertabMain: MenuappChanged {
    func menuappchanged() {
        self.enablemenuappbutton()
    }
}

extension ViewControllertabMain: Norcloneconfig {
    func norcloneconfig() {
        self.working.stopAnimation(nil)
        self.info(num: 8)
    }
}

extension ViewControllertabMain: SetLocalRemoteInfo {
    func getlocalremoteinfo(index: Int) -> NSMutableDictionary? {
        guard self.configurations?.localremote != nil else { return nil }
        let info = self.configurations?.localremote?.filter({($0.value(forKey: "index") as? Int)! == index})
        guard info?.count ?? -1 == 1 else { return nil }
        return info![0]
    }

    func setlocalremoteinfo(info: NSMutableDictionary?) {
        guard info != nil else { return }
        if self.configurations?.localremote == nil {
            self.configurations?.localremote = [NSMutableDictionary]()
            self.configurations?.localremote!.append(info!)
        } else {
            self.configurations?.localremote!.append(info!)
        }
    }
}

extension ViewControllertabMain: GetsortedanexpandedObject {
    func getsortedanexpandedObject() -> ScheduleSortedAndExpand? {
        return self.schedulesortedandexpanded
    }
}

extension ViewControllertabMain: Allerrors {
    func allerrors(outputprocess: OutputProcess?) {
        globalMainQueue.async(execute: { () -> Void in
            self.setInfo(info: "Error", color: .red)
            self.showProcessInfo(info: .error)
        })
        self.outputprocess = nil
        if self.outputerrors == nil {
            self.outputerrors = OutputErrors()
        }
        guard outputprocess?.getOutput() != nil else { return }
        for i in 0 ..< outputprocess!.getOutput()!.count {
            self.outputerrors!.addLine(str: outputprocess!.getOutput()![i])
        }
    }

    func getoutputerrors() -> OutputErrors? {
        return self.outputerrors
    }
}

extension ViewControllertabMain: ViewOutputDetails {

    func enableallinfobutton() {
        self.allinfobutton.isEnabled = true
        self.dynamicappend = false
    }

    func disableallinfobutton() {
        self.allinfobutton.isEnabled = false
        self.dynamicappend = true
    }

    func getalloutput() -> [String] {
        return self.outputprocess?.getrawOutput() ?? []
    }

    func reloadtable() {
        weak var localreloadDelegate: Reloadandrefresh?
        localreloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcalloutput) as? ViewControllerAllOutput
        localreloadDelegate?.reloadtabledata()
    }

    func appendnow() -> Bool {
        return self.dynamicappend
    }
}
