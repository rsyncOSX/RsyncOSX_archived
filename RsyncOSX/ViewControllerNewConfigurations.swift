//
//  ViewControllerNew.swift
//  Rsync
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable function_body_length cyclomatic_complexity trailing_comma line_length

import Cocoa
import Foundation

enum Typebackup {
    case synchronize
    case snapshots
    case syncremote
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
                          ViewControllerReference.shared.syncremote]
    var backuptypeselected: Typebackup = .synchronize
    var diddissappear: Bool = false

    @IBOutlet var addtable: NSTableView!
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
    @IBOutlet var addingtrailingbackslash: NSButton!
    @IBOutlet var stringlocalcatalog: NSTextField!
    @IBOutlet var stringremotecatalog: NSTextField!
    @IBOutlet var pretask: NSTextField!
    @IBOutlet var executepretask: NSButton!
    @IBOutlet var posttask: NSTextField!
    @IBOutlet var executeposttask: NSButton!
    @IBOutlet var haltshelltasksonerror: NSButton!
    @IBOutlet var addbutton: NSButton!

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

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerProfile!)
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    // All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }

    @IBAction func cleartable(_: NSButton) {
        self.newconfigurations = nil
        self.newconfigurations = NewConfigurations()
        globalMainQueue.async { () -> Void in
            self.addtable.reloadData()
            self.resetinputfields()
        }
    }

    @IBAction func assist(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAssist!)
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

    @IBAction func addConfig(_: NSButton) {
        let dict: NSMutableDictionary = [
            DictionaryStrings.task.rawValue: ViewControllerReference.shared.synchronize,
            DictionaryStrings.backupID.rawValue: backupID.stringValue,
            DictionaryStrings.localCatalog.rawValue: localCatalog.stringValue,
            DictionaryStrings.offsiteCatalog.rawValue: offsiteCatalog.stringValue,
            DictionaryStrings.offsiteServer.rawValue: offsiteServer.stringValue,
            DictionaryStrings.offsiteUsername.rawValue: offsiteUsername.stringValue,
            DictionaryStrings.parameter1.rawValue: self.archive,
            DictionaryStrings.parameter2.rawValue: self.verbose,
            DictionaryStrings.parameter3.rawValue: self.compress,
            DictionaryStrings.parameter4.rawValue: self.delete,
            DictionaryStrings.parameter5.rawValue: self.eparam,
            DictionaryStrings.parameter6.rawValue: self.ssh,
            "dryrun": self.dryrun,
            DictionaryStrings.dateRun.rawValue: "",
        ]
        if self.localCatalog.stringValue.hasSuffix("/") == false, self.addingtrailingbackslash.state == .off {
            self.localCatalog.stringValue += "/"
            dict.setValue(self.localCatalog.stringValue, forKey: DictionaryStrings.localCatalog.rawValue)
        }
        if self.offsiteCatalog.stringValue.hasSuffix("/") == false, self.addingtrailingbackslash.state == .off {
            self.offsiteCatalog.stringValue += "/"
            dict.setValue(self.offsiteCatalog.stringValue, forKey: DictionaryStrings.offsiteCatalog.rawValue)
        }
        if self.backuptypeselected == .snapshots {
            dict.setValue(ViewControllerReference.shared.snapshot, forKey: DictionaryStrings.task.rawValue)
            dict.setValue(1, forKey: DictionaryStrings.snapshotnum.rawValue)
            // Must be connected to create base remote snapshot catalog
            guard Validatenewconfigs(dict: dict).validated == true else { return }
            self.outputprocess = OutputProcess()
            // If connected create base remote snapshotcatalog
            self.snapshotcreateremotecatalog(dict: dict, outputprocess: self.outputprocess)
        } else if self.backuptypeselected == .syncremote {
            guard self.offsiteServer.stringValue.isEmpty == false else { return }
            dict.setValue(ViewControllerReference.shared.syncremote, forKey: DictionaryStrings.task.rawValue)
        }
        // Pre task
        if self.pretask.stringValue.isEmpty == false {
            if self.executepretask.state == .on {
                dict.setObject(1, forKey: DictionaryStrings.executepretask.rawValue as NSCopying)
            } else {
                dict.setObject(0, forKey: DictionaryStrings.executepretask.rawValue as NSCopying)
            }
            dict.setObject(self.pretask.stringValue, forKey: DictionaryStrings.pretask.rawValue as NSCopying)
        } else {
            dict.setObject(0, forKey: DictionaryStrings.executepretask.rawValue as NSCopying)
        }
        // Post task
        if self.posttask.stringValue.isEmpty == false {
            if self.executeposttask.state == .on {
                dict.setObject(1, forKey: DictionaryStrings.executeposttask.rawValue as NSCopying)
            } else {
                dict.setObject(0, forKey: DictionaryStrings.executeposttask.rawValue as NSCopying)
            }
            dict.setObject(self.pretask.stringValue, forKey: DictionaryStrings.posttask.rawValue as NSCopying)
        } else {
            dict.setObject(0, forKey: DictionaryStrings.executeposttask.rawValue as NSCopying)
        }
        // Haltpretast on error
        if self.haltshelltasksonerror.state == .on {
            dict.setObject(1, forKey: DictionaryStrings.haltshelltasksonerror.rawValue as NSCopying)
        } else {
            dict.setObject(0, forKey: DictionaryStrings.haltshelltasksonerror.rawValue as NSCopying)
        }

        if ViewControllerReference.shared.checkinput {
            let config = Configuration(dictionary: dict)
            let equal = Equal().isequalelement(data: self.configurations?.getConfigurations(), element: config)
            if equal {
                let question: String = NSLocalizedString("This is added before?", comment: "New")
                let text: String = NSLocalizedString("Add config?", comment: "New")
                let dialog: String = NSLocalizedString("Add", comment: "New")
                let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
                guard answer == true else { return }
            }
        }
        guard Validatenewconfigs(dict: dict).validated == true else { return }
        self.configurations?.addNewConfigurations(dict: dict)
        self.newconfigurations?.appendnewConfigurations(dict: dict)
        self.tabledata = self.newconfigurations?.getnewConfigurations()
        globalMainQueue.async { () -> Void in
            self.addtable.reloadData()
        }
        self.resetinputfields()
    }

    func snapshotcreateremotecatalog(dict: NSDictionary, outputprocess: OutputProcess?) {
        let config = Configuration(dictionary: dict)
        guard config.offsiteServer.isEmpty == false else { return }
        self.addbutton.isEnabled = false
        let args = SnapshotCreateCatalogArguments(config: config)
        let updatecurrent = OtherProcessCmdClosure(command: args.getCommand(),
                                                   arguments: args.getArguments(),
                                                   processtermination: self.processtermination,
                                                   filehandler: self.filehandler)
        updatecurrent.executeProcess(outputprocess: outputprocess)
    }
}

extension ViewControllerNewConfigurations: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.newconfigurations?.newConfigurationsCount() ?? 0
    }
}

extension ViewControllerNewConfigurations: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let object: NSMutableDictionary = self.newconfigurations?.getnewConfigurations()?[row], let tableColumn = tableColumn {
            return object[tableColumn.identifier] as? String
        } else {
            return nil
        }
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

extension ViewControllerNewConfigurations {
    func processtermination() {
        self.addbutton.isEnabled = true
    }

    func filehandler() {
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

extension ViewControllerNewConfigurations: AssistTransfer {
    func assisttransfer(values: [String]?) {
        if let values = values {
            switch values.count {
            case 2:
                self.localCatalog.stringValue = values[0]
                self.offsiteCatalog.stringValue = values[1]
                print(values)
            case 4:
                // remote
                self.localCatalog.stringValue = values[0]
                self.offsiteCatalog.stringValue = values[1]
                self.offsiteUsername.stringValue = values[2]
                self.offsiteServer.stringValue = values[3]
            default:
                return
            }
        }
    }
}
