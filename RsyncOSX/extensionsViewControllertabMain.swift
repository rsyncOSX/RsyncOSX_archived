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

    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let dateformatter = Dateandtime().setDateformat()
        if row > self.configurations!.configurationsDataSourcecount() - 1 { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSource()![row]
        let hiddenID: Int = self.configurations!.getConfigurations()[row].hiddenID
        let markdays: Bool = self.configurations!.getConfigurations()[row].markdays
        let celltext = object[tableColumn!.identifier] as? String
        if tableColumn!.identifier.rawValue == "daysID" {
            if markdays {
                return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
            } else {
                return object[tableColumn!.identifier] as? String
            }
        } else if tableColumn!.identifier.rawValue == "offsiteServerCellID",
            ((object[tableColumn!.identifier] as? String)?.isEmpty) == true {
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
                if self.singletask == nil {
                    return #imageLiteral(resourceName: "yellow")
                } else {
                    return #imageLiteral(resourceName: "green")
                }
            }
        } else if tableColumn!.identifier.rawValue == "snapCellID" {
            let snap = object.value(forKey: "snapCellID") as? Int ?? -1
            if snap > 0 {
                 return String(snap - 1)
            } else {
                return ""
            }
        } else if tableColumn!.identifier.rawValue == "runDateCellID" {
            let stringdate: String = object[tableColumn!.identifier] as? String ?? ""
            if stringdate.isEmpty {
                return ""
            } else {
                let date = dateformatter.date(from: stringdate)
                return date?.localizeDate()
            }
        } else {
            if tableColumn!.identifier.rawValue == "batchCellID" {
                return object[tableColumn!.identifier] as? Int
            } else {
                if (self.tcpconnections?.gettestAllremoteserverConnections()?[row]) ?? false && celltext != nil {
                    return self.attributedstring(str: celltext!, color: NSColor.red, align: .left)
                } else {
                    return object[tableColumn!.identifier] as? String
                }
            }
        }
        return nil
    }

    // Toggling batch
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if self.process != nil {
            self.abortOperations()
        }
        if self.configurations!.getConfigurations()[row].task == ViewControllerReference.shared.synchronize ||
            self.configurations!.getConfigurations()[row].task == ViewControllerReference.shared.snapshot {
            self.configurations!.enabledisablebatch(row)
        }
        self.singletask = nil
        self.batchtasks = nil
    }
}

// Get output from rsync command
extension ViewControllertabMain: GetOutput {
    // Get information from rsync output.
    func getoutput() -> [String] {
         return (self.outputprocess?.trimoutput(trim: .two)) ?? []
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
    func rsyncuserparamsupdated() {
        self.showrsynccommandmainview()
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
        self.singletask = nil
        self.tcpconnections = nil
        self.setNumbers(outputprocess: nil)
        self.showrsynccommandmainview()
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
    }

    func enableProfileMenu() {
        self.loadProfileMenu = true
        globalMainQueue.async(execute: { () -> Void in
            self.displayProfile()
        })
    }
}

// Rsync path is changed, update displayed rsync command
extension ViewControllertabMain: RsyncIsChanged {
    func rsyncischanged() {
        self.showrsynccommandmainview()
        self.setinfoaboutrsync()
    }
}

// Check for remote connections, reload table when completed.
extension ViewControllertabMain: Connections {
    func displayConnections() {
        guard Activetab(viewcontroller: .vctabmain).isactive == true else { return }
        self.loadProfileMenu = true
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllertabMain: NewVersionDiscovered {
    func notifyNewVersion() {
        guard Activetab(viewcontroller: .vctabmain).isactive == true else { return }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.newVersionViewController!)
        })
    }
}

extension ViewControllertabMain: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        self.loadProfileMenu = true
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
            self.displayProfile()
        })
        self.setinfoaboutrsync()
    }
}

extension ViewControllertabMain: DismissViewEstimating {
    func dismissestimating(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}

// Called when either a terminatopn of Process is
// discovered or data is availiable in the filehandler
extension ViewControllertabMain: UpdateProgress {

    func processTermination() {
        self.readyforexecution = true
        if self.configurations!.processtermination == nil {
            self.configurations!.processtermination = .singlequicktask
        }
        switch self.configurations!.processtermination! {
        case .singletask, .singlequicktask, .quicktask:
            return
        case .batchtask:
            self.batchtasksDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
            self.batchtasks = self.batchtasksDelegate?.getbatchtaskObject()
            self.outputprocess = self.batchtasks?.outputprocess
            self.process = self.batchtasks?.process
            self.batchtasks?.processTermination()
        case .remoteinfotask:
            guard self.configurations!.remoteinfotaskworkqueue != nil else { return }
            self.configurations!.remoteinfotaskworkqueue?.processTermination()
        case .infosingletask:
            weak var processterminationDelegate: UpdateProgress?
            processterminationDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcinfolocalremote) as? ViewControllerInformationLocalRemote
            processterminationDelegate?.processTermination()
        case .automaticbackup:
            guard self.configurations!.remoteinfotaskworkqueue != nil else { return }
            weak var estimateupdateDelegate: Updateestimating?
            estimateupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcestimatingtasks) as? ViewControllerEstimatingTasks
            // compute alle estimates
            if self.configurations!.remoteinfotaskworkqueue!.stackoftasktobeestimated != nil {
                self.configurations!.remoteinfotaskworkqueue?.processTermination()
                estimateupdateDelegate?.updateProgressbar()
            } else {
                estimateupdateDelegate?.dismissview()
                self.configurations!.remoteinfotaskworkqueue?.processTermination()
                self.configurations!.remoteinfotaskworkqueue?.selectalltaskswithnumbers(deselect: false)
                self.configurations!.remoteinfotaskworkqueue?.setbackuplist()
                weak var openDelegate: OpenQuickBackup?
                switch ViewControllerReference.shared.activetab ?? .vctabmain {
                case .vcnewconfigurations:
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
                case .vctabmain:
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
                case .vctabschedule:
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
                case .vccopyfiles:
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
                case .vcsnapshot:
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
                case .vcverify:
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcverify) as? ViewControllerVerify
                case .vcssh:
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
                case .vcloggdata:
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
                default:
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
                }
                openDelegate?.openquickbackup()
            }
        case .restore:
            weak var processterminationDelegate: UpdateProgress?
            processterminationDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
            processterminationDelegate?.processTermination()
        case .estimatebatchtask:
            guard self.configurations!.remoteinfotaskworkqueue != nil else { return }
            weak var estimateupdateDelegate: Updateestimating?
            estimateupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcestimatingtasks) as? ViewControllerEstimatingTasks
            // compute alle estimates
            if self.configurations!.remoteinfotaskworkqueue!.stackoftasktobeestimated != nil {
                self.configurations!.remoteinfotaskworkqueue?.processTermination()
                estimateupdateDelegate?.updateProgressbar()
            } else {
                self.configurations!.remoteinfotaskworkqueue?.processTermination()
                self.configurations!.processtermination = .batchtask
            }
        }
    }

    // Function is triggered when Process outputs data in filehandler
    // Process is either in singleRun or batchRun
    func fileHandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        if self.configurations!.processtermination == nil {
            self.configurations!.processtermination = .singlequicktask
        }
        switch self.configurations!.processtermination! {
        case .singletask, .infosingletask, .automaticbackup, .estimatebatchtask, .quicktask, .singlequicktask:
            return
        case .batchtask:
            weak var localprocessupdateDelegate: UpdateProgress?
            localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
            localprocessupdateDelegate?.fileHandler()
        case .remoteinfotask:
            outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            if outputeverythingDelegate?.appendnow() ?? false {
                outputeverythingDelegate?.reloadtable()
            }
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
            self.seterrorinfo(info: "Error")
            self.showrsynccommandmainview()
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
            if self.batchtasks != nil {
                self.batchtasks!.error()
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
            } else if errortype == .filesize {
                self.rsyncCommand.stringValue = self.errordescription(errortype: errortype) + ": filesize = " + errorstr
            } else {
                self.seterrorinfo(info: "Error")
                self.rsyncCommand.stringValue = self.errordescription(errortype: errortype) + "\n" + errorstr
            }
        })
    }
}

// Abort task from progressview
extension ViewControllertabMain: Abort {
    // Abort any task
    func abortOperations() {
        // Terminates the running process
        if let process = self.process {
            process.terminate()
            self.index = nil
            self.working.stopAnimation(nil)
            self.workinglabel.isHidden = true
            self.process = nil
            // Create workqueu and add abort
            self.seterrorinfo(info: "Abort")
            self.rsyncCommand.stringValue = ""
            if self.configurations!.remoteinfotaskworkqueue != nil && self.configurations?.estimatedlist != nil {
                weak var localestimateupdateDelegate: Updateestimating?
                localestimateupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcestimatingtasks) as? ViewControllerEstimatingTasks
                localestimateupdateDelegate?.dismissview()
                self.configurations!.remoteinfotaskworkqueue = nil
            }
        } else {
            self.working.stopAnimation(nil)
            self.workinglabel.isHidden = true
            self.rsyncCommand.stringValue = NSLocalizedString("Selection out of range - aborting", comment: "Execute")
            self.process = nil
            self.index = nil
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

    func presentViewProgress() {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerProgress!)
        })
    }

    func presentViewInformation(outputprocess: OutputProcess) {
        self.outputprocess = outputprocess
        if self.dynamicappend {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        } else {
            globalMainQueue.async(execute: { () -> Void in
                self.presentAsSheet(self.viewControllerInformation!)
            })
        }
    }

    func terminateProgressProcess() {
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess
        localprocessupdateDelegate?.processTermination()
    }

    func seterrorinfo(info: String) {
        guard info != "" else {
            self.errorinfo.isHidden = true
            return
        }
        self.errorinfo.textColor = setcolor(nsviewcontroller: self, color: .red)
        self.errorinfo.isHidden = false
        self.errorinfo.stringValue = info
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

extension ViewControllertabMain: GetConfigurationsObject {
    func getconfigurationsobject() -> Configurations? {
        guard self.configurations != nil else { return nil }
        return self.configurations
    }

    func createconfigurationsobject(profile: String?) -> Configurations? {
        self.configurations = nil
        self.configurations = Configurations(profile: profile)
        return self.configurations
    }

    // After a write, a reload is forced.
    func reloadconfigurationsobject() {
        // If batchtask keep configuration object
        self.batchtasks = self.batchtasksDelegate?.getbatchtaskObject()
        guard self.batchtasks == nil else {
            // Batchtask, check if task is completed
            guard self.configurations!.getbatchQueue()?.batchruniscompleted() == false else {
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
        guard self.batchtasks == nil else {
            // Batchtask, check if task is completed
            guard self.configurations!.getbatchQueue()?.batchruniscompleted() == false else {
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
        return self.schedules
    }
}

extension  ViewControllertabMain: GetHiddenID {
    func gethiddenID() -> Int {
        return self.hiddenID ?? -1
    }
}

extension ViewControllertabMain: Setinfoaboutrsync {
    internal func setinfoaboutrsync() {
        if ViewControllerReference.shared.norsync == true {
            self.info.stringValue = Infoexecute().info(num: 3)
        } else {
            self.info.stringValue = Infoexecute().info(num: 0)
            self.rsyncversionshort.stringValue = ViewControllerReference.shared.rsyncversionshort ?? ""
        }
    }
}

extension ViewControllertabMain: ErrorOutput {
    func erroroutput() {
        self.info.stringValue = Infoexecute().info(num: 2)
    }
}

extension ViewControllertabMain: Createandreloadconfigurations {
    // func reateandreloadconfigurations()
}

extension ViewControllertabMain: SendProcessreference {
    func sendoutputprocessreference(outputprocess: OutputProcess?) {
        self.outputprocess = outputprocess
    }

    func sendprocessreference(process: Process?) {
        self.process = process
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
        self.configurations!.processtermination = .quicktask
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
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

extension ViewControllertabMain: SetLocalRemoteInfo {
    func getlocalremoteinfo(index: Int) -> NSDictionary? {
        guard self.configurations?.localremote != nil else { return nil }
        if let info = self.configurations?.localremote?.filter({($0.value(forKey: "index") as? Int)! == index}) {
            guard info.count > 0 else { return nil }
            return info[0]
        } else {
            return nil
        }
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

extension ViewControllertabMain: Allerrors {
    func allerrors(outputprocess: OutputProcess?) {
        globalMainQueue.async(execute: { () -> Void in
            self.seterrorinfo(info: "Error")
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

    func disableappend() {
        self.dynamicappend = false
    }

    func enableappend() {
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

extension ViewControllertabMain: AllProfileDetails {
    func disablereloadallprofiles() {
        self.allprofilesview = false
    }

    func enablereloadallprofiles() {
        self.allprofilesview = true
        self.allprofiledetailsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcallprofiles) as? ViewControllerAllProfiles
    }

}
