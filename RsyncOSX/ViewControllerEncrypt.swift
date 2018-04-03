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

class ViewControllerEncrypt: NSViewController, GetIndex, SetConfigurations {

    private var profile: RcloneProfiles?
    private var profilename: String?
    private var profilenamearray: [String]?
    var configurationsrclone: ConfigurationsRclone?
    var rcloneindex: Int?
    var index: Int?
    var hiddenID: Int?

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var profilescombobox: NSComboBox!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var connectbutton: NSButton!

    @IBAction func connect(_ sender: NSButton) {
    }

    @IBAction func selectprofile(_ sender: NSComboBox) {
        guard self.profilescombobox.indexOfSelectedItem > -1 else { return}
        self.profilename = self.profilenamearray?[self.profilescombobox.indexOfSelectedItem]
        if self.profilename == "Default" { self.profilename = nil }
        self.configurationsrclone = ConfigurationsRclone(profile: self.profilename)
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        let storage = RclonePersistentStorageAPI(profile: nil)
        if let userConfiguration = storage.getUserconfiguration() {
            _ = RcloneUserconfiguration(userconfigRsyncOSX: userConfiguration)
        }
        self.configurationsrclone = ConfigurationsRclone(profile: self.profilename)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.loadprofiles()
        self.index = self.index(viewcontroller: .vctabmain)
        self.getconfig()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    private func loadprofiles() {
        self.profile = nil
        self.profile = RcloneProfiles()
        self.profilescombobox.removeAllItems()
        self.profilescombobox.addItems(withObjectValues: self.profile!.getDirectorysStrings())
        self.profilenamearray = self.profile!.getDirectorysStrings()
        self.connectbutton.isEnabled = false
    }

    private func getconfig() {
        guard self.index != nil else { return }
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        self.localCatalog.stringValue = config.localCatalog
        self.offsiteCatalog.stringValue = config.offsiteCatalog
        self.offsiteUsername.stringValue = config.offsiteUsername
        self.offsiteServer.stringValue = config.offsiteServer
        self.backupID.stringValue = config.backupID
    }

    private func checkconnection() {
        guard self.index != nil && self.rcloneindex != nil else {
            self.connectbutton.isEnabled = false
            return
        }
        let rclonehiddenID = self.configurationsrclone!.gethiddenID(index: self.rcloneindex!)
        let rcloneremotecatalog = self.configurationsrclone!.getResourceConfiguration(rclonehiddenID, resource: .remoteCatalog) + "/"
        let rsynclocalcatalog = self.localCatalog.stringValue
        if rcloneremotecatalog == rsynclocalcatalog {
            self.connectbutton.isEnabled = true
        } else {
            self.connectbutton.isEnabled = false
        }
    }

    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.rcloneindex = index
            self.hiddenID = self.configurationsrclone!.gethiddenID(index: index)
        } else {
            self.rcloneindex = nil
        }
        self.checkconnection()
    }
}

extension ViewControllerEncrypt: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configurationsrclone?.configurationsDataSourcecount() ?? 0
    }
}

extension ViewControllerEncrypt: NSTableViewDelegate {
    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row > self.configurationsrclone!.configurationsDataSourcecount() - 1 { return nil }
        let object: NSDictionary = self.configurationsrclone!.getConfigurationsDataSource()![row]
        if tableColumn!.identifier.rawValue == "batchCellID" {
            return object[tableColumn!.identifier]
        } else if tableColumn!.identifier.rawValue == "offsiteServerCellID", ((object[tableColumn!.identifier] as? String)?.isEmpty)! {
            return "localhost"
        } else {
            return object[tableColumn!.identifier] as? String
        }
    }
}
