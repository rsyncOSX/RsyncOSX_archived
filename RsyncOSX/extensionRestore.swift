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
        if (notification.object as? NSTextField) == search {
            delayWithSeconds(0.25) {
                if self.search.stringValue.isEmpty {
                    globalMainQueue.async { () -> Void in
                        if let index = self.index {
                            if let hiddenID = self.configurations?.getConfigurationsDataSourceSynchronize()?[index].value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int {
                                self.remotefilelist = Remotefilelist(hiddenID: hiddenID)
                            }
                        }
                    }
                } else {
                    globalMainQueue.async { () -> Void in
                        self.restoretabledata = self.restoretabledata?.filter { $0.contains(self.search.stringValue) }
                        self.restoretableView.reloadData()
                    }
                }
            }
        }
    }

    func searchFieldDidEndSearching(_: NSSearchField) {
        if let index = self.index {
            if configurations?.getConfigurationsDataSourceSynchronize()?[index].value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int != nil {
                working.startAnimation(nil)
            }
        }
    }
}

extension ViewControllerRestore: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == restoretableView {
            guard restoretabledata != nil else {
                return 0
            }
            infolabel.stringValue = NSLocalizedString("Number of remote files:", comment: "Restore") + " " + NumberFormatter.localizedString(from: NSNumber(value: restoretabledata?.count ?? 0), number: NumberFormatter.Style.decimal)
            return restoretabledata!.count
        } else {
            return configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
        }
    }
}

extension ViewControllerRestore: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == restoretableView {
            guard restoretabledata != nil else { return nil }
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "files"), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = restoretabledata?[row] ?? ""
                return cell
            }
        } else {
            guard row < configurations?.getConfigurationsDataSourceSynchronize()?.count ?? -1 else { return nil }
            if let object: NSDictionary = configurations?.getConfigurationsDataSourceSynchronize()?[row] {
                let cellIdentifier: String = tableColumn!.identifier.rawValue
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                    return cell
                }
            }
        }
        return nil
    }
}

extension ViewControllerRestore {
    func processtermination() {
        if let vc = SharedReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.processTermination()
            reset()
            infolabel.stringValue = NSLocalizedString("Restore completed...", comment: "Restore")
        } else {
            let number = Numbers(outputprocess: outputprocess)
            maxcount = number.getTransferredNumbers(numbers: .transferredNumber)
            let transferredNumberSizebytes = number.getTransferredNumbers(numbers: .transferredNumberSizebytes)
            if maxcount == 0, transferredNumberSizebytes == 0 {
                infolabel.stringValue = NSLocalizedString("Seems to be nothing to restore", comment: "Restore")
                restoreactions?.estimated = false
            } else {
                infolabel.stringValue = NSLocalizedString("Number of remote files:", comment: "Restore") + " " + NumberFormatter.localizedString(from: NSNumber(value: maxcount), number: NumberFormatter.Style.decimal) + ", size: " + NumberFormatter.localizedString(from: NSNumber(value: transferredNumberSizebytes), number: NumberFormatter.Style.decimal) + " kB"
                restoreactions?.estimated = true
            }
        }
        working.stopAnimation(nil)
    }

    func filehandler() {
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
        if let vc = SharedReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.fileHandler()
        }
    }
}

extension ViewControllerRestore: Count {
    func maxCount() -> Int {
        return maxcount
    }

    func inprogressCount() -> Int {
        return outputprocess?.getOutput()?.count ?? 0
    }
}

extension ViewControllerRestore: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        dismiss(viewcontroller)
        _ = InterruptProcess()
        reset()
    }
}

extension ViewControllerRestore: TemporaryRestorePath {
    func temporaryrestorepath() {
        settmprestorepathfromuserconfig()
    }
}

extension ViewControllerRestore: NewProfile {
    func newprofile(profile _: String?, selectedindex: Int?) {
        if let index = selectedindex {
            profilepopupbutton.selectItem(at: index)
        } else {
            initpopupbutton()
        }
        restoretabledata = nil
        reset()
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
            self.rsynctableView.reloadData()
        }
    }

    func reloadprofilepopupbutton() {}
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
        restoretabledata = remotefilelist?.remotefilelist
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
        }
        working.stopAnimation(nil)
        remotefilelist = nil
    }
}

extension ViewControllerRestore: Sidebarbuttonactions {
    func sidebarbuttonactions(action: Sidebaractionsmessages) {
        switch action {
        case .Filelist:
            goforrestorebyfile()
            getremotefilelist()
        case .Estimate:
            if checkedforfullrestore.state == .on {
                goforfullrestore()
            }
            estimate()
        case .Restore:
            restore()
        case .Reset:
            resetaction()
        default:
            return
        }
    }
}
