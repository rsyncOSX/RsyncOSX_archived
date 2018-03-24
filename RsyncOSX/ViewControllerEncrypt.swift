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

    private var profilesArray: [String]?
    private var profile: RcloneProfiles?
    private var useprofile: String?
    var configurationsrclone: ConfigurationsRclone?
    @IBOutlet weak var mainTableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        var storage: RclonePersistentStorageAPI?
        storage = RclonePersistentStorageAPI(profile: nil)
        if let userConfiguration =  storage?.getUserconfiguration() {
            _ = RcloneUserconfiguration(userconfigRsyncOSX: userConfiguration)
        }
        self.configurationsrclone = ConfigurationsRclone(profile: nil)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.profile = nil
        self.profile = RcloneProfiles()
        self.profilesArray = self.profile!.getDirectorysStrings()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
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
