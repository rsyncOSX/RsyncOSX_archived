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
    @IBOutlet weak var resetbutton: NSButton!
    @IBOutlet weak var rcloneID: NSTextField!
    @IBOutlet weak var rcloneremotecatalog: NSTextField!
    @IBOutlet weak var forceresetbutton: NSButton!

    @IBAction func forcereset(_ sender: NSButton) {
        guard self.index != nil else { return }
        if self.forceresetbutton.state == .on {
            self.resetbutton.isEnabled = true
        } else {
            self.resetbutton.isEnabled = false
        }
    }

    @IBAction func getconfig(_ sender: NSButton) {
         self.presentViewControllerAsSheet(self.viewControllerSource!)
    }

    @IBAction func connect(_ sender: NSButton) {
        guard self.index != nil else { return }
        if let rclonehiddenID = self.configurationsrclone?.gethiddenID(index: self.rcloneindex!) {
            self.configurations!.setrcloneconnection(index: self.index!, rclonehiddenID: rclonehiddenID, rcloneprofile: rcloneprofilename)
            self.updateview()
        }
    }

    @IBAction func reset(_ sender: NSButton) {
        guard self.index != nil else { return }
        self.configurations!.deletercloneconnection(index: self.index!)
        self.updateview()
        self.connectbutton.isEnabled = self.enableconnectionbutton()
        self.resetbutton.isEnabled = self.enableresetbutton()
    }

    @IBAction func selectprofile(_ sender: NSComboBox) {
        guard self.profilescombobox.indexOfSelectedItem > -1 else { return}
        self.rcloneprofilename = self.profilenamearray?[self.profilescombobox.indexOfSelectedItem]
        if self.rcloneprofilename == "Default" { self.rcloneprofilename = nil }
        self.configurationsrclone = RcloneConfigurations(profile: self.rcloneprofilename)
        self.connectbutton.isEnabled = false
        self.resetbutton.isEnabled = false
        self.updateview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcencrypt, nsviewcontroller: self)
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        let storage = RclonePersistentStorageAPI(profile: nil)
        if let userConfiguration = storage.getUserconfiguration() {
            _ = RcloneUserconfiguration(userconfigRsyncOSX: userConfiguration)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.loadprofiles()
        self.index = self.index(viewcontroller: .vctabmain)
        self.getconfig()
        self.deselect()
        self.forceresetbutton.state = .off
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    private func updateview() {
        self.getconfig()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    private func loadprofiles() {
        self.rcloneprofile = nil
        self.rcloneprofile = RcloneProfiles()
        self.profilescombobox.removeAllItems()
        self.profilescombobox.addItems(withObjectValues: self.rcloneprofile!.getDirectorysStrings())
        self.profilenamearray = self.rcloneprofile!.getDirectorysStrings()
        self.connectbutton.isEnabled = false
    }

    private func getconfig() {
        guard self.index != nil else {
            self.localCatalog.stringValue = ""
            self.offsiteCatalog.stringValue = ""
            self.offsiteUsername.stringValue = ""
            self.offsiteServer.stringValue = ""
            self.backupID.stringValue = ""
            return
        }
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        guard config.task == "backup" || config.task == "combined" else { return }
        self.localCatalog.stringValue = config.localCatalog
        self.offsiteCatalog.stringValue = config.offsiteCatalog
        self.offsiteUsername.stringValue = config.offsiteUsername
        self.offsiteServer.stringValue = config.offsiteServer
        self.backupID.stringValue = config.backupID
        guard config.rclonehiddenID != nil else {
            self.rcloneID.stringValue = ""
            self.rcloneremotecatalog.stringValue = ""
            return
        }
        guard self.rcloneprofilename ?? "" == config.rcloneprofile ?? "" && config.rclonehiddenID != nil else {
            self.rcloneID.stringValue = ""
            self.rcloneremotecatalog.stringValue = ""
            return
        }
        if let rcloneindex = self.configurationsrclone?.getIndex(config.rclonehiddenID!) {
            guard rcloneindex >= 0 else { return }
            self.rcloneID.stringValue = self.configurationsrclone!.getConfigurations()[rcloneindex].backupID
            self.rcloneremotecatalog.stringValue = self.configurationsrclone!.getConfigurations()[rcloneindex].offsiteCatalog
        }
    }

    private func enableconnectionbutton() -> Bool {
        guard self.index != nil && self.rcloneindex != nil else { return false }
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
        guard self.index != nil && self.rcloneindex != nil else { return false }
        if self.configurationsrclone!.getConfigurations()[self.rcloneindex!].hiddenID == self.configurations?.getConfigurations() [self.index!].rclonehiddenID
            && self.rcloneprofilename == self.configurations?.getConfigurations() [self.index!].rcloneprofile {
                return true
        } else {
            return false
        }
    }

    private func deselect() {
        guard self.rcloneindex != nil else { return }
        self.mainTableView.deselectRow(self.rcloneindex!)
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
        if self.rcloneindex != nil {
            self.connectbutton.isEnabled = self.enableconnectionbutton()
            self.resetbutton.isEnabled = self.enableresetbutton()
        } else {
            self.connectbutton.isEnabled = false
            self.resetbutton.isEnabled = false
        }
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
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row > self.configurationsrclone!.configurationsDataSourcecount() - 1 { return nil }
        let object: NSDictionary = self.configurationsrclone!.getConfigurationsDataSource()![row]
        let text = object[tableColumn!.identifier] as? String
        if self.index != nil {
            guard self.index! < self.configurations!.getConfigurations().count else { return nil }
            if self.configurationsrclone!.getConfigurations()[row].hiddenID == self.configurations?.getConfigurations() [self.index!].rclonehiddenID && self.rcloneprofilename == self.configurations?.getConfigurations() [self.index!].rcloneprofile {
                if tableColumn!.identifier.rawValue == "connected" {
                     return #imageLiteral(resourceName: "complete")
                }
            }
        }
        return text
    }
}

extension ViewControllerEncrypt: DismissViewController {
    // Protocol DismissViewController
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerEncrypt: GetSource {
    func getSource(index: Int) {
        self.index = index
        self.getconfig()
        self.connectbutton.isEnabled = false
        self.resetbutton.isEnabled = false
    }
}
