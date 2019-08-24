//
//  ViewControllerProfile.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

// Protocol for adding new profiles
protocol NewProfile: class {
    func newProfile(profile: String?)
    func enableProfileMenu()
}

class ViewControllerProfile: NSViewController, SetConfigurations, SetDismisser, Delay {

    var storageapi: PersistentStorageAPI?
    private var profilesArray: [String]?
    private var profile: CatalogProfile?
    private var useprofile: String?

    @IBOutlet weak var loadbutton: NSButton!
    @IBOutlet weak var newprofile: NSTextField!
    @IBOutlet weak var profilesTable: NSTableView!

    @IBAction func defaultProfile(_ sender: NSButton) {
        _ = Selectprofile(profile: nil)
        self.closeview()
    }

    @IBAction func deleteProfile(_ sender: NSButton) {
        if let useprofile = self.useprofile {
            self.profile?.deleteProfileDirectory(profileName: useprofile)
            _ = Selectprofile(profile: nil)
        }
        self.closeview()
    }

    // Use profile or close
    @IBAction func close(_ sender: NSButton) {
        let newprofile = self.newprofile.stringValue
        guard newprofile.isEmpty == false else {
            if self.useprofile != nil {
                _ = Selectprofile(profile: self.useprofile)
            }
            self.closeview()
            return
        }
        let success = self.profile?.createProfileDirectory(profileName: newprofile)
        guard success == true else {
            self.closeview()
            return
        }
        _ = Selectprofile(profile: newprofile)
        self.closeview()
    }

    private func closeview() {
        if (self.presentingViewController as? ViewControllertabMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presentingViewController as? ViewControllertabSchedule) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabschedule)
        } else if (self.presentingViewController as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcnewconfigurations)
        } else if (self.presentingViewController as? ViewControllerCopyFiles) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        } else if (self.presentingViewController as? ViewControllerSnapshots) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        } else if (self.presentingViewController as? ViewControllerSsh) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcssh)
        } else if (self.presentingViewController as? ViewControllerVerify) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcverify)
        } else if (self.presentingViewController as? ViewControllerLoggData) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilesTable.delegate = self
        self.profilesTable.dataSource = self
        self.profilesTable.target = self
        self.newprofile.delegate = self
        self.profilesTable.doubleAction = #selector(ViewControllerProfile.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.profile = nil
        self.profile = CatalogProfile()
        self.profilesArray = self.profile!.getDirectorysStrings()
        globalMainQueue.async(execute: { () -> Void in
            self.profilesTable.reloadData()
        })
        self.newprofile.stringValue = ""
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        _ = Selectprofile(profile: self.useprofile)
        self.closeview()
    }
}

extension ViewControllerProfile: NSTableViewDataSource {

    func numberOfRows(in tableViewMaster: NSTableView) -> Int {
        return self.profilesArray?.count ?? 0
    }
}

extension ViewControllerProfile: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "profilesID"),
                                         owner: self) as? NSTableCellView {
            cell.textField?.stringValue = self.profilesArray?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.useprofile = self.profilesArray![index]
        }
    }
}

extension ViewControllerProfile: NSTextFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        self.delayWithSeconds(0.5) {
            if self.newprofile.stringValue.count > 0 {
                self.loadbutton.title = NSLocalizedString("Save", comment: "Profile")
            } else {
                self.loadbutton.title = NSLocalizedString("Load", comment: "Profile")
            }
        }
    }
}
