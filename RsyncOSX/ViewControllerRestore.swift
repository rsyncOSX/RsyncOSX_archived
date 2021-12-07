//
//  ViewControllerRestore.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length type_body_length

import Cocoa
import Foundation

protocol Updateremotefilelist: AnyObject {
    func updateremotefilelist()
}

class ViewControllerRestore: NSViewController, SetConfigurations, Delay, Connected, VcMain, Checkforrsync, Setcolor, Help {
    var restorefilestask: RestorefilesTask?
    var fullrestoretask: FullrestoreTask?
    var remotefilelist: Remotefilelist?
    var index: Int?
    var restoretabledata: [String]?
    var diddissappear: Bool = false
    var outputprocess: OutputfromProcess?
    var maxcount: Int = 0
    weak var outputeverythingDelegate: ViewOutputDetails?
    var restoreactions: RestoreActions?
    // Send messages to the sidebar
    weak var sidebaractionsDelegate: Sidebaractions?
    var configurations: Estimatedlistforsynchronization?

    @IBOutlet var restoretableView: NSTableView!
    @IBOutlet var rsynctableView: NSTableView!
    @IBOutlet var remotefiles: NSTextField!
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var search: NSSearchField!
    @IBOutlet var checkedforfullrestore: NSButton!
    @IBOutlet var tmprestorepath: NSTextField!
    @IBOutlet var profilepopupbutton: NSPopUpButton!
    @IBOutlet var infolabel: NSTextField!

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        presentAsModalWindow(viewControllerProfile!)
    }

    // Abort button
    @IBAction func abort(_: NSButton) {
        working.stopAnimation(nil)
        _ = InterruptProcess()
        reset()
    }

    @IBAction func showHelp(_: AnyObject?) {
        help()
    }

    @IBAction func doareset(_: NSButton) {
        reset()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurations = Estimatedlistforsynchronization()
        SharedReference.shared.setvcref(viewcontroller: .vcrestore, nsviewcontroller: self)
        outputeverythingDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        restoretableView.delegate = self
        restoretableView.dataSource = self
        rsynctableView.delegate = self
        rsynctableView.dataSource = self
        working.usesThreadedAnimation = true
        search.delegate = self
        tmprestorepath.delegate = self
        remotefiles.delegate = self
        restoretableView.doubleAction = #selector(tableViewDoubleClick(sender:))
        initpopupbutton()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        sidebaractionsDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        sidebaractionsDelegate?.sidebaractions(action: .restoreviewbuttons)
        guard diddissappear == false else {
            globalMainQueue.async { () in
                self.rsynctableView.reloadData()
            }
            return
        }
        globalMainQueue.async { () in
            self.rsynctableView.reloadData()
        }
        reset()
        settmprestorepathfromuserconfig()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        diddissappear = true
    }

    func reset() {
        restoretabledata = nil
        restorefilestask = nil
        fullrestoretask = nil
        // Restore state
        restoreactions = RestoreActions(closure: verifytmprestorepath)
        if index != nil {
            restoreactions?.index = true
        }
        restoretabledata = nil
        globalMainQueue.async { () in
            self.restoretableView.reloadData()
            self.rsynctableView.reloadData()
        }
    }

    // Restore files
    func executerestorefiles() {
        guard restoreactions?.goforrestorefilestotemporarypath() ?? false else { return }
        guard restorefilestask != nil else { return }
        restorefilestask?.executecopyfiles(remotefile: remotefiles.stringValue, localCatalog: tmprestorepath.stringValue, dryrun: false)
        outputprocess = restorefilestask?.outputprocess
        globalMainQueue.async { () in
            self.presentAsSheet(self.viewControllerProgress!)
        }
    }

    func prepareforfilesrestoreandandgetremotefilelist() {
        guard checkforgetremotefiles() else { return }
        if let index = index {
            infolabel.isHidden = true
            remotefiles.stringValue = ""
            let hiddenID = Estimatedlistforsynchronization().getConfigurationsDataSourceSynchronize()?[index].value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int ?? -1
            if Estimatedlistforsynchronization().getConfigurationsDataSourceSynchronize()?[index].value(forKey: DictionaryStrings.taskCellID.rawValue) as? String ?? "" != SharedReference.shared.snapshot {
                restorefilestask = RestorefilesTask(hiddenID: hiddenID, processtermination: processtermination, filehandler: filehandler)
                remotefilelist = Remotefilelist(hiddenID: hiddenID)
                working.startAnimation(nil)
            } else {
                let question: String = NSLocalizedString("Filelist for snapshot tasks might be huge?", comment: "Restore")
                let text: String = NSLocalizedString("Start getting files?", comment: "Restore")
                let dialog: String = NSLocalizedString("Start", comment: "Restore")
                let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
                if answer {
                    restorefilestask = RestorefilesTask(hiddenID: hiddenID, processtermination: processtermination, filehandler: filehandler)
                    remotefilelist = Remotefilelist(hiddenID: hiddenID)
                    working.startAnimation(nil)
                } else {
                    reset()
                }
            }
        }
    }

    func checkforgetremotefiles() -> Bool {
        guard checkforrsync() == false else { return false }
        if let index = index {
            guard connected(config: configurations?.getConfigurations()?[index]) == true else {
                infolabel.stringValue = Inforestore().info(num: 4)
                infolabel.isHidden = false
                return false
            }
            guard configurations!.getConfigurations()?[index].task != SharedReference.shared.syncremote else {
                infolabel.stringValue = Inforestore().info(num: 5)
                infolabel.isHidden = false
                restoretabledata = nil
                globalMainQueue.async { () in
                    self.restoretableView.reloadData()
                }
                return false
            }
            return true
        } else {
            return false
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == restoretableView {
            infolabel.isHidden = true
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                guard restoretabledata != nil else { return }
                remotefiles.stringValue = restoretabledata![index]
                guard remotefiles.stringValue.isEmpty == false else {
                    infolabel.stringValue = Inforestore().info(num: 3)
                    reset()
                    return
                }
                restoreactions?.index = true
                restoreactions?.remotefileverified = true
            }
        } else {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            checkedforfullrestore.state = .off
            if let index = indexes.first {
                self.index = index
                restoretabledata = nil
                restoreactions?.index = true
                guard restoreactions?.reset() == false else {
                    reset()
                    return
                }
            } else {
                index = nil
                reset()
            }
            globalMainQueue.async { () in
                self.restoretableView.reloadData()
            }
        }
    }

    // Sidebar filelist
    func getremotefilelist() {
        guard restoreactions?.getfilelistrestorefiles() ?? false else { return }
        prepareforfilesrestoreandandgetremotefilelist()
    }

    // Sidebar reset
    func resetaction() {
        reset()
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        guard remotefiles.stringValue.isEmpty == false else { return }
        guard verifytmprestorepath() == true else { return }
        let question: String = NSLocalizedString("Copy single files or directory?", comment: "Restore")
        let text: String = NSLocalizedString("Start restore?", comment: "Restore")
        let dialog: String = NSLocalizedString("Restore", comment: "Restore")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
        if answer {
            working.startAnimation(nil)
            restorefilestask?.executecopyfiles(remotefile: remotefiles?.stringValue ?? "", localCatalog: tmprestorepath?.stringValue ?? "", dryrun: false)
        }
    }

    private func checkforfullrestore() -> Bool {
        if let index = index {
            guard connected(config: configurations!.getConfigurations()?[index]) == true else {
                infolabel.stringValue = Inforestore().info(num: 4)
                infolabel.isHidden = false
                return false
            }
            guard configurations?.getConfigurations()?[index].task != SharedReference.shared.syncremote else {
                infolabel.stringValue = Inforestore().info(num: 5)
                infolabel.isHidden = false
                return false
            }
        }
        return true
    }

    func executefullrestore() {
        let question: String = NSLocalizedString("Do you REALLY want to start a restore?", comment: "Restore")
        let text: String = NSLocalizedString("Cancel or Restore", comment: "Restore")
        let dialog: String = NSLocalizedString("Restore", comment: "Restore")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
        if answer {
            if let index = index {
                let gotit: String = NSLocalizedString("Executing restore...", comment: "Restore")
                infolabel.stringValue = gotit
                infolabel.isHidden = false
                globalMainQueue.async { () in
                    self.presentAsSheet(self.viewControllerProgress!)
                }
                fullrestoretask = FullrestoreTask(dryrun: false, processtermination: processtermination, filehandler: filehandler)
                fullrestoretask?.executerestore(index: index)
                outputprocess = fullrestoretask?.outputprocess
            }
        }
    }

    func settmprestorepathfromuserconfig() {
        let setuserconfig: String = NSLocalizedString(" ... set in User configuration ...", comment: "Restore")
        tmprestorepath.stringValue = SharedReference.shared.temporarypathforrestore ?? setuserconfig
        if (SharedReference.shared.temporarypathforrestore ?? "").isEmpty == true {
            restoreactions?.tmprestorepathselected = false
        } else {
            restoreactions?.tmprestorepathselected = true
        }
        restoreactions?.tmprestorepathverified = verifytmprestorepath()
    }

    func verifytmprestorepath() -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: tmprestorepath.stringValue) == false {
            infolabel.stringValue = Inforestore().info(num: 1)
            return false
        } else {
            infolabel.isHidden = true
            return true
        }
    }

    func goforrestorebyfile() {
        restoreactions?.restorefiles = true
        restoreactions?.fullrestore = false
        globalMainQueue.async { () in
            self.restoretableView.reloadData()
        }
    }

    func goforfullrestore() {
        restoretabledata = nil
        restoreactions?.fullrestore = true
        restoreactions?.restorefiles = false
        restoreactions?.tmprestorepathselected = true
        globalMainQueue.async { () in
            self.restoretableView.reloadData()
        }
    }

    // Sidebar restore
    func restore() {
        if checkedforfullrestore.state == .on {
            if restoreactions?.goforfullrestoretotemporarypath() == true {
                executefullrestore()
            }
        } else {
            if restoreactions?.goforrestorefilestotemporarypath() == true {
                executerestorefiles()
            }
        }
    }

    // Sidebar estimate
    func estimate() {
        guard checkforrsync() == false else { return }
        if restoreactions?.goforfullrestoreestimatetemporarypath() ?? false {
            guard checkforfullrestore() == true else { return }
            if let index = index {
                let gotit: String = NSLocalizedString("Getting info, please wait...", comment: "Restore")
                infolabel.stringValue = gotit
                infolabel.isHidden = false
                working.startAnimation(nil)
                if restoreactions?.goforfullrestoreestimatetemporarypath() ?? false {
                    fullrestoretask = FullrestoreTask(dryrun: true, processtermination: processtermination, filehandler: filehandler)
                    fullrestoretask?.executerestore(index: index)
                    outputprocess = fullrestoretask?.outputprocess
                }
            }
        } else {
            guard restoreactions?.remotefileverified ?? false else { return }
            working.startAnimation(nil)
            restorefilestask?.executecopyfiles(remotefile: remotefiles!.stringValue, localCatalog: tmprestorepath!.stringValue, dryrun: true)
            outputprocess = restorefilestask?.outputprocess
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
        _ = Selectprofile(profile: profile, selectedindex: selectedindex)
        reset()
    }
}
