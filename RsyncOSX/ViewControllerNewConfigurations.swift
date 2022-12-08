//
//  ViewControllerNew.swift
//  Rsync
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable function_body_length cyclomatic_complexity line_length type_body_length

import Cocoa
import Foundation

enum Typebackup {
    case synchronize
    case snapshots
    case syncremote
}

class ViewControllerNewConfigurations: NSViewController, SetConfigurations, Delay, Index, VcMain, Checkforrsync, Help, Presentoutput {
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

    weak var reloadtabledata: Reloadandrefresh?
    weak var openoutput: OpenOutputfromrsync?
    weak var setprocessDelegate: SendOutputProcessreference?

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
    @IBOutlet var backuptype: NSComboBox!
    @IBOutlet var addingtrailingbackslash: NSButton!
    @IBOutlet var stringlocalcatalog: NSTextField!
    @IBOutlet var stringremotecatalog: NSTextField!
    @IBOutlet var pretask: NSTextField!
    @IBOutlet var executepretask: NSButton!
    @IBOutlet var posttask: NSTextField!
    @IBOutlet var executeposttask: NSButton!
    @IBOutlet var haltshelltasksonerror: NSButton!

    // Assist
    @IBOutlet var comboremoteusers: NSComboBox!
    @IBOutlet var comboremotecomputers: NSComboBox!
    @IBOutlet var combocatalogs: NSComboBox!
    @IBOutlet var combolocalhome: NSComboBox!

    var assist: Assist?

    // Sidebar Clear button
    @IBAction func delete(_: NSButton) {
        globalMainQueue.async { () in
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
        localCatalog.toolTip = NSLocalizedString("By using Finder drag and drop filepaths.", comment: "Tooltip")
        offsiteCatalog.toolTip = NSLocalizedString("By using Finder drag and drop filepaths.", comment: "Tooltip")
        SharedReference.shared.setvcref(viewcontroller: .vcnewconfigurations, nsviewcontroller: self)
        initcombox(combobox: backuptype, index: 0)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // sidebaractionsDelegate?.sidebaractions(action: .addviewbuttons)
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
        // Assist
        initialize()
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
    @IBAction func addtask(_: NSButton) {
        if let newconfig = qualifynewconfig() {
            configurations?.addNewConfigurations(newconfig)
            resetinputfields()
            reloadtabledata = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
            reloadtabledata?.reloadtabledata()
        }
    }

    private func qualifynewconfig() -> Configuration? {
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
            guard Validatenewconfigs(newconfig, true).validated == true else { return nil }
            outputprocess = OutputfromProcess()
            // If connected create base remote snapshotcatalog
            snapshotcreateremotecatalog(newconfig, outputprocess)
        } else if backuptypeselected == .syncremote {
            guard offsiteServer.stringValue.isEmpty == false else { return nil }
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
        guard Validatenewconfigs(newconfig, true).validated == true else { return nil }

        return newconfig
    }

    func snapshotcreateremotecatalog(_ config: Configuration, _: OutputfromProcess?) {
        guard config.offsiteServer.isEmpty == false else { return }
        let args = SnapshotCreateCatalogArguments(config: config)
        let updatecurrent = CommandProcess(command: args.getCommand(),
                                           arguments: args.getArguments(),
                                           processtermination: processtermination)
        updatecurrent.executeProcess()
    }

    @IBAction func selectlocalcatalog(_: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.title = NSLocalizedString("select catalog", comment: "")
        openPanel.beginSheetModal(for: view.window!, completionHandler: { num in
            if num == NSApplication.ModalResponse.OK {
                let path = openPanel.url?.path ?? ""
                self.localCatalog.stringValue = path
            }
        })
    }

    @IBAction func selectoffsiteCatalog(_: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.title = NSLocalizedString("select catalog", comment: "")
        openPanel.beginSheetModal(for: view.window!, completionHandler: { num in
            if num == NSApplication.ModalResponse.OK {
                let path = openPanel.url?.path ?? ""
                self.offsiteCatalog.stringValue = path
            }
        })
    }

    @IBAction func addremote(_: NSButton) {
        if let home = combolocalhome.objectValue as? String,
           let catalog = combocatalogs.objectValue as? String,
           let user = comboremoteusers.objectValue as? String,
           let remotecomputer = comboremotecomputers.objectValue as? String
        {
            var transfer = [String]()
            transfer.append(home + "/" + catalog)
            transfer.append("~/" + catalog)
            transfer.append(user)
            transfer.append(remotecomputer)
            assisttransfer(values: transfer)
        }
    }

    @IBAction func addlocal(_: NSButton) {
        if let home = combolocalhome.objectValue as? String,
           let catalog = combocatalogs.objectValue as? String
        {
            var transfer = [String]()
            transfer.append(home + "/" + catalog)
            transfer.append("/mounted_Volume/" + catalog)
            assisttransfer(values: transfer)
        }
    }

    private func assisttransfer(values: [String]?) {
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

    private func initialize() {
        assist = Assist()
        if let assist = assist {
            initcomboxes(combobox: comboremotecomputers, values: assist.remoteservers)
            initcomboxes(combobox: comboremoteusers, values: assist.remoteusers)
            initcomboxes(combobox: combocatalogs, values: assist.catalogs)
            initcomboxes(combobox: combolocalhome, values: assist.localhome)
        }
    }

    private func initcomboxes(combobox: NSComboBox, values: Set<String>?) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: Array(values ?? []))
        if values?.count ?? 0 > 0 {
            combobox.selectItem(at: 0)
        } else {
            combobox.stringValue = ""
        }
    }
}

extension ViewControllerNewConfigurations {
    func processtermination(data: [String]?) {
        presentoutputfromrsync(data: data)
    }

    // Toolbar - All ouput
    @IBAction func alloutput(_: NSButton) {
        if let newconfig = qualifynewconfig() {
            if let arguments = ArgumentsSynchronize(config: newconfig).argumentssynchronize(dryRun: true, forDisplay: false) {
                let command = RsyncAsync(arguments: arguments,
                                         processtermination: processtermination)
                // openoutput = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                // openoutput?.openoutputfromrsync()
                Task {
                    await command.executeProcess()
                }
            }
        }
    }
}
