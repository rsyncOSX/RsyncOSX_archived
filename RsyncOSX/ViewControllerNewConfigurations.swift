//
//  ViewControllerNew.swift
//  Rsync
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable function_body_length cyclomatic_complexity line_length

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
    var outputprocess: OutputfromProcess?
    // Reference to rsync parameters to use in combox
    var comboBoxValues = [SharedReference.shared.synchronize,
                          SharedReference.shared.snapshot,
                          SharedReference.shared.syncremote]
    var backuptypeselected: Typebackup = .synchronize
    var diddissappear: Bool = false
    // Send messages to the sidebar
    weak var sidebaractionsDelegate: Sidebaractions?

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
    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        presentAsModalWindow(viewControllerProfile!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        help()
    }

    // Sidebar Clear button
    func cleartable() {
        newconfigurations = nil
        newconfigurations = NewConfigurations()
        globalMainQueue.async { () -> Void in
            self.resetinputfields()
        }
    }

    private func changelabels() {
        switch backuptype.indexOfSelectedItem {
        case 2:
            stringlocalcatalog.stringValue = NSLocalizedString("Source catalog:", comment: "Tooltip")
            stringremotecatalog.stringValue = NSLocalizedString("Destination catalog:", comment: "Tooltip")
        default:
            stringlocalcatalog.stringValue = NSLocalizedString("Local catalog:", comment: "Tooltip")
            stringremotecatalog.stringValue = NSLocalizedString("Remote catalog:", comment: "Tooltip")
        }
    }

    @IBAction func setbackuptype(_: NSComboBox) {
        switch backuptype.indexOfSelectedItem {
        case 0:
            backuptypeselected = .synchronize
        case 1:
            backuptypeselected = .snapshots
        case 2:
            backuptypeselected = .syncremote
        default:
            backuptypeselected = .synchronize
        }
        changelabels()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        newconfigurations = NewConfigurations()
        localCatalog.toolTip = NSLocalizedString("By using Finder drag and drop filepaths.", comment: "Tooltip")
        offsiteCatalog.toolTip = NSLocalizedString("By using Finder drag and drop filepaths.", comment: "Tooltip")
        SharedReference.shared.setvcref(viewcontroller: .vcnewconfigurations, nsviewcontroller: self)
        initcombox(combobox: backuptype, index: 0)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // For sending messages to the sidebar
        sidebaractionsDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        sidebaractionsDelegate?.sidebaractions(action: .addviewbuttons)
        backuptypeselected = .synchronize
        addingtrailingbackslash.state = .off
        backuptype.selectItem(at: 0)
        guard diddissappear == false else { return }
        viewParameter1.stringValue = archive
        viewParameter2.stringValue = verbose
        viewParameter3.stringValue = compress
        viewParameter4.stringValue = delete
        viewParameter5.stringValue = eparam + " " + ssh
        changelabels()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        diddissappear = true
    }

    private func initcombox(combobox: NSComboBox, index: Int) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: comboBoxValues)
        combobox.selectItem(at: index)
    }

    private func resetinputfields() {
        localCatalog.stringValue = ""
        offsiteCatalog.stringValue = ""
        offsiteUsername.stringValue = ""
        offsiteServer.stringValue = ""
        backupID.stringValue = ""
        pretask.stringValue = ""
        executepretask.state = .off
        posttask.stringValue = ""
        executeposttask.state = .off
        haltshelltasksonerror.state = .off
    }

    // Sidebar Add button
    func addConfig() {
        if localCatalog.stringValue.hasSuffix("/") == false, addingtrailingbackslash.state == .off {
            localCatalog.stringValue += "/"
        }
        if offsiteCatalog.stringValue.hasSuffix("/") == false, addingtrailingbackslash.state == .off {
            offsiteCatalog.stringValue += "/"
        }
        var newconfig = Configuration()
        newconfig.task = SharedReference.shared.synchronize
        newconfig.backupID = backupID.stringValue
        newconfig.localCatalog = localCatalog.stringValue
        newconfig.offsiteCatalog = offsiteCatalog.stringValue
        newconfig.offsiteServer = offsiteServer.stringValue
        newconfig.offsiteUsername = offsiteUsername.stringValue
        newconfig.parameter1 = archive
        newconfig.parameter2 = verbose
        newconfig.parameter3 = compress
        newconfig.parameter4 = delete
        newconfig.parameter5 = eparam
        newconfig.parameter6 = ssh
        newconfig.dateRun = ""
        if backuptypeselected == .snapshots {
            newconfig.snapshotnum = 1
            newconfig.task = SharedReference.shared.snapshot
            // Must be connected to create base remote snapshot catalog
            guard Validatenewconfigs(newconfig, true).validated == true else { return }
            outputprocess = OutputfromProcess()
            // If connected create base remote snapshotcatalog
            snapshotcreateremotecatalog(newconfig, outputprocess)
        } else if backuptypeselected == .syncremote {
            guard offsiteServer.stringValue.isEmpty == false else { return }
            newconfig.task = SharedReference.shared.syncremote
        }
        // Pre task
        if pretask.stringValue.isEmpty == false {
            if executepretask.state == .on {
                newconfig.executepretask = 1
            } else {
                newconfig.executepretask = 0
            }
            newconfig.pretask = pretask.stringValue
        } else {
            newconfig.executepretask = 0
        }
        // Post task
        if posttask.stringValue.isEmpty == false {
            if executeposttask.state == .on {
                newconfig.executeposttask = 1
            } else {
                newconfig.executeposttask = 0
            }
            newconfig.pretask = pretask.stringValue
        } else {
            newconfig.executeposttask = 0
        }
        // Haltpretast on error
        if haltshelltasksonerror.state == .on {
            newconfig.haltshelltasksonerror = 1
        } else {
            newconfig.haltshelltasksonerror = 0
        }
        guard Validatenewconfigs(newconfig, true).validated == true else { return }
        configurations?.addNewConfigurations(newconfig)
        resetinputfields()
    }

    func snapshotcreateremotecatalog(_ config: Configuration, _ outputprocess: OutputfromProcess?) {
        guard config.offsiteServer.isEmpty == false else { return }
        let args = SnapshotCreateCatalogArguments(config: config)
        let updatecurrent = OtherProcess(command: args.getCommand(),
                                         arguments: args.getArguments(),
                                         processtermination: processtermination,
                                         filehandler: filehandler)
        updatecurrent.executeProcess(outputprocess: outputprocess)
    }
}

extension ViewControllerNewConfigurations: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return newconfigurations?.newConfigurationsCount() ?? 0
    }
}

extension ViewControllerNewConfigurations: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let object: NSMutableDictionary = newconfigurations?.getnewConfigurations()?[row], let tableColumn = tableColumn {
            return object[tableColumn.identifier] as? String
        } else {
            return nil
        }
    }
}

extension ViewControllerNewConfigurations: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        dismiss(viewcontroller)
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
    func processtermination() {}

    func filehandler() {}
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
                localCatalog.stringValue = values[0]
                offsiteCatalog.stringValue = values[1]
            case 4:
                // remote
                localCatalog.stringValue = values[0]
                offsiteCatalog.stringValue = values[1]
                offsiteUsername.stringValue = values[2]
                offsiteServer.stringValue = values[3]
            default:
                return
            }
        }
    }
}

extension ViewControllerNewConfigurations: Sidebarbuttonactions {
    func sidebarbuttonactions(action: Sidebaractionsmessages) {
        switch action {
        case .Delete:
            cleartable()
        case .Add:
            addConfig()
        default:
            return
        }
    }
}
