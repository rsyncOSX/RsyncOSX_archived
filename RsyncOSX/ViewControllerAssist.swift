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
    @IBOutlet var comboremotehome: NSComboBox!
    @IBOutlet var comboremotecomputers: NSComboBox!
    @IBOutlet var combocatalogs: NSComboBox!
    @IBOutlet var combolocalhome: NSComboBox!

    @IBAction func closeview(_: NSButton) {
        self.view.window?.close()
    }

    @IBAction func rescan(_: NSButton) {
        self.initialize(reset: true)
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
        self.initialize(reset: false)
        self.transferdataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        if self.assist?.dirty ?? true {
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

    private func initialize(reset: Bool) {
        self.assist = Assist(reset: reset)
        if let assist = self.assist {
            self.initcomboxes(combobox: self.comboremotecomputers, values: assist.remoteservers)
            self.initcomboxes(combobox: self.comboremoteusers, values: assist.remoteusers)
            self.initcomboxes(combobox: self.comboremotehome, values: assist.remotehome)
            self.initcomboxes(combobox: self.combocatalogs, values: assist.catalogs)
            self.initcomboxes(combobox: self.combolocalhome, values: assist.localhome)
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
