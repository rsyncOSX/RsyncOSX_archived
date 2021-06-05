//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length function_body_length

import Cocoa
import Foundation

protocol CloseEdit: Any {
    func closeview()
}

class ViewControllerEdit: NSViewController, SetConfigurations, Index, Delay {
    @IBOutlet var localCatalog: NSTextField!
    @IBOutlet var offsiteCatalog: NSTextField!
    @IBOutlet var offsiteUsername: NSTextField!
    @IBOutlet var offsiteServer: NSTextField!
    @IBOutlet var backupID: NSTextField!
    @IBOutlet var snapshotnum: NSTextField!
    @IBOutlet var stringlocalcatalog: NSTextField!
    @IBOutlet var stringremotecatalog: NSTextField!
    @IBOutlet var pretask: NSTextField!
    @IBOutlet var executepretask: NSButton!
    @IBOutlet var posttask: NSTextField!
    @IBOutlet var executeposttask: NSButton!
    @IBOutlet var haltshelltasksonerror: NSButton!

    var index: Int?

    @IBAction func enabledisableresetsnapshotnum(_: NSButton) {
        if let config: Configuration = configurations?.getConfigurations()?[index!] {
            guard config.task == SharedReference.shared.snapshot else { return }
            let info: String = NSLocalizedString("Dont change the snapshot num if you don´t know what you are doing...", comment: "Snapshots")
            Alerts.showInfo(info: info)
            if snapshotnum.isEnabled {
                snapshotnum.isEnabled = false
            } else {
                snapshotnum.isEnabled = true
            }
        }
    }

    // Close and dismiss view
    @IBAction func close(_: NSButton) {
        view.window?.close()
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_: NSButton) {
        if var config: [Configuration] = configurations?.getConfigurations() {
            if let index = self.index() {
                config[index].localCatalog = localCatalog.stringValue
                config[index].offsiteCatalog = offsiteCatalog.stringValue
                config[index].offsiteServer = offsiteServer.stringValue
                config[index].offsiteUsername = offsiteUsername.stringValue
                config[index].backupID = backupID.stringValue
                if snapshotnum.stringValue.count > 0 {
                    config[index].snapshotnum = Int(snapshotnum.stringValue)
                }
                // Pre task
                if pretask.stringValue.isEmpty == false {
                    if executepretask.state == .on {
                        config[index].executepretask = 1
                    } else {
                        config[index].executepretask = 0
                    }
                    config[index].pretask = pretask.stringValue
                } else {
                    config[index].executepretask = nil
                    config[index].pretask = nil
                }
                // Post task
                if posttask.stringValue.isEmpty == false {
                    if executeposttask.state == .on {
                        config[index].executeposttask = 1
                    } else {
                        config[index].executeposttask = 0
                    }
                    config[index].posttask = posttask.stringValue
                } else {
                    config[index].executeposttask = nil
                    config[index].posttask = nil
                }
                // Halt on error
                if haltshelltasksonerror.state == .on {
                    config[index].haltshelltasksonerror = 1
                } else {
                    config[index].haltshelltasksonerror = 0
                }
                guard Validatenewconfigs(config[index], false).validated == true else { return }
                configurations?.updateConfigurations(config[index], index: index)
                view.window?.close()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        snapshotnum.delegate = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Check if there is another view open, if yes close it..
        if let view = SharedReference.shared.getvcref(viewcontroller: .vcedit) as? ViewControllerEdit {
            weak var closeview: ViewControllerEdit?
            closeview = view
            closeview?.closeview()
        }
        SharedReference.shared.setvcref(viewcontroller: .vcedit, nsviewcontroller: self)
        localCatalog.stringValue = ""
        offsiteCatalog.stringValue = ""
        offsiteUsername.stringValue = ""
        offsiteServer.stringValue = ""
        backupID.stringValue = ""
        pretask.stringValue = ""
        executepretask.state = .off
        posttask.stringValue = ""
        executeposttask.state = .off
        haltshelltasksonerror.state = .off
        if let index = self.index() {
            self.index = index
            if let config: Configuration = configurations?.getConfigurations()?[index] {
                localCatalog.stringValue = config.localCatalog
                offsiteCatalog.stringValue = config.offsiteCatalog
                offsiteUsername.stringValue = config.offsiteUsername
                offsiteServer.stringValue = config.offsiteServer
                backupID.stringValue = config.backupID
                if let snapshotnum = config.snapshotnum {
                    self.snapshotnum.stringValue = String(snapshotnum)
                }
                pretask.stringValue = config.pretask ?? ""
                posttask.stringValue = config.posttask ?? ""
                if let executepretask = config.executepretask {
                    if executepretask == 1 {
                        self.executepretask.state = .on
                    } else {
                        self.executepretask.state = .off
                    }
                } else {
                    executepretask.state = .off
                }
                if let executeposttask = config.executeposttask {
                    if executeposttask == 1 {
                        self.executeposttask.state = .on
                    } else {
                        self.executeposttask.state = .off
                    }
                } else {
                    executeposttask.state = .off
                }
                if let haltshelltasksonerror = config.haltshelltasksonerror {
                    if haltshelltasksonerror == 1 {
                        self.haltshelltasksonerror.state = .on
                    } else {
                        self.haltshelltasksonerror.state = .off
                    }
                }
                changelabels()
            }
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        SharedReference.shared.setvcref(viewcontroller: .vcedit, nsviewcontroller: nil)
    }

    private func changelabels() {
        if let index = self.index {
            if let config = configurations?.getConfigurations()?[index] {
                switch config.task {
                case SharedReference.shared.syncremote:
                    stringlocalcatalog.stringValue = NSLocalizedString("Source catalog:", comment: "Tooltip")
                    stringremotecatalog.stringValue = NSLocalizedString("Destination catalog:", comment: "Tooltip")
                default:
                    stringlocalcatalog.stringValue = NSLocalizedString("Local catalog:", comment: "Tooltip")
                    stringremotecatalog.stringValue = NSLocalizedString("Remote catalog:", comment: "Tooltip")
                }
            }
        }
    }
}

extension ViewControllerEdit: NSTextFieldDelegate {
    func controlTextDidChange(_: Notification) {
        delayWithSeconds(0.5) {
            if let index = self.index {
                if let config = self.configurations?.getConfigurations()?[index] {
                    if let num = Int(self.snapshotnum.stringValue) {
                        guard num < config.snapshotnum ?? 0, num > 0 else {
                            self.snapshotnum.stringValue = String(config.snapshotnum ?? 1)
                            return
                        }
                    } else {
                        self.snapshotnum.stringValue = String(config.snapshotnum ?? 1)
                    }
                }
            }
        }
    }
}

// Needed for automatically close view if another config is selected
extension ViewControllerEdit: CloseEdit {
    func closeview() {
        view.window?.close()
    }
}
