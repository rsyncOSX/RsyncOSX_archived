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

    private var remoteestimatedlist: RemoteinfoEstimation?
    weak var remoteinfotaskDelegate: SetRemoteInfo?
    var loaded: Bool = false
    var diddissappear: Bool = false

    @IBAction func execute(_: NSButton) {
        if (remoteestimatedlist?.estimatedlistandconfigs?.estimatedlist?.count ?? 0) > 0 {
            weak var openDelegate: OpenQuickBackup?
            if (presentingViewController as? ViewControllerMain) != nil {
                openDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
            } else if (presentingViewController as? ViewControllerRestore) != nil {
                openDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
            } else if (presentingViewController as? ViewControllerLoggData) != nil {
                openDelegate = SharedReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
            } else if (presentingViewController as? ViewControllerSnapshots) != nil {
                openDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
            }
            openDelegate?.openquickbackup()
        }
        remoteestimatedlist?.abort()
        remoteestimatedlist?.stackoftasktobeestimated = nil
        remoteestimatedlist = nil
        remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: nil)
        closeview()
    }

    // Either abort or close
    @IBAction func abort(_: NSButton) {
        remoteestimatedlist?.abort()
        remoteestimatedlist?.stackoftasktobeestimated = nil
        remoteestimatedlist = nil
        abort()
        remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: nil)
        closeview()
    }

    private func closeview() {
        if (presentingViewController as? ViewControllerMain) != nil {
            dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (presentingViewController as? ViewControllerNewConfigurations) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcnewconfigurations)
        } else if (presentingViewController as? ViewControllerRestore) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcrestore)
        } else if (presentingViewController as? ViewControllerSnapshots) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        } else if (presentingViewController as? ViewControllerSsh) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcssh)
        } else if (presentingViewController as? ViewControllerLoggData) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        SharedReference.shared.setvcref(viewcontroller: .vcremoteinfo, nsviewcontroller: self)
        if let remoteinfotask = remoteinfotaskDelegate?.getremoteinfo() {
            remoteestimatedlist = remoteinfotask
            loaded = true
            progress.isHidden = true
        } else {
            remoteestimatedlist = RemoteinfoEstimation(viewcontroller: self, processtermination: processtermination)
            remoteinfotaskDelegate?.setremoteinfo(remoteinfotask: remoteestimatedlist)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard diddissappear == false else {
            globalMainQueue.async { () in
                self.mainTableView.reloadData()
            }
            return
        }
        globalMainQueue.async { () in
            self.mainTableView.reloadData()
        }
        count.stringValue = number()
        enableexecutebutton()
        if loaded == false {
            initiateProgressbar()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        diddissappear = true
        // Release the estimating object
        remoteestimatedlist?.abort()
        remoteestimatedlist = nil
    }

    private func number() -> String {
        if loaded {
            return NSLocalizedString("Loaded cached data...", comment: "Remote info")
        } else {
            let max = remoteestimatedlist?.maxCount() ?? 0
            return NSLocalizedString("Number of tasks to estimate:", comment: "Remote info") + " " + String(describing: max)
        }
    }

    private func dobackups() -> [NSMutableDictionary]? {
        let backup = remoteestimatedlist?.records?.filter { $0.value(forKey: DictionaryStrings.select.rawValue) as? Int == 1 }
        return backup
    }

    private func enableexecutebutton() {
        if let backup = dobackups() {
            if backup.count > 0 {
                executebutton.isEnabled = true
            } else {
                executebutton.isEnabled = false
            }
        } else {
            executebutton.isEnabled = false
        }
    }

    private func initiateProgressbar() {
        progress.maxValue = Double(remoteestimatedlist?.maxCount() ?? 0)
        progress.minValue = 0
        progress.doubleValue = 0
        progress.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        progress.doubleValue = value
    }
}

extension ViewControllerRemoteInfo: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return remoteestimatedlist?.records?.count ?? 0
    }
}

extension ViewControllerRemoteInfo: NSTableViewDelegate, Attributedestring {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard remoteestimatedlist?.records != nil else { return nil }
        guard row < (remoteestimatedlist!.records?.count)! else { return nil }
        let object: NSDictionary = (remoteestimatedlist?.records?[row])!
        switch tableColumn!.identifier.rawValue {
        case DictionaryStrings.transferredNumber.rawValue:
            let celltext = object[tableColumn!.identifier] as? String
            return attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case DictionaryStrings.transferredNumberSizebytes.rawValue:
            let celltext = object[tableColumn!.identifier] as? String
            return attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case DictionaryStrings.newfiles.rawValue:
            let celltext = object[tableColumn!.identifier] as? String
            return attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case DictionaryStrings.deletefiles.rawValue:
            let celltext = object[tableColumn!.identifier] as? String
            return attributedstring(str: celltext!, color: NSColor.red, align: .right)
        case DictionaryStrings.select.rawValue:
            return object[tableColumn!.identifier] as? Int
        default:
            return object[tableColumn!.identifier] as? String
        }
    }

    // Toggling selection
    func tableView(_: NSTableView, setObjectValue _: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard remoteestimatedlist?.records != nil else { return }
        if tableColumn!.identifier.rawValue == DictionaryStrings.select.rawValue {
            var select: Int = remoteestimatedlist?.records![row].value(forKey: DictionaryStrings.select.rawValue) as? Int ?? 0
            if select == 0 { select = 1 } else if select == 1 { select = 0 }
            remoteestimatedlist?.records![row].setValue(select, forKey: DictionaryStrings.select.rawValue)
        }
        enableexecutebutton()
    }
}

extension ViewControllerRemoteInfo {
    func processtermination() {
        globalMainQueue.async { () in
            self.mainTableView.reloadData()
        }
        let progress = Double(remoteestimatedlist?.maxCount() ?? 0) - Double(remoteestimatedlist?.inprogressCount() ?? 0)
        updateProgressbar(progress)
    }
}

extension ViewControllerRemoteInfo: StartStopProgressIndicator {
    func start() {
        //
    }

    func stop() {
        globalMainQueue.async { () in
            self.mainTableView.reloadData()
        }
        progress.stopAnimation(nil)
        progress.isHidden = true
        count.stringValue = NSLocalizedString("Estimation completed", comment: "Remote info") + "..."
        count.textColor = setcolor(nsviewcontroller: self, color: .green)
        enableexecutebutton()
    }
}
