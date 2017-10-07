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
protocol NewProfile: class {
    func newProfile(profile: String?)
    func enableProfileMenu()
}

class ViewControllerProfile: NSViewController {

    weak var configurationsDelegate: GetConfigurationsObject?
    var configurations: Configurations?

    var storageapi: PersistentStorageAPI?
    weak var dismissDelegate: DismissViewController?
    weak var newProfileDelegate: NewProfile?
    private var profilesArray: [String]?
    private var profile: Profiles?
    private var useprofile: String?

    @IBOutlet weak var newprofile: NSTextField!
    @IBOutlet weak var profilesTable: NSTableView!

    // Setting default profile
    @IBAction func defaultProfile(_ sender: NSButton) {
        self.useprofile = nil
        self.newProfileDelegate?.newProfile(profile: self.useprofile)
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Add and load new profile
    @IBAction func addProfile(_ sender: NSButton) {
        let newprofile = self.newprofile.stringValue
        guard newprofile.isEmpty == false else {
            self.dismissDelegate?.dismiss_view(viewcontroller: self)
            return
        }
        let success = self.profile?.createProfile(profileName: newprofile)
        guard success == true else {
            self.dismissDelegate?.dismiss_view(viewcontroller: self)
            return
        }
        self.newProfileDelegate?.newProfile(profile: newprofile)
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Delete profile
    @IBAction func deleteProfile(_ sender: NSButton) {
        if let useprofile = self.useprofile {
            self.profile?.deleteProfile(profileName: useprofile)
            self.newProfileDelegate?.newProfile(profile: nil)
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Use profile or close
    @IBAction func close(_ sender: NSButton) {
        self.newProfileDelegate?.newProfile(profile: self.useprofile)
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.profilesTable.delegate = self
        self.profilesTable.dataSource = self
        self.profilesTable.target = self
        self.profilesTable.doubleAction = #selector(ViewControllerProfile.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.configurations = self.configurationsDelegate?.getconfigurationsobject()
        self.profile = nil
        self.profile = Profiles()
        self.profilesArray = self.profile!.getDirectorysStrings()
        self.newProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        // Decide which viewcontroller calling the view
        if self.configurations!.allowNotifyinMain == true {
            self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        } else {
            self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
        }
        globalMainQueue.async(execute: { () -> Void in
            self.profilesTable.reloadData()
        })
        self.newprofile.stringValue = ""
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        self.newProfileDelegate?.newProfile(profile: self.useprofile)
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }
}

extension ViewControllerProfile: NSTableViewDataSource {

    func numberOfRows(in tableViewMaster: NSTableView) -> Int {
        if self.profilesArray != nil {
            return self.profilesArray!.count
        } else {
            return 0
        }
    }
}

extension ViewControllerProfile: NSTableViewDelegate {

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
