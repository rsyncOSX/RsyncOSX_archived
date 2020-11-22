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
    var assistedit: Addvalues = .none

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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.combolocalhome.delegate = self
        self.combocatalogs.delegate = self
        self.comboremotehome.delegate = self
        self.comboremoteusers.delegate = self
        self.comboremotecomputers.delegate = self
        self.assist = Assist().assist
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.initialize()
        self.transferdataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.writeassistvaluesstorage()
    }

    private func writeassistvaluesstorage() {
        if self.assist == nil { self.assist = [Set<String>]() }
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

    private func initcomboxes(combobox: NSComboBox, values: Set<String>?) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: Array(values ?? []))
        if values?.count ?? 0 > 0 {
            combobox.selectItem(at: 0)
        } else {
            combobox.stringValue = ""
        }
    }

    @IBAction func addvalue(_: NSButton) {
        if self.addremotecomputers.stringValue.isEmpty == false {
            if self.remotecomputers == nil {
                self.remotecomputers = Set<String>()
            }
            self.remotecomputers?.insert(self.addremotecomputers.stringValue)
            self.initcomboxes(combobox: self.comboremotecomputers, values: self.remotecomputers)
        }
        if self.addremoteusers.stringValue.isEmpty == false {
            if self.remoteusers == nil {
                self.remoteusers = Set<String>()
            }
            self.remoteusers?.insert(self.addremoteusers.stringValue)
            self.initcomboxes(combobox: self.comboremoteusers, values: self.remoteusers)
        }
        if self.addremotehome.stringValue.isEmpty == false {
            if self.remotehome == nil {
                self.remotehome = Set<String>()
            }
            self.remotehome?.insert(self.addremotehome.stringValue)
            self.initcomboxes(combobox: self.comboremotehome, values: self.remotehome)
        }
        if self.addlocalhome.stringValue.isEmpty == false {
            if self.localhome == nil {
                self.localhome = Set<String>()
            }
            self.localhome?.insert(self.addlocalhome.stringValue)
            self.initcomboxes(combobox: self.combolocalhome, values: self.localhome)
        }
        if self.addcatalogs.stringValue.isEmpty == true {
            if self.catalogs == nil {
                self.catalogs = Set<String>()
            }
            self.catalogs?.insert(self.addcatalogs.stringValue)
            self.initcomboxes(combobox: self.combocatalogs, values: self.catalogs)
        }
        self.resetstringvalues()
    }

    @IBAction func deletevalue(_: NSButton) {
        switch self.assistedit {
        case .catalogs:
            self.catalogs?.remove(self.combocatalogs.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.combocatalogs, values: self.catalogs)
        case .localhome:
            self.localhome?.remove(self.combolocalhome.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.combolocalhome, values: self.localhome)
        case .remotehome:
            self.remotehome?.remove(self.comboremotehome.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.comboremotehome, values: self.remotehome)
        case .remoteusers:
            self.remoteusers?.remove(self.comboremoteusers.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.comboremoteusers, values: self.remoteusers)
        case .remotecomputers:
            self.remotecomputers?.remove(self.comboremotecomputers.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.comboremotecomputers, values: self.remotecomputers)
        default:
            return
        }
        self.assistedit = .none
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

extension ViewControllerAssist: NSComboBoxDelegate {
    func comboBoxWillPopUp(_ notification: Notification) {
        if let combobox = notification.object as? NSComboBox {
            switch combobox {
            case self.combolocalhome:
                self.assistedit = .localhome
            case self.combocatalogs:
                self.assistedit = .catalogs
            case self.comboremotehome:
                self.assistedit = .remotehome
            case self.comboremoteusers:
                self.assistedit = .remoteusers
            case self.comboremotecomputers:
                self.assistedit = .remotecomputers
            default:
                return
            }
        }
    }
}
