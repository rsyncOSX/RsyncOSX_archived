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

protocol QuickBackupCompleted: AnyObject {
    func quickbackupcompleted()
}

class ViewControllerQuickBackup: NSViewController, SetDismisser, Abort, Delay, Setcolor {
    var seconds: Int?
    var row: Int?
    var filterby: Sortandfilter?
    var quickbackup: QuickBackup?
    var executing: Bool = true
    weak var inprogresscountDelegate: Count?
    var max: Double?
    var maxInt: Int?
    var diddissappear: Bool = false
    var indexinitiated: Int = -1

    @IBOutlet var mainTableView: NSTableView!
    @IBOutlet var abortbutton: NSButton!
    @IBOutlet var completed: NSTextField!
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var numberoffilestodo: NSTextField!

    // Either abort or close
    @IBAction func abort(_: NSButton) {
        if self.executing {
            self.quickbackup = nil
            self.abort()
            self.working.stopAnimation(nil)
        }
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
        self.inprogresscountDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        ViewControllerReference.shared.setvcref(viewcontroller: .vcquickbackup, nsviewcontroller: self)
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.working.usesThreadedAnimation = true
        self.completed.isHidden = true
        self.quickbackup = QuickBackup()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else {
            globalMainQueue.async { () -> Void in
                self.mainTableView.reloadData()
            }
            return
        }
        guard self.quickbackup?.sortedlist?.count ?? 0 > 0 else {
            self.completed.isHidden = false
            self.completed.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.completed.stringValue = NSLocalizedString("There seems to be nothing to do...", comment: "Quickbackup")
            self.executing = false
            return
        }
        self.quickbackup?.prepareandstartexecutetasks()
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
        self.working.isHidden = false
        self.working.startAnimation(nil)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func initiateProgressbar(progress: NSProgressIndicator) {
        progress.isHidden = false
        if let calculatedNumberOfFiles = self.quickbackup?.maxcount {
            progress.maxValue = Double(calculatedNumberOfFiles)
            self.max = Double(calculatedNumberOfFiles)
            self.maxInt = calculatedNumberOfFiles
            self.numberoffilestodo.isHidden = false
        }
        progress.minValue = 0
        progress.doubleValue = 0
        progress.startAnimation(self)
    }

    private func updateProgressbar(progress: NSProgressIndicator) {
        let value = Double((self.inprogresscountDelegate?.inprogressCount())!)
        progress.doubleValue = value
        let filestodo = (self.maxInt ?? 0) + 16 - (self.inprogresscountDelegate?.inprogressCount() ?? 0)
        if filestodo >= 0 {
            self.numberoffilestodo.stringValue = String(filestodo)
        } else {
            self.numberoffilestodo.isHidden = true
        }
    }
}

extension ViewControllerQuickBackup: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.quickbackup?.sortedlist?.count ?? 0
    }
}

extension ViewControllerQuickBackup: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard self.quickbackup?.sortedlist != nil else { return nil }
        guard row < self.quickbackup!.sortedlist!.count else { return nil }
        let object: NSDictionary = self.quickbackup!.sortedlist![row]
        let hiddenID = object.value(forKey: "hiddenID") as? Int
        let cellIdentifier: String = tableColumn!.identifier.rawValue
        if cellIdentifier == "percentCellID" {
            if let cell: NSProgressIndicator = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSProgressIndicator {
                if hiddenID == self.quickbackup?.hiddenID {
                    if row > self.indexinitiated {
                        self.indexinitiated = row
                        self.initiateProgressbar(progress: cell)
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

extension ViewControllerQuickBackup: Reloadandrefresh {
    func reloadtabledata() {
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }
}

extension ViewControllerQuickBackup: ReportonandhaltonError {
    func reportandhaltonerror() {
        self.quickbackup = nil
        self.abort()
        self.working.stopAnimation(nil)
        self.completed.isHidden = false
        self.completed.stringValue = "Error"
        self.completed.textColor = setcolor(nsviewcontroller: self, color: .red)
    }
}

extension ViewControllerQuickBackup: QuickBackupCompleted {
    func quickbackupcompleted() {
        self.completed.isHidden = false
        self.completed.textColor = setcolor(nsviewcontroller: self, color: .green)
        self.working.stopAnimation(nil)
        self.executing = false
    }
}
