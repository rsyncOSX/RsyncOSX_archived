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

protocol AssistTransfer: AnyObject {
    func assisttransfer(values: [String]?)
}

class ViewControllerAssist: NSViewController {
    var assist: Assist?
    weak var transferdataDelegate: AssistTransfer?

    @IBOutlet var comboremoteusers: NSComboBox!
    @IBOutlet var comboremotecomputers: NSComboBox!
    @IBOutlet var combocatalogs: NSComboBox!
    @IBOutlet var combolocalhome: NSComboBox!

    @IBAction func closeview(_: NSButton) {
        self.view.window?.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
        self.transferdataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
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
           let user = self.comboremoteusers.objectValue as? String,
           let remotecomputer = self.comboremotecomputers.objectValue as? String
        {
            var transfer = [String]()
            transfer.append(home + "/" + catalog)
            transfer.append("~/" + catalog)
            transfer.append(user)
            transfer.append(remotecomputer)
            self.transferdataDelegate?.assisttransfer(values: transfer)
            self.view.window?.close()
        }
    }

    @IBAction func addlocal(_: NSButton) {
        if let home = self.combolocalhome.objectValue as? String,
           let catalog = self.combocatalogs.objectValue as? String
        {
            var transfer = [String]()
            transfer.append(home + "/" + catalog)
            transfer.append("/mounted_Volume/" + catalog)
            self.transferdataDelegate?.assisttransfer(values: transfer)
            self.view.window?.close()
        }
    }

    private func initialize() {
        self.assist = Assist()
        if let assist = self.assist {
            self.initcomboxes(combobox: self.comboremotecomputers, values: assist.remoteservers)
            self.initcomboxes(combobox: self.comboremoteusers, values: assist.remoteusers)
            self.initcomboxes(combobox: self.combocatalogs, values: assist.catalogs)
            self.initcomboxes(combobox: self.combolocalhome, values: assist.localhome)
        }
    }
}
