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
protocol AddProfiles : class {
    func newProfile()
    func enableProfileMenu()
}


class ViewControllerProfile : NSViewController {

    // Dismisser
    weak var dismiss_delegate:DismissViewController?
    // new Profile
    weak var newProfile_delegate:AddProfiles?
    // Array to display in tableview
    fileprivate var profilesArray:[String]?
    // The profiles object
    private var profile:profiles?
    // Selecet profile to use
    fileprivate var useprofile:String?
    // New profile
    @IBOutlet weak var newprofile: NSTextField!
    
    // Radiobuttons
    @IBOutlet weak var delete: NSButton!
    @IBOutlet weak var new: NSButton!
    // Table to show profiles
    @IBOutlet weak var profilesTable: NSTableView!
    
    // Setting default profile
    @IBAction func defaultProfile(_ sender: NSButton) {
        SharingManagerConfiguration.sharedInstance.setProfile(profile: nil)
        self.newProfile_delegate?.newProfile()
        self.useprofile = nil
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    @IBAction func radioButtons(_ sender: NSButton) {
        // Only for grouping radio buttons
    }
    
    @IBAction func close(_ sender: NSButton) {
        if let pvc = self.presenting as? ViewControllertabMain {
            self.newProfile_delegate = pvc
        }
        if (self.delete.state == 1) {
            if let useprofile = self.useprofile {
                self.profile?.deleteProfile(profileName: useprofile)
                SharingManagerConfiguration.sharedInstance.setProfile(profile: nil)
                self.newProfile_delegate?.newProfile()
            }
            self.profile = nil
            self.profile = profiles(path: nil)
            self.profilesArray = self.profile!.getDirectorysStrings()
            self.useprofile = nil
            self.dismiss_delegate?.dismiss_view(viewcontroller: self)
            
        } else if (self.new.state == 1) {
            let newprofile = self.newprofile.stringValue
            if (newprofile.isEmpty == false) {
                // Create new profile and use it
                self.profile?.createProfile(profileName: newprofile)
                SharingManagerConfiguration.sharedInstance.setProfile(profile: newprofile)
                self.newProfile_delegate?.newProfile()
            }
            self.profile = nil
            self.profile = profiles(path: nil)
            self.profilesArray = self.profile!.getDirectorysStrings()
            self.useprofile = nil
            self.dismiss_delegate?.dismiss_view(viewcontroller: self)
            
        } else {
            if let useprofile = self.useprofile {
                SharingManagerConfiguration.sharedInstance.setProfile(profile: useprofile)
                self.newProfile_delegate?.newProfile()
            }
            self.useprofile = nil
            self.dismiss_delegate?.dismiss_view(viewcontroller: self)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Table delegates
        self.profilesTable.delegate = self
        self.profilesTable.dataSource = self
        // Dismisser is root controller
        if let pvc = self.presenting as? ViewControllertabMain {
            self.dismiss_delegate = pvc
        }
        self.profile = profiles(path: nil)
        self.profilesArray = self.profile!.getDirectorysStrings()
        
        self.profilesTable.target = self
        self.profilesTable.doubleAction = #selector(ViewControllerProfile.tableViewDoubleClick(sender:))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        GlobalMainQueue.async(execute: { () -> Void in
            self.profilesTable.reloadData()
        })
        self.newprofile.stringValue = ""
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender:AnyObject) {
        if let pvc = self.presenting as? ViewControllertabMain {
            self.newProfile_delegate = pvc
        }
        if let useprofile = self.useprofile {
            SharingManagerConfiguration.sharedInstance.setProfile(profile: useprofile)
            self.newProfile_delegate?.newProfile()
        }
        self.useprofile = nil
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
}

extension ViewControllerProfile : NSTableViewDataSource {
    
    func numberOfRows(in tableViewMaster: NSTableView) -> Int {
        if (self.profilesArray != nil) {
            return self.profilesArray!.count
        } else {
            return 0
        }
    }
}


extension ViewControllerProfile : NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text:String?
        var cellIdentifier: String = ""
        let data = self.profilesArray![row]
        if tableColumn == tableView.tableColumns[0] {
            text = data
            cellIdentifier = "profilesID"
        }
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text!
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = notification.object as! NSTableView
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.useprofile = self.profilesArray![index]
        }
    }
    

}

