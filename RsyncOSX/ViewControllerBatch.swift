//
//  ViewControllerBatch.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 25/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

// Return the created batchobject
protocol GetNewBatchTask: class {
    func getbatchtaskObject() -> BatchTask?
}

// Dismiss view when rsync error
protocol CloseViewError: class {
    func closeerror()
}

protocol Attributedestring: class {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString
}

extension Attributedestring {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: str)
        let range = (str as NSString).range(of: str)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        attributedString.setAlignment(align, range: range)
        return attributedString
    }
}

class ViewControllerBatch: NSViewController, SetDismisser, AbortTask {

    var row: Int?
    var batchTask: BatchTask?
    var diddissappear: Bool = false
    private var remoteinfotask: RemoteInfoTaskWorkQueue?
    weak var remoteinfotaskDelegate: SetRemoteInfo?
    weak var inprogresscountDelegate: Count?
    var indexinitiated: Int = -1
    var max: Double?
    var batchisrunning: Bool?

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet weak var abortbutton: NSButton!

    // Either abort or close
    @IBAction func abort(_ sender: NSButton) {
        if self.batchisrunning! == true {
            self.abort()
        }
        self.batchTask!.closeOperation()
        self.batchTask = nil
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Execute batch
    @IBAction func execute(_ sender: NSButton) {
        self.batchisrunning = true
        self.batchTask!.executeBatch()
        self.executeButton.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcbatch, nsviewcontroller: self)
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.batchTask = BatchTask()
        self.batchisrunning = false
        self.batchTask?.configurations?.createbatchQueue()
        self.executeButton.isEnabled = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
            return
        }
        self.executeButton.isEnabled = true
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        self.remoteinfotaskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.remoteinfotask = RemoteInfoTaskWorkQueue(inbatch: true)
        self.remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: self.remoteinfotask)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func initiateProgressbar(progress: NSProgressIndicator, hiddenID: Int) {
        progress.isHidden = false
        if let calculatedNumberOfFiles = self.batchTask?.maxcount(hiddenID: hiddenID) {
            progress.maxValue = Double(calculatedNumberOfFiles)
            self.max = Double(calculatedNumberOfFiles)
        }
        progress.minValue = 0
        progress.doubleValue = 0
        progress.startAnimation(self)
    }

    private func updateProgressbar(progress: NSProgressIndicator) {
        let value = Double(self.batchTask?.incount() ?? 0)
        progress.doubleValue = value
    }

}

extension ViewControllerBatch: NSTableViewDataSource {
        // Delegate for size of table
        func numberOfRows(in tableView: NSTableView) -> Int {
            return self.batchTask?.configurations?.batchQueuecount() ?? 0
    }
}

extension ViewControllerBatch: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard  self.batchTask?.configurations?.getupdatedbatchQueue() != nil else { return nil }
        guard row < self.batchTask!.configurations!.getupdatedbatchQueue()!.count else { return nil }
        let object: NSMutableDictionary = (self.batchTask?.configurations!.getupdatedbatchQueue()![row])!
        let hiddenID = object.value(forKey: "hiddenID") as? Int
        let cellIdentifier: String = tableColumn!.identifier.rawValue
        if cellIdentifier == "percentCellID" {
            guard self.batchisrunning! == true else { return nil}
            if let cell: NSProgressIndicator = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSProgressIndicator {
                if hiddenID == self.batchTask?.hiddenID {
                    if row > self.indexinitiated {
                        self.indexinitiated = row
                        self.initiateProgressbar(progress: cell, hiddenID: hiddenID!)
                    } else {
                        self.updateProgressbar(progress: cell)
                    }
                    return cell
                } else {
                    return nil
                }
            }
        } else {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                return cell
            }
        }
        return nil
    }
}

extension ViewControllerBatch: StartStopProgressIndicator {

    func stop() {
        self.executeButton.isEnabled = true
    }

    func start() {
       self.executeButton.isEnabled = false
    }

    func complete() {
    }
}

extension ViewControllerBatch: GetNewBatchTask {

    func getbatchtaskObject() -> BatchTask? {
        return self.batchTask
    }
}

extension ViewControllerBatch: CloseViewError {
    func closeerror() {
        self.batchTask = nil
        self.abort()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }
}

extension ViewControllerBatch: UpdateProgress {
    func processTermination() {
        //
    }

    func fileHandler() {
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}
