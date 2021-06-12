//
//  extensionsViewControllertabMain.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.05.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable file_length

import Cocoa
import Foundation

// Get output from rsync command
extension ViewControllerMain: GetOutput {
    // Get information from rsync output.
    func getoutput() -> [String] {
        return TrimTwo(outputprocess?.getOutput() ?? []).trimmeddata
    }
}

// Scheduled task are changed, read schedule again og redraw table
extension ViewControllerMain: Reloadandrefresh {
    // Refresh tableView in main
    func reloadtabledata() {
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }
}

// Get index of selected row
extension ViewControllerMain: GetSelecetedIndex {
    func getindex() -> Int? {
        return index
    }
}

// New profile is loaded.
extension ViewControllerMain: NewProfile {
    // Function is called from profiles when new or default profiles is seleceted
    func newprofile(profile: String?, selectedindex: Int?) {
        if let index = selectedindex {
            profilepopupbutton.selectItem(at: index)
        } else {
            initpopupbutton()
        }
        reset()
        singletask = nil
        deselect()
        // Read configurations and Scheduledata
        configurations = createconfigurationsobject(profile: profile)
        schedules = createschedulesobject(profile: profile)
        // Make sure loading profile
        displayProfile()
        reloadtabledata()
        // Reset in tabSchedule
        reloadtable(vcontroller: .vctabschedule)
        deselectrowtable(vcontroller: .vctabschedule)
        reloadtable(vcontroller: .vcsnapshot)
    }

    func reloadprofilepopupbutton() {
        globalMainQueue.async { () -> Void in
            self.displayProfile()
        }
    }

    func createschedulesobject(profile: String?) -> Schedules? {
        schedules = nil
        schedules = Schedules(profile: profile)
        schedulesortedandexpanded = ScheduleSortedAndExpand()
        return schedules
    }

    func createconfigurationsobject(profile: String?) -> Configurations? {
        configurations = nil
        configurations = Configurations(profile: profile)
        return configurations
    }
}

// Rsync path is changed, update displayed rsync command
extension ViewControllerMain: RsyncIsChanged {
    func rsyncischanged() {
        setinfoaboutrsync()
    }
}

// Check for remote connections, reload table when completed.
extension ViewControllerMain: Connections {
    func displayConnections() {
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }
}

extension ViewControllerMain: NewVersionDiscovered {
    func notifyNewVersion() {
        globalMainQueue.async { () -> Void in
            self.info.stringValue = Infoexecute().info(num: 9)
        }
    }
}

extension ViewControllerMain: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        dismiss(viewcontroller)
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
            self.displayProfile()
        }
        setinfoaboutrsync()
    }
}

// Deselect a row
extension ViewControllerMain: DeselectRowTable {
    // deselect a row after row is deleted
    func deselect() {
        if let index = self.index {
            SharedReference.shared.process = nil
            self.index = nil
            mainTableView.deselectRow(index)
        }
    }
}

// If rsync throws any error
extension ViewControllerMain: RsyncError {
    func rsyncerror() {
        // Set on or off in user configuration
        globalMainQueue.async { () -> Void in
            self.info.stringValue = "Rsync error, see logfile..."
            self.info.textColor = self.setcolor(nsviewcontroller: self, color: .red)
            self.info.isHidden = false
            guard SharedReference.shared.haltonerror == true else { return }
            self.deselect()
            _ = InterruptProcess()
            self.singletask?.error()
        }
    }
}

// If, for any reason, handling files or directory throws an error
extension ViewControllerMain: ErrorMessage {
    func errormessage(errorstr: String, error errortype: RsyncOSXTypeErrors) {
        globalMainQueue.async { () -> Void in
            if errortype == .logfilesize {
                self.info.stringValue = "Reduce size logfile, filesize is: " + errorstr
                self.info.textColor = self.setcolor(nsviewcontroller: self, color: .red)
                self.info.isHidden = false
            } else {
                self.outputprocess?.addlinefromoutput(str: errorstr + "\n" + errorstr)
                self.info.stringValue = "Some error: see logfile."
                self.info.textColor = self.setcolor(nsviewcontroller: self, color: .red)
                self.info.isHidden = false
            }
            var message = [String]()
            message.append(errorstr)
            _ = Logfile(message, error: true)
        }
    }
}

// Abort task from progressview
extension ViewControllerMain: Abort {
    // Abort the task
    func abortOperations() {
        _ = InterruptProcess()
        working.stopAnimation(nil)
        index = nil
        info.stringValue = ""
    }
}

// Extensions from here are used in newSingleTask
extension ViewControllerMain: StartStopProgressIndicatorSingleTask {
    func startIndicatorExecuteTaskNow() {
        working.startAnimation(nil)
    }

    func startIndicator() {
        working.startAnimation(nil)
    }

    func stopIndicator() {
        working.stopAnimation(nil)
    }
}

extension ViewControllerMain: GetConfigurationsObject {
    func getconfigurationsobject() -> Configurations? {
        guard configurations != nil else { return nil }
        return configurations
    }

    // After a write, a reload is forced.
    func reloadconfigurationsobject() {
        createandreloadconfigurations()
    }

    func getschedulesortedandexpanded() -> ScheduleSortedAndExpand? {
        return schedulesortedandexpanded
    }
}

extension ViewControllerMain: GetSchedulesObject {
    func reloadschedulesobject() {
        createandreloadschedules()
    }

    func getschedulesobject() -> Schedules? {
        return schedules
    }
}

extension ViewControllerMain: Setinfoaboutrsync {
    internal func setinfoaboutrsync() {
        if SharedReference.shared.norsync == true {
            info.stringValue = Infoexecute().info(num: 3)
        } else {
            rsyncversionshort.stringValue = SharedReference.shared.rsyncversionshort ?? ""
        }
    }
}

extension ViewControllerMain: ErrorOutput {
    func erroroutput() {
        info.stringValue = Infoexecute().info(num: 2)
    }
}

extension ViewControllerMain: SendOutputProcessreference {
    func sendoutputprocessreference(outputprocess: OutputfromProcess?) {
        self.outputprocess = outputprocess
    }
}

extension ViewControllerMain: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerMain: Count {
    func maxCount() -> Int {
        return TrimTwo(outputprocess?.getOutput() ?? []).maxnumber
    }

    func inprogressCount() -> Int {
        return outputprocess?.getOutput()?.count ?? 0
    }
}

extension ViewControllerMain: ViewOutputDetails {
    func getalloutput() -> [String] {
        return outputprocess?.getOutput() ?? []
    }

    func reloadtable() {
        weak var localreloadDelegate: Reloadandrefresh?
        localreloadDelegate = SharedReference.shared.getvcref(viewcontroller: .vcalloutput) as? ViewControllerAllOutput
        localreloadDelegate?.reloadtabledata()
    }

    func appendnow() -> Bool {
        if SharedReference.shared.getvcref(viewcontroller: .vcalloutput) != nil {
            return true
        } else {
            return false
        }
    }
}

enum Color {
    case red
    case white
    case green
    case black
}

protocol Setcolor: AnyObject {
    func setcolor(nsviewcontroller: NSViewController, color: Color) -> NSColor
}

extension Setcolor {
    private func isDarkMode(view: NSView) -> Bool {
        return view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
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

protocol Checkforrsync: AnyObject {
    func checkforrsync() -> Bool
}

extension Checkforrsync {
    func checkforrsync() -> Bool {
        if SharedReference.shared.norsync == true {
            _ = Norsync()
            return true
        } else {
            return false
        }
    }
}

// Protocol for start,stop, complete progressviewindicator
protocol StartStopProgressIndicator: AnyObject {
    func start()
    func stop()
}

// Protocol for either completion of work or update progress when Process discovers a
// process termination and when filehandler discover data
protocol UpdateProgress: AnyObject {
    func processTermination()
    func fileHandler()
}

protocol ViewOutputDetails: AnyObject {
    func reloadtable()
    func appendnow() -> Bool
    func getalloutput() -> [String]
}

// Get multiple selected indexes
protocol GetMultipleSelectedIndexes: AnyObject {
    func getindexes() -> [Int]
    func multipleselection() -> Bool
}

extension ViewControllerMain: GetMultipleSelectedIndexes {
    func multipleselection() -> Bool {
        return multipeselection
    }

    func getindexes() -> [Int] {
        if let indexes = self.indexes {
            return indexes.map { $0 }
        } else {
            return []
        }
    }
}

extension ViewControllerMain: DeinitExecuteTaskNow {
    func deinitexecutetasknow() {
        executetasknow = nil
        info.stringValue = Infoexecute().info(num: 0)
    }
}

extension ViewControllerMain: DisableEnablePopupSelectProfile {
    func enableselectpopupprofile() {
        profilepopupbutton.isEnabled = true
    }

    func disableselectpopupprofile() {
        profilepopupbutton.isEnabled = false
    }
}

extension ViewControllerMain: Sidebarbuttonactions {
    func sidebarbuttonactions(action: Sidebaractionsmessages) {
        switch action {
        case .Delete:
            delete()
        default:
            return
        }
    }
}
