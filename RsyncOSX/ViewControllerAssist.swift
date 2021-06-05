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
        view.window?.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        transferdataDelegate = SharedReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
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
            transferdataDelegate?.assisttransfer(values: transfer)
            view.window?.close()
        }
    }

    @IBAction func addlocal(_: NSButton) {
        if let home = combolocalhome.objectValue as? String,
           let catalog = combocatalogs.objectValue as? String
        {
            var transfer = [String]()
            transfer.append(home + "/" + catalog)
            transfer.append("/mounted_Volume/" + catalog)
            transferdataDelegate?.assisttransfer(values: transfer)
            view.window?.close()
        }
    }

    private func initialize() {
        assist = Assist()
        if let assist = self.assist {
            initcomboxes(combobox: comboremotecomputers, values: assist.remoteservers)
            initcomboxes(combobox: comboremoteusers, values: assist.remoteusers)
            initcomboxes(combobox: combocatalogs, values: assist.catalogs)
            initcomboxes(combobox: combolocalhome, values: assist.localhome)
        }
    }
}
