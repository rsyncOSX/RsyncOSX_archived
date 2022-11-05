//
//  ViewControllerSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

protocol Loadsshparameters: AnyObject {
    func loadsshparameters()
}

protocol GetSource: AnyObject {
    func getSourceindex(index: Int)
}

class ViewControllerSsh: NSViewController, SetConfigurations, VcMain, Checkforrsync, Help {
    var sshcmd: Ssh?
    var hiddenID: Int?
    var data: [String]?
    var outputprocess: OutputfromProcess?
    // Send messages to the sidebar
    weak var sidebaractionsDelegate: Sidebaractions?

    @IBOutlet var rsaCheck: NSButton!
    @IBOutlet var detailsTable: NSTableView!
    @IBOutlet var copykeycommand: NSTextField!
    @IBOutlet var sshport: NSTextField!
    @IBOutlet var sshkeypathandidentityfile: NSTextField!
    @IBOutlet var verifykeycommand: NSTextField!

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        presentAsModalWindow(viewControllerProfile!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        help()
    }

    // Sidebar create keys
    func createPublicPrivateRSAKeyPair() {
        outputprocess = OutputfromProcess()
        sshcmd = Ssh(processtermination: processtermination)
        guard sshcmd?.islocalpublicrsakeypresent() ?? true == false else { return }
        sshcmd?.creatersakeypair()
    }

    // Sidebar kilde
    var viewControllerSource: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "CopyFilesID")
            as? NSViewController)
    }

    func source() {
        guard sshcmd != nil else { return }
        presentAsModalWindow(viewControllerSource!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SharedReference.shared.setvcref(viewcontroller: .vcssh, nsviewcontroller: self)
        detailsTable.delegate = self
        detailsTable.dataSource = self
        outputprocess = nil
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        sidebaractionsDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        sidebaractionsDelegate?.sidebaractions(action: .sshviewbuttons)
        loadsshparameters()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        copykeycommand.stringValue = ""
        verifykeycommand.stringValue = ""
    }

    func checkforPrivateandPublicRSAKeypair() {
        sshcmd = Ssh(processtermination: processtermination)
        if sshcmd?.islocalpublicrsakeypresent() ?? false {
            rsaCheck.state = .on
        } else {
            rsaCheck.state = .off
        }
    }

    func copylocalpubrsakeyfile() {
        guard sshcmd?.islocalpublicrsakeypresent() ?? false == true else { return }
        outputprocess = OutputfromProcess()
        sshcmd = Ssh(processtermination: processtermination)
        if let hiddenID = hiddenID {
            sshcmd?.copykeyfile(hiddenID: hiddenID)
            copykeycommand.stringValue = sshcmd?.commandCopyPasteTerminal ?? ""
            sshcmd?.verifyremotekey(hiddenID: hiddenID)
            verifykeycommand.stringValue = sshcmd?.commandCopyPasteTerminal ?? ""
        }
    }
}

extension ViewControllerSsh: GetSource {
    func getSourceindex(index: Int) {
        hiddenID = index
        copylocalpubrsakeyfile()
        loadsshparameters()
    }
}

extension ViewControllerSsh: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return data?.count ?? 0
    }
}

extension ViewControllerSsh: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = data?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}

extension ViewControllerSsh {
    func processtermination(data: [String]?) {
        globalMainQueue.async { () in
            self.checkforPrivateandPublicRSAKeypair()
            self.data = data
            self.detailsTable.reloadData()
        }
    }
}

extension ViewControllerSsh: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        dismiss(viewcontroller)
    }
}

extension ViewControllerSsh: Loadsshparameters {
    func loadsshparameters() {
        sshkeypathandidentityfile.stringValue = SharedReference.shared.sshkeypathandidentityfile ?? ""
        if let sshport = SharedReference.shared.sshport {
            self.sshport.stringValue = String(sshport)
        } else {
            sshport.stringValue = ""
        }
        checkforPrivateandPublicRSAKeypair()
    }
}

extension ViewControllerSsh: Sidebarbuttonactions {
    func sidebarbuttonactions(action: Sidebaractionsmessages) {
        switch action {
        case .CreateKey:
            createPublicPrivateRSAKeyPair()
        case .Remote:
            source()
        default:
            return
        }
    }
}
