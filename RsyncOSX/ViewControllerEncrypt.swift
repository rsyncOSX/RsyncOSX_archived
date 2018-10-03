//
//  ViewControllerEncrypt.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

import Cocoa

class ViewControllerEncrypt: NSViewController, GetIndex, SetConfigurations, VcCopyFiles {

    private var rcloneprofile: RcloneProfiles?
    private var rcloneprofilename: String?
    private var profilenamearray: [String]?
    var configurationsrclone: RcloneConfigurations?
    var rcloneindex: Int?
    var rsyncindex: Int?
    var hiddenID: Int?
    var diddissappear: Bool = false

    @IBOutlet weak var rcloneTableView: NSTableView!
    @IBOutlet weak var rsyncTableView: NSTableView!
    @IBOutlet weak var profilescombobox: NSComboBox!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var connectbutton: NSButton!
    @IBOutlet weak var resetbutton: NSButton!
    @IBOutlet weak var rcloneID: NSTextField!
    @IBOutlet weak var rcloneremotecatalog: NSTextField!
    @IBOutlet weak var forceresetbutton: NSButton!

    @IBAction func forcereset(_ sender: NSButton) {
        guard self.rsyncindex != nil else { return }
        if self.forceresetbutton.state == .on {
            self.resetbutton.isEnabled = true
        } else {
            self.resetbutton.isEnabled = false
        }
    }

    @IBAction func connect(_ sender: NSButton) {
        guard self.rsyncindex != nil else { return }
        if let rclonehiddenID = self.configurationsrclone?.gethiddenID(index: self.rcloneindex!) {
            self.configurations!.setrcloneconnection(index: self.rsyncindex!, rclonehiddenID: rclonehiddenID, rcloneprofile: rcloneprofilename)
            self.updateview()
        }
    }

    @IBAction func reset(_ sender: NSButton) {
        guard self.rsyncindex != nil else { return }
        self.configurations!.deletercloneconnection(index: self.rsyncindex!)
        self.updateview()
        self.connectbutton.isEnabled = self.enableconnectionbutton()
        self.resetbutton.isEnabled = self.enableresetbutton()
    }

    @IBAction func selectprofile(_ sender: NSComboBox) {
        guard self.profilescombobox.indexOfSelectedItem > -1 else { return}
        self.rcloneprofilename = self.profilenamearray?[self.profilescombobox.indexOfSelectedItem]
        if self.rcloneprofilename == "Default profile" { self.rcloneprofilename = nil }
        self.configurationsrclone = RcloneConfigurations(profile: self.rcloneprofilename)
        self.connectbutton.isEnabled = false
        self.resetbutton.isEnabled = false
        self.updateview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcencrypt, nsviewcontroller: self)
        self.rcloneTableView.delegate = self
        self.rcloneTableView.dataSource = self
        self.rsyncTableView.delegate = self
        self.rsyncTableView.dataSource = self
        let storage = RclonePersistentStorageAPI(profile: nil)
        if let userConfiguration = storage.getUserconfiguration() {
            _ = RcloneUserconfiguration(userconfigRsyncOSX: userConfiguration)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else { return }
        self.loadprofiles()
        self.deselect()
        self.forceresetbutton.state = .off
        globalMainQueue.async(execute: { () -> Void in
            self.rsyncTableView.reloadData()
        })
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func updateview() {
        self.selectindexrcloneosx()
        globalMainQueue.async(execute: { () -> Void in
            self.rcloneTableView.reloadData()
        })
    }

    private func loadprofiles() {
        self.rcloneprofile = RcloneProfiles()
        self.profilescombobox.removeAllItems()
        self.profilescombobox.addItems(withObjectValues: self.rcloneprofile!.getDirectorysStrings())
        self.profilescombobox.addItem(withObjectValue: "Default profile")
        self.profilenamearray = self.rcloneprofile!.getDirectorysStrings()
        self.profilenamearray?.append("Default profile")
        self.connectbutton.isEnabled = false
    }

    private func selectindexrsyncosx() {
        guard self.rsyncindex != nil else {
            self.localCatalog.stringValue = ""
            self.offsiteCatalog.stringValue = ""
            self.offsiteUsername.stringValue = ""
            self.offsiteServer.stringValue = ""
            self.backupID.stringValue = ""
            return
        }
        let rsyncconfig: Configuration = self.configurations!.getConfigurations()[self.rsyncindex!]
        guard rsyncconfig.task == "backup" || rsyncconfig.task == "combined" else { return }
        self.localCatalog.stringValue = rsyncconfig.localCatalog
        self.offsiteCatalog.stringValue = rsyncconfig.offsiteCatalog
        self.offsiteUsername.stringValue = rsyncconfig.offsiteUsername
        self.offsiteServer.stringValue = rsyncconfig.offsiteServer
        self.backupID.stringValue = rsyncconfig.backupID
    }

    private func selectindexrcloneosx() {
        guard self.rsyncindex != nil else { return }
        let rsyncconfig: Configuration = self.configurations!.getConfigurations()[self.rsyncindex!]
        guard rsyncconfig.rclonehiddenID != nil else {
            self.rcloneID.stringValue = ""
            self.rcloneremotecatalog.stringValue = ""
            return
        }
        guard self.rcloneprofilename ?? "" == rsyncconfig.rcloneprofile ?? "" && rsyncconfig.rclonehiddenID != nil else {
            self.rcloneID.stringValue = ""
            self.rcloneremotecatalog.stringValue = ""
            return
        }
        if let rcloneindex = self.configurationsrclone?.getIndex(rsyncconfig.rclonehiddenID!) {
            guard rcloneindex >= 0 else { return }
            self.rcloneID.stringValue = self.configurationsrclone!.getConfigurations()[rcloneindex].backupID
            self.rcloneremotecatalog.stringValue = self.configurationsrclone!.getConfigurations()[rcloneindex].offsiteCatalog
        }
    }

    private func enableconnectionbutton() -> Bool {
        guard self.rsyncindex != nil && self.rcloneindex != nil else { return false }
        let rclonehiddenID = self.configurationsrclone!.gethiddenID(index: self.rcloneindex!)
        let rcloneremotecatalog = self.configurationsrclone!.getResourceConfiguration(rclonehiddenID, resource: .remoteCatalog) + "/"
        let rsynclocalcatalog = self.localCatalog.stringValue
        if rcloneremotecatalog == rsynclocalcatalog {
            return true
        } else {
            return false
        }
    }

    private func enableresetbutton() -> Bool {
        guard self.forceresetbutton.state == .off else { return true }
        guard self.rsyncindex != nil && self.rcloneindex != nil else { return false }
        if self.configurationsrclone!.getConfigurations()[self.rcloneindex!].hiddenID == self.configurations?.getConfigurations() [self.rsyncindex!].rclonehiddenID
            && self.rcloneprofilename == self.configurations?.getConfigurations() [self.rsyncindex!].rcloneprofile {
            return true
        } else {
            return false
        }
    }

    private func deselect() {
        guard self.rcloneindex != nil else { return }
        self.rcloneTableView.deselectRow(self.rcloneindex!)
    }

    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == self.rcloneTableView {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                self.rcloneindex = index
                self.selectindexrcloneosx()
                self.hiddenID = self.configurationsrclone!.gethiddenID(index: index)
            } else {
                self.rcloneindex = nil
            }
            if self.rcloneindex != nil {
                self.connectbutton.isEnabled = self.enableconnectionbutton()
                self.resetbutton.isEnabled = self.enableresetbutton()
            } else {
                self.connectbutton.isEnabled = false
                self.resetbutton.isEnabled = false
            }
            globalMainQueue.async(execute: { () -> Void in
                self.rcloneTableView.reloadData()
            })
        } else {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                self.rsyncindex = index
                self.selectindexrsyncosx()
                globalMainQueue.async(execute: { () -> Void in
                    self.rcloneTableView.reloadData()
                })
            } else {
                self.rsyncindex = nil
            }
        }
    }
}

extension ViewControllerEncrypt: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.rcloneTableView {
            return self.configurationsrclone?.configurationsDataSourcecount() ?? 0
        } else {
            return self.configurations?.getConfigurationsDataSourcecountBackupCombined()?.count ?? 0
        }
    }
}

extension ViewControllerEncrypt: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == self.rcloneTableView {
            guard row < self.configurationsrclone!.configurationsDataSourcecount() else { return nil }
            let object: NSDictionary = self.configurationsrclone!.getConfigurationsDataSource()![row]
            if self.rsyncindex != nil {
                guard self.rsyncindex! < self.configurations!.getConfigurations().count else { return nil }
                if self.configurationsrclone!.getConfigurations()[row].hiddenID == self.configurations?.getConfigurations() [self.rsyncindex!].rclonehiddenID && self.rcloneprofilename == self.configurations?.getConfigurations() [self.rsyncindex!].rcloneprofile {
                    if tableColumn!.identifier.rawValue == "connected" { return #imageLiteral(resourceName: "complete") }
                }
            }
            return object[tableColumn!.identifier] as? String
        } else {
            guard row < self.configurations!.getConfigurationsDataSourcecountBackupCombined()!.count else { return nil }
            let object: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackupCombined()![row]
            return object[tableColumn!.identifier] as? String
        }
    }
}
