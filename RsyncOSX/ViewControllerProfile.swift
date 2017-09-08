//
//  ViewControllerProfile.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

// Protocol for adding new profiles
protocol AddProfiles : class {
    func newProfile(new: Bool, profile: String?)
    func enableProfileMenu()
}

class ViewControllerProfile: NSViewController {

    var storageapi: PersistentStorageAPI?
    weak var dismissDelegate: DismissViewController?
    weak var newProfileDelegate: AddProfiles?
    fileprivate var profilesArray: [String]?
    private var profile: Profiles?
    fileprivate var useprofile: String?

    @IBOutlet weak var newprofile: NSTextField!
    @IBOutlet weak var profilesTable: NSTableView!

    // Setting default profile
    @IBAction func defaultProfile(_ sender: NSButton) {
        self.newProfileDelegate?.newProfile( new: false, profile: nil)
        self.useprofile = nil
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Add and load new profile
    @IBAction func addProfile(_ sender: NSButton) {
        let newprofile = self.newprofile.stringValue
        if newprofile.isEmpty == false {
            // Create new profile and use it
            self.profile?.createProfile(profileName: newprofile)
            // Destroy old configuration and save default configuration
            // New Configurations must be saved as empty Configurations
            self.storageapi = PersistentStorageAPI(profile : nil)
            self.storageapi!.saveConfigFromMemory()
            self.newProfileDelegate?.newProfile(new: true, profile: newprofile)
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
            self.newProfileDelegate?.newProfile(new: false, profile: nil)
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
            self.newProfileDelegate?.newProfile(new: false, profile: useprofile)
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
        self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.profile = Profiles()
        self.profilesArray = self.profile!.getDirectorysStrings()
        self.profilesTable.target = self
        self.profilesTable.doubleAction = #selector(ViewControllerProfile.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.newProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        globalMainQueue.async(execute: { () -> Void in
            self.profilesTable.reloadData()
        })
        self.newprofile.stringValue = ""
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        self.newProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        if let useprofile = self.useprofile {
            self.newProfileDelegate?.newProfile(new: false, profile: useprofile)
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
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier),
                         owner: self) as? NSTableCellView {
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
