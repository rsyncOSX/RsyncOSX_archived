//
//  ViewControllerAssist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity line_length

import Cocoa
import Foundation

struct AssistEdit {
    var indexselected: Int = -1
    var typeselected: Addvalues = .none
}

class ViewControllerAssist: NSViewController {
    var remotecomputers: Set<String>?
    var remoteusers: Set<String>?
    var remotehome: Set<String>?
    var catalogs: Set<String>?
    var localhome: Set<String>?
    var numberofsets: Int = 5
    var assist: [Set<String>]?
    var addvalues: Addvalues = .none
    weak var transferdataDelegate: AssistTransfer?
    var assistedit = AssistEdit()

    @IBOutlet var comboremoteusers: NSComboBox!
    @IBOutlet var addremoteusers: NSTextField!
    @IBOutlet var comboremotehome: NSComboBox!
    @IBOutlet var addremotehome: NSTextField!
    @IBOutlet var comboremotecomputers: NSComboBox!
    @IBOutlet var addremotecomputers: NSTextField!
    @IBOutlet var combocatalogs: NSComboBox!
    @IBOutlet var addcatalogs: NSTextField!
    @IBOutlet var combolocalhome: NSComboBox!
    @IBOutlet var addlocalhome: NSTextField!

    @IBAction func closeview(_: NSButton) {
        self.view.window?.close()
    }

    @IBAction func defaultbutton(_: NSButton) {
        let defaultvalues = AssistDefault()
        self.localhome = defaultvalues.localhome
        self.catalogs = defaultvalues.catalogs
        self.writeassistvaluesstorage()
        self.readassistvaluesstorage()
        self.initialize()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addremotecomputers.delegate = self
        self.addremoteusers.delegate = self
        self.addremotehome.delegate = self
        self.addcatalogs.delegate = self
        self.addlocalhome.delegate = self
        self.combolocalhome.delegate = self
        self.combocatalogs.delegate = self
        self.comboremotehome.delegate = self
        self.comboremoteusers.delegate = self
        self.comboremotecomputers.delegate = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.readassistvaluesstorage()
        // Initialize comboboxes
        self.initialize()
        self.transferdataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
    }

    private func writeassistvaluesstorage() {
        guard self.remotecomputers != nil,
            self.remoteusers != nil,
            self.remotehome != nil,
            self.catalogs != nil,
            self.localhome != nil
        else {
            return
        }
        if self.assist == nil {
            self.assist = [Set<String>]()
        }
        for i in 0 ..< self.numberofsets {
            switch i {
            case 0:
                if self.remotecomputers != nil {
                    self.assist?.append(self.remotecomputers ?? [])
                }
            case 1:
                if self.remoteusers != nil {
                    self.assist?.append(self.remoteusers ?? [])
                }
            case 2:
                if self.remotehome != nil {
                    self.assist?.append(self.remotehome ?? [])
                }
            case 3:
                if self.catalogs != nil {
                    self.assist?.append(self.catalogs ?? [])
                }
            case 4:
                if self.localhome != nil {
                    self.assist?.append(self.localhome ?? [])
                }
            default:
                return
            }
        }
        PersistentStorageAssist(assistassets: self.assist).saveassist()
    }

    private func readassistvaluesstorage() {
        self.assist = Assist(assist: PersistentStorageAssist(assistassets: nil).readassist()).assist
        for i in 0 ..< self.numberofsets {
            switch i {
            case 0:
                self.remotecomputers = self.assist?[0]
            case 1:
                self.remoteusers = self.assist?[1]
            case 2:
                self.remotehome = self.assist?[2]
            case 3:
                self.catalogs = self.assist?[3]
            case 4:
                self.localhome = self.assist?[4]
            default:
                return
            }
        }
        self.assist = nil
    }

    private func initcomboxes(combobox: NSComboBox, values: Set<String>?) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: Array(values ?? []))
        if values?.count ?? 0 > 0 {
            combobox.selectItem(at: 0)
        }
    }

    @IBAction func addvalue(_: NSButton) {
        switch self.addvalues {
        case .remotecomputers:
            if self.remotecomputers == nil {
                self.remotecomputers = Set<String>()
            }
            self.remotecomputers?.insert(self.addremotecomputers.stringValue)
        case .remoteusers:
            if self.remoteusers == nil {
                self.remoteusers = Set<String>()
            }
            self.remoteusers?.insert(self.addremoteusers.stringValue)
        case .remotehome:
            if self.remotehome == nil {
                self.remotehome = Set<String>()
            }
            self.remotehome?.insert(self.addremotehome.stringValue)
        case .localhome:
            if self.localhome == nil {
                self.localhome = Set<String>()
            }
            self.localhome?.insert(self.addlocalhome.stringValue)
        case .catalogs:
            if self.catalogs == nil {
                self.catalogs = Set<String>()
            }
            self.catalogs?.insert(self.addcatalogs.stringValue)
        default:
            return
        }
        self.resetstringvalues()
        self.writeassistvaluesstorage()
        self.readassistvaluesstorage()
        self.initialize()
    }

    @IBAction func deletevalue(_: NSButton) {
        switch self.assistedit.typeselected {
        case .catalogs:
            self.catalogs?.remove(self.combocatalogs.objectValue as? String ?? "")
        case .localhome:
            self.localhome?.remove(self.combolocalhome.objectValue as? String ?? "")
        case .remotehome:
            self.remotehome?.remove(self.comboremotehome.objectValue as? String ?? "")
        case .remoteusers:
            self.remoteusers?.remove(self.comboremoteusers.objectValue as? String ?? "")
        case .remotecomputers:
            self.remotecomputers?.remove(self.comboremotecomputers.objectValue as? String ?? "")
        default:
            return
        }
        self.writeassistvaluesstorage()
        self.readassistvaluesstorage()
        self.initialize()
    }

    @IBAction func addremote(_: NSButton) {
        if let home = self.combolocalhome.objectValue as? String,
            let catalog = self.combocatalogs.objectValue as? String,
            let remotehome = self.comboremotehome.objectValue as? String,
            let user = self.comboremoteusers.objectValue as? String,
            let remotecomputer = self.comboremotecomputers.objectValue as? String
        {
            var transfer = [String]()
            transfer.append(home + "/" + catalog)
            transfer.append(remotehome + "/" + catalog)
            transfer.append(user)
            transfer.append(remotecomputer)
            self.transferdataDelegate?.assisttransfer(values: transfer)
            self.view.window?.close()
        }
    }

    @IBAction func addlocal(_: NSButton) {
        if let home = self.combolocalhome.objectValue as? String,
            let catalog = self.combocatalogs.objectValue as? String,
            let remotehome = self.comboremotehome.objectValue as? String
        {
            var transfer = [String]()
            transfer.append(home + "/" + catalog)
            transfer.append(remotehome + "/" + catalog)
            self.transferdataDelegate?.assisttransfer(values: transfer)
            self.view.window?.close()
        }
    }

    private func resetstringvalues() {
        self.addcatalogs.stringValue = ""
        self.addlocalhome.stringValue = ""
        self.addremotecomputers.stringValue = ""
        self.addremotehome.stringValue = ""
        self.addremoteusers.stringValue = ""
    }

    private func initialize() {
        // Initialize comboboxes
        self.initcomboxes(combobox: self.comboremotecomputers, values: self.remotecomputers)
        self.initcomboxes(combobox: self.comboremoteusers, values: self.remoteusers)
        self.initcomboxes(combobox: self.comboremotehome, values: self.remotehome)
        self.initcomboxes(combobox: self.combocatalogs, values: self.catalogs)
        self.initcomboxes(combobox: self.combolocalhome, values: self.localhome)
    }
}

extension ViewControllerAssist: NSTextFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        switch notification.object as? NSTextField {
        case self.addremotecomputers:
            self.addvalues = .remotecomputers
        case self.addremoteusers:
            self.addvalues = .remoteusers
        case self.addremotehome:
            self.addvalues = .remotehome
        case self.addlocalhome:
            self.addvalues = .localhome
        case self.addcatalogs:
            self.addvalues = .catalogs
        default:
            self.addvalues = .none
        }
    }
}

extension ViewControllerAssist: NSComboBoxDelegate {
    func comboBoxSelectionIsChanging(_ notification: Notification) {
        if let combobox = notification.object as? NSComboBox {
            switch combobox {
            case self.combolocalhome:
                self.assistedit.typeselected = .localhome
                self.assistedit.indexselected = self.combolocalhome.indexOfSelectedItem
            case self.combocatalogs:
                self.assistedit.typeselected = .catalogs
                self.assistedit.indexselected = self.combocatalogs.indexOfSelectedItem
            case self.comboremotehome:
                self.assistedit.typeselected = .remotehome
                self.assistedit.indexselected = self.comboremotehome.indexOfSelectedItem
            case self.comboremoteusers:
                self.assistedit.typeselected = .remoteusers
                self.assistedit.indexselected = self.comboremoteusers.indexOfSelectedItem
            case self.comboremotecomputers:
                self.assistedit.typeselected = .remotecomputers
                self.assistedit.indexselected = self.comboremotecomputers.indexOfSelectedItem
            default:
                return
            }
        }
    }
}
