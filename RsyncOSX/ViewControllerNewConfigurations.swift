//
//  ViewControllerNew.swift
//  Rsync
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable function_body_length line_length cyclomatic_complexity trailing_comma type_body_length

import Cocoa
import Foundation

enum Typebackup {
    case synchronize
    case snapshots
    case syncremote
    case singlefile
}

class ViewControllerNewConfigurations: NSViewController, SetConfigurations, Delay, Index, VcMain, Checkforrsync, Help {
    var newconfigurations: NewConfigurations?
    var tabledata: [NSMutableDictionary]?
    let archive: String = "--archive"
    let verbose: String = "--verbose"
    let compress: String = "--compress"
    let delete: String = "--delete"
    let eparam: String = "-e"
    let ssh: String = "ssh"
    let dryrun: String = "--dry-run"
    var outputprocess: OutputProcess?
    // Reference to rsync parameters to use in combox
    var comboBoxValues = [ViewControllerReference.shared.synchronize,
                          ViewControllerReference.shared.snapshot,
                          ViewControllerReference.shared.syncremote,
                          "single file"]
    var backuptypeselected: Typebackup = .synchronize
    var diddissappear: Bool = false
    var remote: RemoteCapacity?

    @IBOutlet var addtable: NSTableView!
    @IBOutlet var remotecapacitytable: NSTableView!
    @IBOutlet var viewParameter1: NSTextField!
    @IBOutlet var viewParameter2: NSTextField!
    @IBOutlet var viewParameter3: NSTextField!
    @IBOutlet var viewParameter4: NSTextField!
    @IBOutlet var viewParameter5: NSTextField!
    @IBOutlet var localCatalog: NSTextField!
    @IBOutlet var offsiteCatalog: NSTextField!
    @IBOutlet var offsiteUsername: NSTextField!
    @IBOutlet var offsiteServer: NSTextField!
    @IBOutlet var backupID: NSTextField!
    @IBOutlet var profilInfo: NSTextField!
    @IBOutlet var backuptype: NSComboBox!
    @IBOutlet var remotecapacitybutton: NSButton!
    @IBOutlet var addingtrailingbackslash: NSButton!
    @IBOutlet var stringlocalcatalog: NSTextField!
    @IBOutlet var stringremotecatalog: NSTextField!
    @IBOutlet var pretask: NSTextField!
    @IBOutlet var executepretask: NSButton!
    @IBOutlet var posttask: NSTextField!
    @IBOutlet var executeposttask: NSButton!
    @IBOutlet var haltshelltasksonerror: NSButton!

    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    @IBAction func quickbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_: NSButton) {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func remotecapacity(_: NSButton) {
        guard self.configurations?.getConfigurationsDataSource() != nil else { return }
        guard (self.configurations?.getConfigurations().count ?? -1) > 0 else { return }
        self.remotecapacitybutton.isEnabled = false
        self.remote = RemoteCapacity(object: self)
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        }
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        }
    }

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    @IBAction func cleartable(_: NSButton) {
        self.newconfigurations = nil
        self.newconfigurations = NewConfigurations()
        globalMainQueue.async { () -> Void in
            self.addtable.reloadData()
            self.resetinputfields()
        }
    }

    private func changelabels() {
        switch self.backuptype.indexOfSelectedItem {
        case 2:
            self.stringlocalcatalog.stringValue = NSLocalizedString("Source catalog:", comment: "Tooltip")
            self.stringremotecatalog.stringValue = NSLocalizedString("Destination catalog:", comment: "Tooltip")
        default:
            self.stringlocalcatalog.stringValue = NSLocalizedString("Local catalog:", comment: "Tooltip")
            self.stringremotecatalog.stringValue = NSLocalizedString("Remote catalog:", comment: "Tooltip")
        }
    }

    @IBAction func setbackuptype(_: NSComboBox) {
        switch self.backuptype.indexOfSelectedItem {
        case 0:
            self.backuptypeselected = .synchronize
        case 1:
            self.backuptypeselected = .snapshots
        case 2:
            self.backuptypeselected = .syncremote
        case 3:
            self.backuptypeselected = .singlefile
        default:
            self.backuptypeselected = .synchronize
        }
        self.changelabels()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newconfigurations = NewConfigurations()
        self.addtable.delegate = self
        self.addtable.dataSource = self
        self.remotecapacitytable.delegate = self
        self.remotecapacitytable.dataSource = self
        self.localCatalog.toolTip = NSLocalizedString("By using Finder drag and drop filepaths.", comment: "Tooltip")
        self.offsiteCatalog.toolTip = NSLocalizedString("By using Finder drag and drop filepaths.", comment: "Tooltip")
        ViewControllerReference.shared.setvcref(viewcontroller: .vcnewconfigurations, nsviewcontroller: self)
        self.initcombox(combobox: self.backuptype, index: 0)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.backuptypeselected = .synchronize
        self.addingtrailingbackslash.state = .off
        self.backuptype.selectItem(at: 0)
        guard self.diddissappear == false else { return }
        self.viewParameter1.stringValue = self.archive
        self.viewParameter2.stringValue = self.verbose
        self.viewParameter3.stringValue = self.compress
        self.viewParameter4.stringValue = self.delete
        self.viewParameter5.stringValue = self.eparam + " " + self.ssh
        self.changelabels()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func initcombox(combobox: NSComboBox, index: Int) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: self.comboBoxValues)
        combobox.selectItem(at: index)
    }

    private func resetinputfields() {
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.pretask.stringValue = ""
        self.executepretask.state = .off
        self.posttask.stringValue = ""
        self.executeposttask.state = .off
        self.haltshelltasksonerror.state = .off
    }

    private func snapshotcreatecatalog(dict: NSDictionary, outputprocess: OutputProcess?) {
        let config: Configuration = Configuration(dictionary: dict)
        guard config.offsiteServer.isEmpty == false else { return }
        let args = SnapshotCreateCatalogArguments(config: config)
        let updatecurrent = SnapshotCreateCatalog(command: args.getCommand(), arguments: args.getArguments())
        updatecurrent.executeProcess(outputprocess: outputprocess)
    }

    @IBAction func addConfig(_: NSButton) {
        let dict: NSMutableDictionary = [
            "task": ViewControllerReference.shared.synchronize,
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
            "singleFile": 0,
        ]
        if !self.localCatalog.stringValue.hasSuffix("/"), self.backuptypeselected != .singlefile, self.addingtrailingbackslash.state == .off {
            self.localCatalog.stringValue += "/"
            dict.setValue(self.localCatalog.stringValue, forKey: "localCatalog")
        }
        if !self.offsiteCatalog.stringValue.hasSuffix("/"), self.addingtrailingbackslash.state == .off {
            self.offsiteCatalog.stringValue += "/"
            dict.setValue(self.offsiteCatalog.stringValue, forKey: "offsiteCatalog")
        }
        if self.backuptypeselected == .snapshots {
            dict.setValue(ViewControllerReference.shared.snapshot, forKey: "task")
            dict.setValue(1, forKey: "snapshotnum")
            guard Validatenewconfigs(dict: dict).validated == true else { return }
            self.outputprocess = OutputProcess()
            self.snapshotcreatecatalog(dict: dict, outputprocess: self.outputprocess)
        } else if self.backuptypeselected == .syncremote {
            guard self.offsiteServer.stringValue.isEmpty == false else { return }
            dict.setValue(ViewControllerReference.shared.syncremote, forKey: "task")
        } else if self.backuptypeselected == .singlefile {
            dict.setValue(1, forKey: "singleFile")
        }
        // Pre task
        if self.pretask.stringValue.isEmpty == false {
            if self.executepretask.state == .on {
                dict.setObject(1, forKey: "executepretask" as NSCopying)
            } else {
                dict.setObject(0, forKey: "executepretask" as NSCopying)
            }
            dict.setObject(self.pretask.stringValue, forKey: "pretask" as NSCopying)
        } else {
            dict.setObject(0, forKey: "executepretask" as NSCopying)
        }
        // Post task
        if self.posttask.stringValue.isEmpty == false {
            if self.executeposttask.state == .on {
                dict.setObject(1, forKey: "executeposttask" as NSCopying)
            } else {
                dict.setObject(0, forKey: "executeposttask" as NSCopying)
            }
            dict.setObject(self.pretask.stringValue, forKey: "posttask" as NSCopying)
        } else {
            dict.setObject(0, forKey: "executeposttask" as NSCopying)
        }
        // Haltpretast on error
        if self.haltshelltasksonerror.state == .on {
            dict.setObject(1, forKey: "haltshelltasksonerror" as NSCopying)
        } else {
            dict.setObject(0, forKey: "haltshelltasksonerror" as NSCopying)
        }

        if ViewControllerReference.shared.checkinput {
            let config: Configuration = Configuration(dictionary: dict)
            let equal = Equal().isequal(data: self.configurations?.getConfigurations(), element: config)
            if equal {
                let question: String = NSLocalizedString("This is added before?", comment: "New")
                let text: String = NSLocalizedString("Add config?", comment: "New")
                let dialog: String = NSLocalizedString("Add", comment: "New")
                let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
                guard answer == true else { return }
            }
        }
        guard Validatenewconfigs(dict: dict).validated == true else { return }
        self.configurations?.addNewConfigurations(dict)
        self.newconfigurations?.appendnewConfigurations(dict: dict)
        self.tabledata = self.newconfigurations?.getnewConfigurations()
        globalMainQueue.async { () -> Void in
            self.addtable.reloadData()
        }
        self.resetinputfields()
    }
}

extension ViewControllerNewConfigurations: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.addtable {
            return self.newconfigurations?.newConfigurationsCount() ?? 0
        } else {
            return self.remote?.remotecapacity?.count ?? 0
        }
    }
}

extension ViewControllerNewConfigurations: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == self.addtable {
            guard self.newconfigurations?.getnewConfigurations() != nil else { return nil }
            let object: NSMutableDictionary = self.newconfigurations!.getnewConfigurations()![row]
            return object[tableColumn!.identifier] as? String
        } else {
            guard self.remote?.remotecapacity != nil else { return nil }
            let object: NSMutableDictionary = self.remote!.remotecapacity![row]
            return object[tableColumn!.identifier] as? String
        }
    }

    func tableView(_: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        self.tabledata![row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
    }
}

extension ViewControllerNewConfigurations: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}

extension ViewControllerNewConfigurations: SetProfileinfo {
    func setprofile(profile: String, color: NSColor) {
        globalMainQueue.async { () -> Void in
            self.profilInfo.stringValue = profile
            self.profilInfo.textColor = color
        }
    }
}

extension ViewControllerNewConfigurations: UpdateProgress {
    func processTermination() {
        self.remote?.processTermination()
        self.remotecapacitybutton.isEnabled = self.remote!.enableremotecapacitybutton()
        globalMainQueue.async { () -> Void in
            self.remotecapacitytable.reloadData()
        }
    }

    func fileHandler() {
        //
    }
}

extension ViewControllerNewConfigurations: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}
