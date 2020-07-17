//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length function_body_length cyclomatic_complexity

import Cocoa
import Foundation

protocol CloseEdit: Any {
    func closeview()
}

class ViewControllerEdit: NSViewController, SetConfigurations, SetDismisser, Index, Delay {
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
    var singleFile: Bool = false

    @IBAction func enabledisableresetsnapshotnum(_: NSButton) {
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        guard config.task == "snapshot" else { return }
        let info: String = NSLocalizedString("Dont change the snapshot num if you don´t know what you are doing...", comment: "Snapshots")
        Alerts.showInfo(info: info)
        if self.snapshotnum.isEnabled {
            self.snapshotnum.isEnabled = false
        } else {
            self.snapshotnum.isEnabled = true
        }
    }

    // Close and dismiss view
    @IBAction func close(_: NSButton) {
        self.view.window?.close()
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_: NSButton) {
        var config: [Configuration] = self.configurations?.getConfigurations() ?? []
        guard config.count > 0 else { return }
        if self.localCatalog.stringValue.hasSuffix("/") == false, self.singleFile == false {
            self.localCatalog.stringValue += "/"
        }
        if let index = self.index() {
            config[index].localCatalog = self.localCatalog.stringValue
            if self.offsiteCatalog.stringValue.hasSuffix("/") == false {
                self.offsiteCatalog.stringValue += "/"
            }
            config[index].offsiteCatalog = self.offsiteCatalog.stringValue
            config[index].offsiteServer = self.offsiteServer.stringValue
            config[index].offsiteUsername = self.offsiteUsername.stringValue
            config[index].backupID = self.backupID.stringValue
            if self.snapshotnum.stringValue.count > 0 {
                config[index].snapshotnum = Int(self.snapshotnum.stringValue)
            }
            // Pre task
            if self.pretask.stringValue.isEmpty == false {
                if self.executepretask.state == .on {
                    config[index].executepretask = 1
                } else {
                    config[index].executepretask = 0
                }
                config[index].pretask = self.pretask.stringValue
            } else {
                config[index].executepretask = nil
                config[index].pretask = nil
            }
            // Post task
            if self.posttask.stringValue.isEmpty == false {
                if self.executeposttask.state == .on {
                    config[index].executeposttask = 1
                } else {
                    config[index].executeposttask = 0
                }
                config[index].posttask = self.posttask.stringValue
            } else {
                config[index].executeposttask = nil
                config[index].posttask = nil
            }
            // Halt on error
            if self.haltshelltasksonerror.state == .on {
                config[index].haltshelltasksonerror = 1
            } else {
                config[index].haltshelltasksonerror = 0
            }

            let dict = ConvertOneConfig(config: config[index]).dict
            guard Validatenewconfigs(dict: dict, Edit: true).validated == true else { return }
            self.configurations?.updateConfigurations(config[index], index: index)
            self.view.window?.close()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.snapshotnum.delegate = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Check if there is another view open, if yes close it..
        if let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcedit) as? ViewControllerEdit {
            weak var closeview: ViewControllerEdit?
            closeview = view
            closeview?.closeview()
        }
        ViewControllerReference.shared.setvcref(viewcontroller: .vcedit, nsviewcontroller: self)
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.pretask.stringValue = ""
        self.executepretask.state = .off
        self.posttask.stringValue = ""
        self.executeposttask.state = .off
        self.haltshelltasksonerror.state = .off
        if let index = self.index() {
            self.index = index
            if let config: Configuration = self.configurations?.getConfigurations()[index] {
                self.localCatalog.stringValue = config.localCatalog
                if self.localCatalog.stringValue.hasSuffix("/") == false {
                    self.singleFile = true
                } else {
                    self.singleFile = false
                }
                self.offsiteCatalog.stringValue = config.offsiteCatalog
                self.offsiteUsername.stringValue = config.offsiteUsername
                self.offsiteServer.stringValue = config.offsiteServer
                self.backupID.stringValue = config.backupID
                if let snapshotnum = config.snapshotnum {
                    self.snapshotnum.stringValue = String(snapshotnum)
                }
                self.pretask.stringValue = config.pretask ?? ""
                self.posttask.stringValue = config.posttask ?? ""
                if let executepretask = config.executepretask {
                    if executepretask == 1 {
                        self.executepretask.state = .on
                    } else {
                        self.executepretask.state = .off
                    }
                } else {
                    self.executepretask.state = .off
                }
                if let executeposttask = config.executeposttask {
                    if executeposttask == 1 {
                        self.executeposttask.state = .on
                    } else {
                        self.executeposttask.state = .off
                    }
                } else {
                    self.executeposttask.state = .off
                }
                if let haltshelltasksonerror = config.haltshelltasksonerror {
                    if haltshelltasksonerror == 1 {
                        self.haltshelltasksonerror.state = .on
                    } else {
                        self.haltshelltasksonerror.state = .off
                    }
                }
                self.changelabels()
            }
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcedit, nsviewcontroller: nil)
    }

    private func changelabels() {
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        switch config.task {
        case ViewControllerReference.shared.syncremote:
            self.stringlocalcatalog.stringValue = NSLocalizedString("Source catalog:", comment: "Tooltip")
            self.stringremotecatalog.stringValue = NSLocalizedString("Destination catalog:", comment: "Tooltip")
        default:
            self.stringlocalcatalog.stringValue = NSLocalizedString("Local catalog:", comment: "Tooltip")
            self.stringremotecatalog.stringValue = NSLocalizedString("Remote catalog:", comment: "Tooltip")
        }
    }
}

extension ViewControllerEdit: NSTextFieldDelegate {
    func controlTextDidChange(_: Notification) {
        delayWithSeconds(0.5) {
            if let num = Int(self.snapshotnum.stringValue) {
                let config: Configuration = self.configurations!.getConfigurations()[self.index!]
                guard num < config.snapshotnum ?? 0, num > 0 else {
                    self.snapshotnum.stringValue = String(config.snapshotnum ?? 1)
                    return
                }
            } else {
                let config: Configuration = self.configurations!.getConfigurations()[self.index!]
                self.snapshotnum.stringValue = String(config.snapshotnum ?? 1)
            }
        }
    }
}

extension ViewControllerEdit: CloseEdit {
    func closeview() {
        self.view.window?.close()
    }
}
