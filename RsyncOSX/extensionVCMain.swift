//
//  extensionsViewControllertabMain.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.05.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable file_length line_length

import Foundation
import Cocoa

// Get output from rsync command
extension ViewControllerMain: GetOutput {
    // Get information from rsync output.
    func getoutput() -> [String] {
         return (self.outputprocess?.trimoutput(trim: .two)) ?? []
    }
}

// Scheduled task are changed, read schedule again og redraw table
extension ViewControllerMain: Reloadandrefresh {
    // Refresh tableView in main
    func reloadtabledata() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

// Parameters to rsync is changed
extension ViewControllerMain: RsyncUserParams {
    func rsyncuserparamsupdated() {
        self.showrsynccommandmainview()
    }
}

// Get index of selected row
extension ViewControllerMain: GetSelecetedIndex {
    func getindex() -> Int? {
        return self.index
    }
}

// New profile is loaded.
extension ViewControllerMain: NewProfile {
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
extension ViewControllerMain: RsyncIsChanged {
    func rsyncischanged() {
        self.showrsynccommandmainview()
        self.setinfoaboutrsync()
    }
}

// Check for remote connections, reload table when completed.
extension ViewControllerMain: Connections {
    func displayConnections() {
        guard (self.presentingViewController as? ViewControllerMain) != nil else { return }
        self.loadProfileMenu = true
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerMain: NewVersionDiscovered {
    func notifyNewVersion() {
        // guard (self.presentingViewController as? ViewControllerMain) != nil else { return }
        globalMainQueue.async(execute: { () -> Void in
                // self.presentAsSheet(self.newVersionViewController!)
           self.info.stringValue = Infoexecute().info(num: 9)
        })
    }
}

extension ViewControllerMain: DismissViewController {
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

// Deselect a row
extension ViewControllerMain: DeselectRowTable {
    // deselect a row after row is deleted
    func deselect() {
        guard self.index != nil else { return }
        self.mainTableView.deselectRow(self.index!)
    }
}

// If rsync throws any error
extension ViewControllerMain: RsyncError {
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
            if self.executebatch != nil {
                self.executebatch!.error()
            }
        })
    }
}

// If, for any reason, handling files or directory throws an error
extension ViewControllerMain: Fileerror {
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
extension ViewControllerMain: Abort {
    // Abort any task
    func abortOperations() {
        // Terminates the running process
        if let process = self.process {
            process.terminate()
            self.process = nil
            self.seterrorinfo(info: "Abort")
            self.rsyncCommand.stringValue = ""
            if self.configurations!.remoteinfoestimation != nil && self.configurations?.estimatedlist != nil {
                self.configurations!.remoteinfoestimation = nil
            }
        } else {
            self.rsyncCommand.stringValue = NSLocalizedString("Selection out of range - aborting", comment: "Execute")
        }
        self.working.stopAnimation(nil)
        self.workinglabel.isHidden = true
        self.process = nil
        self.index = nil
    }
}

// Extensions from here are used in either newSingleTask or newBatchTask

extension ViewControllerMain: StartStopProgressIndicatorSingleTask {
    func startIndicatorExecuteTaskNow() {
         self.working.startAnimation(nil)
    }
    func startIndicator() {
        self.working.startAnimation(nil)
        self.workinglabel.isHidden = false
    }

    func stopIndicator() {
        self.working.stopAnimation(nil)
        self.workinglabel.isHidden = true
    }
}

extension ViewControllerMain: GetConfigurationsObject {
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
        guard self.executebatch == nil else {
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

extension ViewControllerMain: GetSchedulesObject {
    func reloadschedulesobject() {
        // If batchtask scedules object
        guard self.executebatch == nil else {
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

extension  ViewControllerMain: GetHiddenID {
    func gethiddenID() -> Int {
        return self.hiddenID ?? -1
    }
}

extension ViewControllerMain: Setinfoaboutrsync {
    internal func setinfoaboutrsync() {
        if ViewControllerReference.shared.norsync == true {
            self.info.stringValue = Infoexecute().info(num: 3)
        } else {
            self.rsyncversionshort.stringValue = ViewControllerReference.shared.rsyncversionshort ?? ""
        }
    }
}

extension ViewControllerMain: ErrorOutput {
    func erroroutput() {
        self.info.stringValue = Infoexecute().info(num: 2)
    }
}

extension ViewControllerMain: Createandreloadconfigurations {
    // func reateandreloadconfigurations()
}

extension ViewControllerMain: SendProcessreference {
    func sendoutputprocessreference(outputprocess: OutputProcess?) {
        self.outputprocess = outputprocess
    }

    func sendprocessreference(process: Process?) {
        self.process = process
    }
}

extension ViewControllerMain: SetRemoteInfo {
    func getremoteinfo() -> RemoteinfoEstimation? {
        return self.configurations!.remoteinfoestimation
    }

    func setremoteinfo(remoteinfotask: RemoteinfoEstimation?) {
        self.configurations!.remoteinfoestimation = remoteinfotask
    }
}

extension ViewControllerMain: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        })
    }
}

extension ViewControllerMain: Count {
    func maxCount() -> Int {
        return self.outputprocess?.getMaxcount() ?? 0
    }

    func inprogressCount() -> Int {
        return self.outputprocess?.count() ?? 0
    }
}

extension ViewControllerMain: Reloadsortedandrefresh {
    func reloadsortedandrefreshtabledata() {
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerMain: MenuappChanged {
    func menuappchanged() {
        self.enablemenuappbutton()
    }
}

extension ViewControllerMain: SetLocalRemoteInfo {
    func getlocalremoteinfo(index: Int) -> [NSDictionary]? {
        guard self.configurations?.localremote != nil else { return nil }
        if let info = self.configurations?.localremote?.filter({($0.value(forKey: "index") as? Int)! == index}) {
            return info
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

extension ViewControllerMain: Allerrors {
    func allerrors(outputprocess: OutputProcess?) {
        globalMainQueue.async(execute: { () -> Void in
            self.seterrorinfo(info: "Error")
        })
        self.outputprocess = nil
        if self.outputerrors == nil {
            self.outputerrors = OutputErrors()
        }
        for i in 0 ..< (outputprocess?.getOutput()?.count ?? 0) {
            self.outputerrors!.addLine(str: outputprocess!.getOutput()![i])
        }
    }

    func getoutputerrors() -> OutputErrors? {
        return self.outputerrors
    }
}

extension ViewControllerMain: ViewOutputDetails {

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

extension ViewControllerMain: AllProfileDetails {
    func disablereloadallprofiles() {
        self.allprofilesview = false
    }

    func enablereloadallprofiles() {
        self.allprofilesview = true
        self.allprofiledetailsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcallprofiles) as? ViewControllerAllProfiles
    }
}

enum Color {
    case red
    case white
    case green
    case black
}

protocol Setcolor: class {
    func setcolor(nsviewcontroller: NSViewController, color: Color) -> NSColor
}

extension Setcolor {

    private func isDarkMode(view: NSView) -> Bool {
        if #available(OSX 10.14, *) {
            return view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
        return false
    }

    func setcolor(nsviewcontroller: NSViewController, color: Color) -> NSColor {
        let darkmode = isDarkMode(view: nsviewcontroller.view)
        switch color {
        case .red:
            return .red
        case .white:
            if darkmode {
                return .white
            } else {
                return .black
            }
        case .green:
            if darkmode {
                return .green
            } else {
                return .blue
            }
        case .black:
            if darkmode {
                return .white
            } else {
                return .black
            }
        }
    }
}

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
