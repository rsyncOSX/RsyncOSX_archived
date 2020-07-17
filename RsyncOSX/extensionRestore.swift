//
//  extensionRestore.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/02/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Cocoa
import Foundation

extension ViewControllerRestore: NSSearchFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        if (notification.object as? NSTextField)! == self.search {
            self.delayWithSeconds(0.25) {
                if self.search.stringValue.isEmpty {
                    globalMainQueue.async { () -> Void in
                        if let index = self.index {
                            if let hiddenID = self.configurations!.getConfigurationsDataSourceSynchronize()![index].value(forKey: "hiddenID") as? Int {
                                self.remotefilelist = Remotefilelist(hiddenID: hiddenID)
                            }
                        }
                    }
                } else {
                    globalMainQueue.async { () -> Void in
                        self.restoretabledata = self.restoretabledata!.filter { $0.contains(self.search.stringValue) }
                        self.restoretableView.reloadData()
                    }
                }
            }
        }
    }

    func searchFieldDidEndSearching(_: NSSearchField) {
        if let index = self.index {
            if self.configurations!.getConfigurationsDataSourceSynchronize()![index].value(forKey: "hiddenID") as? Int != nil {
                self.working.startAnimation(nil)
            }
        }
    }
}

extension ViewControllerRestore: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.restoretableView {
            guard self.restoretabledata != nil else {
                self.info.textColor = setcolor(nsviewcontroller: self, color: .red)
                return 0
            }
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = NSLocalizedString("Number of remote files:", comment: "Restore") + " " + NumberFormatter.localizedString(from: NSNumber(value: self.restoretabledata?.count ?? 0), number: NumberFormatter.Style.decimal)
            return self.restoretabledata!.count
        } else {
            return self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
        }
    }
}

extension ViewControllerRestore: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == self.restoretableView {
            guard self.restoretabledata != nil else { return nil }
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "files"), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = self.restoretabledata?[row] ?? ""
                return cell
            }
        } else {
            guard row < self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? -1 else { return nil }
            let object: NSDictionary = self.configurations!.getConfigurationsDataSourceSynchronize()![row]
            let cellIdentifier: String = tableColumn!.identifier.rawValue
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                return cell
            }
        }
        return nil
    }
}

extension ViewControllerRestore: UpdateProgress {
    func processTermination() {
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.processTermination()
            self.reset()
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = NSLocalizedString("Restore completed...", comment: "Restore")
        } else {
            let number = Numbers(outputprocess: self.outputprocess)
            self.maxcount = number.getTransferredNumbers(numbers: .transferredNumber)
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = NSLocalizedString("Number of remote files:", comment: "Restore") + " " + NumberFormatter.localizedString(from: NSNumber(value: self.maxcount), number: NumberFormatter.Style.decimal) + ", " + NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumberSizebytes)), number: NumberFormatter.Style.decimal) + " kB"
            self.restoreisverified.image = #imageLiteral(resourceName: "green")
            self.restoreactions?.estimated = true
        }
        self.working.stopAnimation(nil)
    }

    func fileHandler() {
        if self.outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.fileHandler()
        }
    }
}

extension ViewControllerRestore: Count {
    func maxCount() -> Int {
        return self.maxcount
    }

    func inprogressCount() -> Int {
        return self.outputprocess?.count() ?? 0
    }
}

extension ViewControllerRestore: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        _ = InterruptProcess()
        self.reset()
    }
}

extension ViewControllerRestore: TemporaryRestorePath {
    func temporaryrestorepath() {
        self.settmprestorepathfromuserconfig()
    }
}

extension ViewControllerRestore: NewProfile {
    func newprofile(profile _: String?, selectedindex: Int?) {
        if let index = selectedindex {
            self.profilepopupbutton.selectItem(at: index)
        } else {
            self.initpopupbutton()
        }
        self.restoretabledata = nil
        self.reset()
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
            self.rsynctableView.reloadData()
        }
    }

    func reloadprofilepopupbutton() {
        //
    }
}

extension ViewControllerRestore: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerRestore: Updateremotefilelist {
    func updateremotefilelist() {
        self.restoretabledata = self.remotefilelist?.remotefilelist
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
        }
        self.working.stopAnimation(nil)
        self.remotefilelist = nil
    }
}
