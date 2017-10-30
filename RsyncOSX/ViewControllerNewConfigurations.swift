//
//  ViewControllerNew.swift
//  Rsync
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable function_body_length

import Foundation
import Cocoa

class ViewControllerNewConfigurations: NSViewController, SetConfigurations, VcSchedule {

    var storageapi: PersistentStorageAPI?
    var newconfigurations: NewConfigurations?
    var tabledata: [NSMutableDictionary]?
    let archive: String = "--archive"
    let verbose: String = "--verbose"
    let compress: String = "--compress"
    let delete: String = "--delete"
    let eparam: String = "-e"
    let ssh: String = "ssh"
    let dryrun: String = "--dry-run"

    @IBOutlet weak var newTableView: NSTableView!
    @IBOutlet weak var viewParameter1: NSTextField!
    @IBOutlet weak var viewParameter2: NSTextField!
    @IBOutlet weak var viewParameter3: NSTextField!
    @IBOutlet weak var viewParameter4: NSTextField!
    @IBOutlet weak var viewParameter5: NSTextField!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var rsyncdaemon: NSButton!
    @IBOutlet weak var singleFile: NSButton!
    @IBOutlet weak var profilInfo: NSTextField!
    @IBOutlet weak var equal: NSTextField!

    @IBAction func cleartable(_ sender: NSButton) {
        self.newconfigurations = nil
        self.newconfigurations = NewConfigurations()
        globalMainQueue.async(execute: { () -> Void in
            self.newTableView.reloadData()
            self.setFields()
        })
    }
    @IBAction func copyLocalCatalog(_ sender: NSButton) {
        _ = FileDialog(requester: .addLocalCatalog)
    }

    @IBAction func copyRemoteCatalog(_ sender: NSButton) {
        _ = FileDialog(requester: .addRemoteCatalog)
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Set the delegates
        self.newTableView.delegate = self
        self.newTableView.dataSource = self
        self.localCatalog.toolTip = "By using Finder drag and drop filepaths."
        self.offsiteCatalog.toolTip = "By using Finder drag and drop filepaths."
        ViewControllerReference.shared.setvcref(viewcontroller: .vcnewconfigurations, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.newconfigurations = nil
        self.newconfigurations = NewConfigurations()
        if let profile = self.configurations!.getProfile() {
            self.storageapi = PersistentStorageAPI(profile: profile)
        } else {
            self.storageapi = PersistentStorageAPI(profile: nil)
        }
        self.setFields()
    }

    private func setFields() {
        self.viewParameter1.stringValue = archive
        self.viewParameter2.stringValue = verbose
        self.viewParameter3.stringValue = compress
        self.viewParameter4.stringValue = delete
        self.viewParameter5.stringValue = eparam + " " + ssh
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.rsyncdaemon.state = .off
        self.singleFile.state = .off
        self.equal.isHidden = true
    }

    @IBAction func addConfig(_ sender: NSButton) {
        let dict: NSMutableDictionary = [
            "task": "backup",
            "backupID": backupID.stringValue,
            "localCatalog": localCatalog.stringValue,
            "offsiteCatalog": offsiteCatalog.stringValue,
            "offsiteServer": offsiteServer.stringValue,
            "offsiteUsername": offsiteUsername.stringValue,
            "parameter1": self.archive,
            "parameter2": self.verbose,
            "parameter3": self.compress,
            "parameter4": self.delete,
            "parameter5": self.eparam,
            "parameter6": self.ssh,
            "dryrun": self.dryrun,
            "dateRun": "",
            "singleFile": 0]
        dict.setValue("no", forKey: "batch")
        if self.singleFile.state == .on { dict.setValue(1, forKey: "singleFile")}
        if !self.localCatalog.stringValue.hasSuffix("/") && self.singleFile.state == .off {
            self.localCatalog.stringValue += "/"
            dict.setValue(self.localCatalog.stringValue, forKey: "localCatalog")
        }
        if !self.offsiteCatalog.stringValue.hasSuffix("/") {
            self.offsiteCatalog.stringValue += "/"
            dict.setValue(self.offsiteCatalog.stringValue, forKey: "offsiteCatalog")
        }
        dict.setObject(self.rsyncdaemon.state, forKey: "rsyncdaemon" as NSCopying)
        if sshport.stringValue != "" {
            if let port: Int = Int(self.sshport.stringValue) {
                dict.setObject(port, forKey: "sshport" as NSCopying)
            }
        }
        // If add button is selected without any values
        guard self.localCatalog.stringValue != "/" else {
            self.offsiteCatalog.stringValue = ""
            self.localCatalog.stringValue = ""
            return
        }
        guard self.offsiteCatalog.stringValue != "/" else {
            self.offsiteCatalog.stringValue = ""
            self.localCatalog.stringValue = ""
            return
        }
        guard self.offsiteCatalog.stringValue != self.localCatalog.stringValue else {
            self.equal.isHidden = false
            return
        }
        self.configurations!.addNewConfigurations(dict)
        self.newconfigurations?.appendnewConfigurations(dict: dict)
        self.tabledata = self.newconfigurations!.getnewConfigurations()
        globalMainQueue.async(execute: { () -> Void in
            self.newTableView.reloadData()
        })
        self.setFields()
    }
}

extension ViewControllerNewConfigurations: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.newconfigurations?.newConfigurationsCount() ?? 0
    }

}

extension ViewControllerNewConfigurations: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.newconfigurations?.getnewConfigurations() != nil else {
            return nil
        }
        let object: NSMutableDictionary = self.newconfigurations!.getnewConfigurations()![row]
        return object[tableColumn!.identifier] as? String
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        self.tabledata![row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
    }
}

extension ViewControllerNewConfigurations: GetPath {

    func pathSet(path: String?, requester: WhichPath) {
        if let setpath = path {
            switch requester {
            case .addLocalCatalog:
                self.localCatalog.stringValue = setpath
            case .addRemoteCatalog:
                self.offsiteCatalog.stringValue = setpath
            default:
                break
            }
        }
    }
}

extension ViewControllerNewConfigurations: DismissViewController {

    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllerNewConfigurations: SetProfileinfo {
    func setprofile(profile: String, color: NSColor) {
        globalMainQueue.async(execute: { () -> Void in
            self.profilInfo.stringValue = profile
            self.profilInfo.textColor = color
        })
    }
}
