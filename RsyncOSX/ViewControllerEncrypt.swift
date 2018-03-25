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

class ViewControllerEncrypt: NSViewController {

    private var profile: RcloneProfiles?
    private var profilename: String?
    private var profilenamearray: [String]?
    var configurationsrclone: ConfigurationsRclone?
    var index: Int?
    var hiddenID: Int?
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var profilescombobox: NSComboBox!

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
        var storage: RclonePersistentStorageAPI?
        storage = RclonePersistentStorageAPI(profile: nil)
        if let userConfiguration =  storage?.getUserconfiguration() {
            _ = RcloneUserconfiguration(userconfigRsyncOSX: userConfiguration)
        }
        self.configurationsrclone = ConfigurationsRclone(profile: self.profilename)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.loadprofiles()
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
    }

    // when row is selected
    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.hiddenID = self.configurationsrclone!.gethiddenID(index: index)
        } else {
            self.index = nil
        }
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
            return object[tableColumn!.identifier] as? Int!
        } else if tableColumn!.identifier.rawValue == "offsiteServerCellID", ((object[tableColumn!.identifier] as? String)?.isEmpty)! {
            return "localhost"
        } else {
            return object[tableColumn!.identifier] as? String
        }
    }
}
