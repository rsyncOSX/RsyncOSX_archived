//
//  ViewControllerProfile.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar file_length cyclomatic_complexity line_length

import Foundation
import Cocoa

// Protocol for adding new profiles
protocol AddProfiles : class {
    func newProfile(new: Bool)
    func enableProfileMenu()
}

class ViewControllerProfile: NSViewController {

    // Dismisser
    weak var dismissDelegate: DismissViewController?
    // new Profile
    weak var newProfileDelegate: AddProfiles?
    // Array to display in tableview
    fileprivate var profilesArray: [String]?
    // The profiles object
    private var profile: Profiles?
    // Selecet profile to use
    fileprivate var useprofile: String?
    // New profile
    @IBOutlet weak var newprofile: NSTextField!

    // Table to show profiles
    @IBOutlet weak var profilesTable: NSTableView!

    // Setting default profile
    @IBAction func defaultProfile(_ sender: NSButton) {
        Configurations.shared.setProfile(profile: nil)
        self.newProfileDelegate?.newProfile( new: false)
        self.useprofile = nil
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Add and load new profile
    @IBAction func addProfile(_ sender: NSButton) {
        let newprofile = self.newprofile.stringValue
        if newprofile.isEmpty == false {
            // Create new profile and use it
            self.profile?.createProfile(profileName: newprofile)
            Configurations.shared.setProfile(profile: newprofile)
            // Destroy old configuration and save default configuration
            // New Configurations must be saved as empty Configurations
            Configurations.shared.destroyConfigurations()
            PersistentStoreageAPI.shared.saveConfigFromMemory()
            self.newProfileDelegate?.newProfile(new: true)
        }
        self.profile = nil
        self.profile = Profiles()
        self.profilesArray = self.profile!.getDirectorysStrings()
        self.useprofile = nil
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Delete profile
    @IBAction func deleteProfile(_ sender: NSButton) {
        if let useprofile = self.useprofile {
            self.profile?.deleteProfile(profileName: useprofile)
            Configurations.shared.setProfile(profile: nil)
            self.newProfileDelegate?.newProfile(new: false)
        }
        self.profile = nil
        self.profile = Profiles()
        self.profilesArray = self.profile!.getDirectorysStrings()
        self.useprofile = nil
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Use profile or close
    @IBAction func close(_ sender: NSButton) {
        if let useprofile = self.useprofile {
            Configurations.shared.setProfile(profile: useprofile)
            self.newProfileDelegate?.newProfile(new: false)
        }
        self.useprofile = nil
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Table delegates
        self.profilesTable.delegate = self
        self.profilesTable.dataSource = self
        // Dismisser is root controller
        if let pvc = self.presenting as? ViewControllertabMain {
            self.dismissDelegate = pvc
        }
        self.profile = Profiles()
        self.profilesArray = self.profile!.getDirectorysStrings()
        self.profilesTable.target = self
        self.profilesTable.doubleAction = #selector(ViewControllerProfile.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let pvc = self.presenting as? ViewControllertabMain {
            self.newProfileDelegate = pvc
        }
        globalMainQueue.async(execute: { () -> Void in
            self.profilesTable.reloadData()
        })
        self.newprofile.stringValue = ""
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        if let pvc = self.presenting as? ViewControllertabMain {
            self.newProfileDelegate = pvc
        }
        if let useprofile = self.useprofile {
            Configurations.shared.setProfile(profile: useprofile)
            self.newProfileDelegate?.newProfile(new: false)
        }
        self.useprofile = nil
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }
}

extension ViewControllerProfile : NSTableViewDataSource {

    func numberOfRows(in tableViewMaster: NSTableView) -> Int {
        if self.profilesArray != nil {
            return self.profilesArray!.count
        } else {
            return 0
        }
    }
}

extension ViewControllerProfile : NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String?
        var cellIdentifier: String = ""
        let data = self.profilesArray![row]
        if tableColumn == tableView.tableColumns[0] {
            text = data
            cellIdentifier = "profilesID"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text!
            return cell
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.useprofile = self.profilesArray![index]
        }
    }

}
