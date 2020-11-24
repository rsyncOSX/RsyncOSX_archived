//
//  ViewControllerAssist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 01/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerAssist: NSViewController {
    var assist: Assist?
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
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.initialize()
        self.transferdataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        if self.assist?.dirty ?? false {
            PersistentStorageAssist(assist: self.assist).saveassist()
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

    @IBAction func addvalue(_: NSButton) {
        if self.addremotecomputers.stringValue.isEmpty == false {
            if self.assist?.remotecomputers == nil { self.assist?.remotecomputers = Set() }
            self.assist?.remotecomputers?.insert(self.addremotecomputers.stringValue)
            self.initcomboxes(combobox: self.comboremotecomputers, values: self.assist?.remotecomputers)
        }
        if self.addremoteusers.stringValue.isEmpty == false {
            if self.assist?.remoteusers == nil { self.assist?.remoteusers = Set() }
            self.assist?.remoteusers?.insert(self.addremoteusers.stringValue)
            self.initcomboxes(combobox: self.comboremoteusers, values: self.assist?.remoteusers)
        }
        if self.addremotehome.stringValue.isEmpty == false {
            if self.assist?.remotehome == nil { self.assist?.remotehome = Set() }
            self.assist?.remotehome?.insert(self.addremotehome.stringValue)
            self.initcomboxes(combobox: self.comboremotehome, values: self.assist?.remotehome)
        }
        if self.addlocalhome.stringValue.isEmpty == false {
            if self.assist?.localhome == nil { self.assist?.localhome = Set() }
            self.assist?.localhome?.insert(self.addlocalhome.stringValue)
            self.initcomboxes(combobox: self.combolocalhome, values: self.assist?.localhome)
        }
        if self.addcatalogs.stringValue.isEmpty == true {
            if self.assist?.catalogs == nil { self.assist?.catalogs = Set() }
            self.assist?.catalogs?.insert(self.addcatalogs.stringValue)
            self.initcomboxes(combobox: self.combocatalogs, values: self.assist?.catalogs)
        }
        self.resetstringvalues()
    }

    @IBAction func deletevalue(_: NSButton) {
        switch self.assistedit {
        case .catalogs:
            self.assist?.catalogs?.remove(self.combocatalogs.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.combocatalogs, values: self.assist?.catalogs)
        case .localhome:
            self.assist?.localhome?.remove(self.combolocalhome.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.combolocalhome, values: self.assist?.localhome)
        case .remotehome:
            self.assist?.remotehome?.remove(self.comboremotehome.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.comboremotehome, values: self.assist?.remotehome)
        case .remoteusers:
            self.assist?.remoteusers?.remove(self.comboremoteusers.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.comboremoteusers, values: self.assist?.remoteusers)
        case .remotecomputers:
            self.assist?.remotecomputers?.remove(self.comboremotecomputers.objectValue as? String ?? "")
            self.initcomboxes(combobox: self.comboremotecomputers, values: self.assist?.remotecomputers)
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
        self.assist = Assist()
        if let assist = self.assist?.assist {
            guard assist.count == 5 else { return }
            self.initcomboxes(combobox: self.comboremotecomputers, values: assist[0])
            self.initcomboxes(combobox: self.comboremoteusers, values: assist[1])
            self.initcomboxes(combobox: self.comboremotehome, values: assist[2])
            self.initcomboxes(combobox: self.combocatalogs, values: assist[3])
            self.initcomboxes(combobox: self.combolocalhome, values: assist[4])
        }
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
