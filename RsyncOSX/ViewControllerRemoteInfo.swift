//
//  ViewControllerQuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

protocol OpenQuickBackup: AnyObject {
    func openquickbackup()
}

class ViewControllerRemoteInfo: NSViewController, SetDismisser, Abort, Setcolor {
    @IBOutlet var mainTableView: NSTableView!
    @IBOutlet var progress: NSProgressIndicator!
    @IBOutlet var executebutton: NSButton!
    @IBOutlet var abortbutton: NSButton!
    @IBOutlet var count: NSTextField!

    private var remoteinfotask: RemoteinfoEstimation?
    weak var remoteinfotaskDelegate: SetRemoteInfo?
    var selected: Bool = false
    var loaded: Bool = false
    var diddissappear: Bool = false

    @IBAction func execute(_: NSButton) {
        if let backup = self.dobackups() {
            if backup.count > 0 {
                self.remoteinfotask?.setbackuplist(list: backup)
                weak var openDelegate: OpenQuickBackup?
                if (self.presentingViewController as? ViewControllerMain) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                } else if (self.presentingViewController as? ViewControllerSchedule) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
                } else if (self.presentingViewController as? ViewControllerNewConfigurations) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
                } else if (self.presentingViewController as? ViewControllerRestore) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
                } else if (self.presentingViewController as? ViewControllerSsh) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
                } else if (self.presentingViewController as? ViewControllerVerify) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcverify) as? ViewControllerVerify
                } else if (self.presentingViewController as? ViewControllerLoggData) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
                } else if (self.presentingViewController as? ViewControllerSnapshots) != nil {
                    openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
                }
                openDelegate?.openquickbackup()
            }
        }
        self.closeview()
    }

    // Either abort or close
    @IBAction func abort(_: NSButton) {
        if self.remoteinfotask?.stackoftasktobeestimated?.count ?? 0 > 0 {
            self.abort()
            self.remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: nil)
        }
        self.closeview()
    }

    private func closeview() {
        if (self.presentingViewController as? ViewControllerMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presentingViewController as? ViewControllerSchedule) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabschedule)
        } else if (self.presentingViewController as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcnewconfigurations)
        } else if (self.presentingViewController as? ViewControllerRestore) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcrestore)
        } else if (self.presentingViewController as? ViewControllerSnapshots) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        } else if (self.presentingViewController as? ViewControllerSsh) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcssh)
        } else if (self.presentingViewController as? ViewControllerVerify) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcverify)
        } else if (self.presentingViewController as? ViewControllerLoggData) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcremoteinfo, nsviewcontroller: self)
        self.remoteinfotaskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if let remoteinfotask = self.remoteinfotaskDelegate?.getremoteinfo() {
            self.remoteinfotask = remoteinfotask
            self.loaded = true
            self.progress.isHidden = true
        } else {
            self.remoteinfotask = RemoteinfoEstimation(viewcontroller: self)
            self.remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: self.remoteinfotask)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else {
            globalMainQueue.async { () -> Void in
                self.mainTableView.reloadData()
            }
            return
        }
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
        self.count.stringValue = self.number()
        self.enableexecutebutton()
        if self.loaded == false {
            self.initiateProgressbar()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func number() -> String {
        if self.loaded {
            return NSLocalizedString("Loaded cached data...", comment: "Remote info")
        } else {
            let max = self.remoteinfotask?.maxCount() ?? 0
            return NSLocalizedString("Number of tasks to estimate:", comment: "Remote info") + " " + String(describing: max)
        }
    }

    private func dobackups() -> [NSMutableDictionary]? {
        let backup = self.remoteinfotask?.records?.filter { $0.value(forKey: "select") as? Int == 1 }
        return backup
    }

    private func enableexecutebutton() {
        if let backup = self.dobackups() {
            if backup.count > 0 {
                self.executebutton.isEnabled = true
            } else {
                self.executebutton.isEnabled = false
            }
        } else {
            self.executebutton.isEnabled = false
        }
    }

    private func initiateProgressbar() {
        self.progress.maxValue = Double(self.remoteinfotask?.maxCount() ?? 0)
        self.progress.minValue = 0
        self.progress.doubleValue = 0
        self.progress.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        self.progress.doubleValue = value
    }
}

extension ViewControllerRemoteInfo: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.remoteinfotask?.records?.count ?? 0
    }
}

extension ViewControllerRemoteInfo: NSTableViewDelegate, Attributedestring {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.remoteinfotask?.records != nil else { return nil }
        guard row < (self.remoteinfotask!.records?.count)! else { return nil }
        let object: NSDictionary = (self.remoteinfotask?.records?[row])!
        switch tableColumn!.identifier.rawValue {
        case "transferredNumber":
            let celltext = object[tableColumn!.identifier] as? String
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case "transferredNumberSizebytes":
            let celltext = object[tableColumn!.identifier] as? String
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case "newfiles":
            let celltext = object[tableColumn!.identifier] as? String
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case "deletefiles":
            let celltext = object[tableColumn!.identifier] as? String
            return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case "select":
            return object[tableColumn!.identifier] as? Int
        default:
            return object[tableColumn!.identifier] as? String
        }
    }

    // Toggling selection
    func tableView(_: NSTableView, setObjectValue _: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard self.remoteinfotask?.records != nil else { return }
        if tableColumn!.identifier.rawValue == "select" {
            var select: Int = self.remoteinfotask?.records![row].value(forKey: "select") as? Int ?? 0
            if select == 0 { select = 1 } else if select == 1 { select = 0 }
            self.remoteinfotask?.records![row].setValue(select, forKey: "select")
        }
        self.enableexecutebutton()
    }
}

extension ViewControllerRemoteInfo: UpdateProgress {
    func processTermination() {
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
        let progress = Double(self.remoteinfotask?.maxCount() ?? 0) - Double(self.remoteinfotask?.inprogressCount() ?? 0)
        self.updateProgressbar(progress)
    }

    func fileHandler() {
        //
    }
}

extension ViewControllerRemoteInfo: StartStopProgressIndicator {
    func start() {
        //
    }

    func stop() {
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
        self.progress.stopAnimation(nil)
        self.progress.isHidden = true
        self.count.stringValue = NSLocalizedString("Completed", comment: "Remote info")
        self.count.textColor = setcolor(nsviewcontroller: self, color: .green)
        self.selected = true
        self.enableexecutebutton()
    }

    func complete() {
        //
    }
}
