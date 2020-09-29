//
//  ViewControllerProfile.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

// Protocol for adding new profiles
protocol NewProfile: AnyObject {
    func newprofile(profile: String?, selectedindex: Int?)
    func reloadprofilepopupbutton()
}

class ViewControllerProfile: NSViewController, SetConfigurations, Delay {
    private var profilesArray: [String]?
    private var profile: CatalogProfile?
    private var useprofile: String?

    @IBOutlet var loadbutton: NSButton!
    @IBOutlet var newprofile: NSTextField!
    @IBOutlet var profilesTable: NSTableView!

    @IBAction func closeview(_: NSButton) {
        self.view.window?.close()
    }

    @IBAction func defaultProfile(_: NSButton) {
        _ = Selectprofile(profile: nil, selectedindex: nil)
        self.view.window?.close()
    }

    @IBAction func deleteProfile(_: NSButton) {
        if let useprofile = self.useprofile {
            self.profile?.deleteProfileDirectory(profileName: useprofile)
            _ = Selectprofile(profile: nil, selectedindex: nil)
        }
        self.view.window?.close()
    }

    // Use profile or close
    @IBAction func close(_: NSButton) {
        let newprofile = self.newprofile.stringValue
        guard newprofile.isEmpty == false else {
            if self.useprofile != nil {
                _ = Selectprofile(profile: self.useprofile, selectedindex: nil)
            }
            self.view.window?.close()
            return
        }
        let success = self.profile?.createprofilecatalog(profile: newprofile)
        guard success == true else {
            self.view.window?.close()
            return
        }
        _ = Selectprofile(profile: newprofile, selectedindex: nil)
        self.view.window?.close()
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
        self.profile = CatalogProfile()
        self.profilesArray = self.profile?.getcatalogsasstringnames()
        globalMainQueue.async { () -> Void in
            self.profilesTable.reloadData()
        }
        self.newprofile.stringValue = ""
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        _ = Selectprofile(profile: self.useprofile, selectedindex: nil)
        self.view.window?.close()
    }
}

extension ViewControllerProfile: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.profilesArray?.count ?? 0
    }
}

extension ViewControllerProfile: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "profilesID"),
                                         owner: self) as? NSTableCellView
        {
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
    func controlTextDidChange(_: Notification) {
        self.delayWithSeconds(0.5) {
            if self.newprofile.stringValue.count > 0 {
                self.loadbutton.title = NSLocalizedString("Save", comment: "Profile")
            } else {
                self.loadbutton.title = NSLocalizedString("Load", comment: "Profile")
            }
        }
    }
}
