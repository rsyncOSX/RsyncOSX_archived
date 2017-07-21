//
//  ViewControllerNew.swift
//  Rsync
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

//swiftlint:disable syntactic_sugar file_length cyclomatic_complexity line_length function_body_length

import Foundation
import Cocoa

class ViewControllerNewConfigurations: NSViewController {

    // Table holding all new Configurations
    @IBOutlet weak var newTableView: NSTableView!

    // NSMutableDictionary as datasource for tableview
    var tabledata: [NSMutableDictionary]?
    let parameterTest: String = "--dry-run"
    let parameter1: String = "--archive"
    let parameter2: String = "--verbose"
    let parameter3: String = "--compress"
    let parameter4: String = "--delete"
    let parameter5: String = "-e"
    let parameter6: String = "ssh"

    var newConfigs: Bool = false

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

    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    lazy var viewControllerUserconfiguration: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardUserconfigID"))
            as? NSViewController)!
    }()

    @IBAction func copyLocalCatalog(_ sender: NSButton) {
        _ = FileDialog(requester: .addLocalCatalog)
    }

    @IBAction func copyRemoteCatalog(_ sender: NSButton) {
        _ = FileDialog(requester: .addRemoteCatalog)
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerUserconfiguration)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Set the delegates
        self.newTableView.delegate = self
        self.newTableView.dataSource = self
        Configurations.shared.destroyNewConfigurations()
        // Tooltip
        self.localCatalog.toolTip = "By using Finder drag and drop filepaths."
        self.offsiteCatalog.toolTip = "By using Finder drag and drop filepaths."
        Configurations.shared.viewControllerNewConfigurations = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.setFields()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        if self.newConfigs {
            PersistentStoreageAPI.shared.saveNewConfigurations()
            self.newConfigs = false
        }
    }

    // handler and getter for setting localcatalog
    // for å hente lokal katalog

    private func setFields() {
        self.viewParameter1.stringValue = parameter1
        self.viewParameter2.stringValue = parameter2
        self.viewParameter3.stringValue = parameter3
        self.viewParameter4.stringValue = parameter4
        self.viewParameter5.stringValue = parameter5 + " " + parameter6
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.rsyncdaemon.state = .off
        self.singleFile.state = .off
    }

    @IBAction func addConfig(_ sender: NSButton) {
        let dict: NSMutableDictionary = [
            "task": "backup",
            "backupID": backupID.stringValue,
            "localCatalog": localCatalog.stringValue,
            "offsiteCatalog": offsiteCatalog.stringValue,
            "offsiteServer": offsiteServer.stringValue,
            "offsiteUsername": offsiteUsername.stringValue,
            "parameter1": parameter1,
            "parameter2": parameter2,
            "parameter3": parameter3,
            "parameter4": parameter4,
            "parameter5": parameter5,
            "parameter6": parameter6,
            "dryrun": "--dry-run",
            "rsync": "rsync",
            "dateRun": "",
            "singleFile": 0]
        dict.setValue("no", forKey: "batch")
        if self.singleFile.state == .on {
            dict.setValue(1, forKey: "singleFile")
        }

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

        Configurations.shared.addNewConfigurations(dict)
        self.tabledata = Configurations.shared.getnewConfigurations()
        globalMainQueue.async(execute: { () -> Void in
            self.newTableView.reloadData()
        })
        self.newConfigs = true
        self.setFields()
    }

}

extension ViewControllerNewConfigurations : NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return Configurations.shared.newConfigurationsCount()
    }

}

extension ViewControllerNewConfigurations : NSTableViewDelegate {

    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let object: NSMutableDictionary = Configurations.shared.getnewConfigurations()![row]
        return object[tableColumn!.identifier] as? String
    }

    @objc(tableView:setObjectValue:forTableColumn:row:) func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
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

    // Telling the view to dismiss any presented Viewcontroller
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }

}
