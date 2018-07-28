//
//  ViewControllerVerify.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.07.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerVerify: NSViewController, SetConfigurations, GetIndex {

    @IBOutlet weak var outputtable: NSTableView!
    var outputprocess: OutputProcess?
    var index: Int?
    var hiddenID: Int?
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var verifybutton: NSButton!
    @IBOutlet weak var deletedbutton: NSButton!

    @IBAction func verify(_ sender: NSButton) {
        if self.index != nil {
            self.enabledisablebuttons(enable: false)
            self.working.startAnimation(nil)
            let arguments = self.configurations?.arguments4verify(index: self.index!)
            self.outputprocess = OutputProcess()
            let verifytask = VerifyTask(arguments: arguments)
            verifytask.executeProcess(outputprocess: self.outputprocess)
        }
    }

    @IBAction func deleted(_ sender: NSButton) {
        if self.index != nil {
            self.enabledisablebuttons(enable: false)
            self.working.startAnimation(nil)
            let arguments = self.configurations?.arguments4restore(index: self.index!, argtype: .argdryRun)
            self.outputprocess = OutputProcess()
            let verifytask = VerifyTask(arguments: arguments)
            verifytask.executeProcess(outputprocess: self.outputprocess)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcverify, nsviewcontroller: self)
        self.outputtable.delegate = self
        self.outputtable.dataSource = self
        self.working.usesThreadedAnimation = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.index = self.index(viewcontroller: .vctabmain)
    }

    private func enabledisablebuttons(enable: Bool) {
        self.verifybutton.isEnabled = enable
        self.deletedbutton.isEnabled = enable
    }
}

extension ViewControllerVerify: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.outputprocess?.getOutput()?.count ?? 0
    }
}

extension ViewControllerVerify: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if tableColumn == tableView.tableColumns[0] {
            text = self.outputprocess!.getOutput()![row]
            cellIdentifier = "outputID"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

extension ViewControllerVerify: UpdateProgress {
    func processTermination() {
        self.working.stopAnimation(nil)
        self.enabledisablebuttons(enable: true)
    }

    func fileHandler() {
        globalMainQueue.async(execute: { () -> Void in
            self.outputtable.reloadData()
        })
    }
}
