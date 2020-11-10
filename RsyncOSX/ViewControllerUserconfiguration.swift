//
//  ViewControllerUserconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length type_body_length cyclomatic_complexity file_length

import Cocoa
import Foundation

protocol MenuappChanged: AnyObject {
    func menuappchanged()
}

class ViewControllerUserconfiguration: NSViewController, NewRsync, Delay, ChangeTemporaryRestorePath {
    var dirty: Bool = false
    weak var reloadconfigurationsDelegate: GetConfigurationsObject?
    weak var reloadschedulesDelegate: GetSchedulesObject?
    weak var menuappDelegate: MenuappChanged?
    weak var loadsshparametersDelegate: Loadsshparameters?
    var oldmarknumberofdayssince: Double?
    var reload: Bool = false
    var nameandpaths: NamesandPaths?
    var jsonischanged: Bool = false

    @IBOutlet var rsyncPath: NSTextField!
    @IBOutlet var version3rsync: NSButton!
    @IBOutlet var detailedlogging: NSButton!
    @IBOutlet var noRsync: NSTextField!
    @IBOutlet var restorePath: NSTextField!
    @IBOutlet var fulllogging: NSButton!
    @IBOutlet var minimumlogging: NSButton!
    @IBOutlet var nologging: NSButton!
    @IBOutlet var marknumberofdayssince: NSTextField!
    @IBOutlet var pathRsyncOSX: NSTextField!
    @IBOutlet var pathRsyncOSXsched: NSTextField!
    @IBOutlet var statuslightpathrsync: NSImageView!
    @IBOutlet var statuslighttemppath: NSImageView!
    @IBOutlet var statuslightpathrsyncosx: NSImageView!
    @IBOutlet var statuslightpathrsyncosxsched: NSImageView!
    @IBOutlet var savebutton: NSButton!
    @IBOutlet var environment: NSTextField!
    @IBOutlet var environmentvalue: NSTextField!
    @IBOutlet var enableenvironment: NSButton!
    @IBOutlet var togglecheckdatabutton: NSButton!
    @IBOutlet var haltonerror: NSButton!
    @IBOutlet var sshport: NSTextField!
    @IBOutlet var sshkeypathandidentityfile: NSTextField!
    @IBOutlet var statuslightsshkeypath: NSImageView!
    @IBOutlet var monitornetworkconnection: NSButton!
    @IBOutlet var json: NSSwitch!
    @IBOutlet var jsonlabel: NSTextField!

    @IBAction func enablejson(_: NSButton) {
        var question: String?
        var checked = false

        var verifyjson: VerifyJSON?
        if let profile = self.reloadconfigurationsDelegate?.getconfigurationsobject()?.profile {
            verifyjson = VerifyJSON(profile: profile)
        } else {
            verifyjson = VerifyJSON(profile: nil)
        }
        if self.json.state == .on { self.jsonlabel.stringValue = "JSON" } else { self.jsonlabel.stringValue = "PLIST" }
        if verifyjson?.verifyconf == true, verifyjson?.verifysched == true {
            checked = true
        } else {
            question = NSLocalizedString("New format is not equal to current.", comment: "Userconfig")
            let text: String = NSLocalizedString("Cancel or Continue?", comment: "Userconfig")
            let dialog: String = NSLocalizedString("Continue", comment: "Userconfig")
            let answer = Alerts.dialogOrCancel(question: question ?? "", text: text, dialog: dialog)
            if answer {
                checked = true
            }
        }
        if self.json.state == .on {
            ViewControllerReference.shared.json = true
            question = NSLocalizedString("Format of config files is about to be changed to JSON.", comment: "Userconfig")
        } else {
            ViewControllerReference.shared.json = false
            question = NSLocalizedString("Format of config files is about to be changed to PLIST.", comment: "Userconfig")
        }
        if self.jsonischanged != ViewControllerReference.shared.json, checked == true {
            let text: String = NSLocalizedString("Cancel or Reboot?", comment: "Userconfig")
            let dialog: String = NSLocalizedString("Reboot", comment: "Userconfig")
            let answer = Alerts.dialogOrCancel(question: question ?? "", text: text, dialog: dialog)
            if answer {
                PersistentStorageUserconfiguration().saveuserconfiguration()
                NSApp.terminate(self)
            }
        }
        ViewControllerReference.shared.json = self.jsonischanged
        if self.jsonischanged {
            self.json.state = .on
        } else {
            self.json.state = .off
            ViewControllerReference.shared.json = self.jsonischanged
            if self.jsonischanged {
                self.json.state = .on
            } else {
                self.json.state = .off
            }
        }
        if self.json.state == .on { self.jsonlabel.stringValue = "JSON" } else { self.jsonlabel.stringValue = "PLIST" }
    }

    @IBAction func copyconfigfiles(_: NSButton) {
        _ = Backupconfigfiles()
        self.view.window?.close()
    }

    @IBAction func togglehaltonerror(_: NSButton) {
        if ViewControllerReference.shared.haltonerror {
            self.haltonerror.state = .off
            ViewControllerReference.shared.haltonerror = false
        } else {
            self.haltonerror.state = .on
            ViewControllerReference.shared.haltonerror = true
        }
        self.setdirty()
    }

    @IBAction func togglecheckdata(_: NSButton) {
        if ViewControllerReference.shared.checkinput {
            self.togglecheckdatabutton.state = .off
            ViewControllerReference.shared.checkinput = false
        } else {
            self.togglecheckdatabutton.state = .on
            ViewControllerReference.shared.checkinput = true
        }
    }

    @IBAction func toggleenableenvironment(_: NSButton) {
        switch self.enableenvironment.state {
        case .on:
            self.environment.isEnabled = true
            self.environmentvalue.isEnabled = true
        case .off:
            self.environment.isEnabled = false
            self.environmentvalue.isEnabled = false
        default:
            return
        }
        self.setdirty()
    }

    @IBAction func toggleversion3rsync(_: NSButton) {
        if self.version3rsync.state == .on {
            ViewControllerReference.shared.rsyncversion3 = true
            if self.rsyncPath.stringValue == "" {
                ViewControllerReference.shared.localrsyncpath = nil
            } else {
                _ = Setrsyncpath(path: self.rsyncPath.stringValue)
            }
        } else {
            ViewControllerReference.shared.rsyncversion3 = false
        }
        self.newrsync()
        self.setdirty()
        self.verifyrsync()
    }

    @IBAction func toggleDetailedlogging(_: NSButton) {
        if self.detailedlogging.state == .on {
            ViewControllerReference.shared.detailedlogging = true
        } else {
            ViewControllerReference.shared.detailedlogging = false
        }
        self.setdirty()
    }

    @IBAction func togglemonitornetworkconnection(_: NSButton) {
        if self.monitornetworkconnection.state == .on {
            ViewControllerReference.shared.monitornetworkconnection = true
        } else {
            ViewControllerReference.shared.monitornetworkconnection = false
        }
        self.setdirty()
    }

    @IBAction func close(_: NSButton) {
        if self.dirty {
            // Before closing save changed configuration
            _ = Setrsyncpath(path: self.rsyncPath.stringValue)
            self.setRestorePath()
            self.setmarknumberofdayssince()
            self.setEnvironment()
            self.setsshparameters()
            PersistentStorageUserconfiguration().saveuserconfiguration()
            if self.reload {
                self.reloadconfigurationsDelegate?.reloadconfigurationsobject()
                self.reloadschedulesDelegate?.reloadschedulesobject()
            }
            self.menuappDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
            self.loadsshparametersDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
            self.menuappDelegate?.menuappchanged()
            self.loadsshparametersDelegate?.loadsshparameters()
            self.changetemporaryrestorepath()
        }
        self.view.window?.close()
        _ = RsyncVersionString()
    }

    @IBAction func logging(_: NSButton) {
        if self.fulllogging.state == .on {
            ViewControllerReference.shared.fulllogging = true
            ViewControllerReference.shared.minimumlogging = false
        } else if self.minimumlogging.state == .on {
            ViewControllerReference.shared.fulllogging = false
            ViewControllerReference.shared.minimumlogging = true
        } else if self.nologging.state == .on {
            ViewControllerReference.shared.fulllogging = false
            ViewControllerReference.shared.minimumlogging = false
        }
        self.setdirty()
    }

    private func setdirty() {
        self.dirty = true
        self.savebutton.title = NSLocalizedString("Save", comment: "Userconfig ")
    }

    private func setmarknumberofdayssince() {
        if let marknumberofdayssince = Double(self.marknumberofdayssince.stringValue) {
            self.oldmarknumberofdayssince = ViewControllerReference.shared.marknumberofdayssince
            ViewControllerReference.shared.marknumberofdayssince = marknumberofdayssince
            if self.oldmarknumberofdayssince != marknumberofdayssince {
                self.reload = true
            }
        }
    }

    private func setRestorePath() {
        if self.restorePath.stringValue.isEmpty == false {
            if restorePath.stringValue.hasSuffix("/") == false {
                restorePath.stringValue += "/"
                ViewControllerReference.shared.temporarypathforrestore = restorePath.stringValue
            } else {
                ViewControllerReference.shared.temporarypathforrestore = restorePath.stringValue
            }
        } else {
            ViewControllerReference.shared.temporarypathforrestore = nil
        }
        self.setdirty()
    }

    private func setEnvironment() {
        if self.environment.stringValue.isEmpty == false {
            guard self.environmentvalue.stringValue.isEmpty == false else { return }
            ViewControllerReference.shared.environment = self.environment.stringValue
            ViewControllerReference.shared.environmentvalue = self.environmentvalue.stringValue
        } else {
            ViewControllerReference.shared.environment = nil
            ViewControllerReference.shared.environmentvalue = nil
        }
    }

    private func verifyrsync() {
        var rsyncpath: String?
        if self.rsyncPath.stringValue.isEmpty == false {
            if self.rsyncPath.stringValue.contains("$HOME") {
                let replaced = self.rsyncPath.stringValue.replacingOccurrences(of: "$HOME",
                                                                               with: self.nameandpaths?.userHomeDirectoryPath ?? "")
                self.rsyncPath.stringValue = replaced
            }
            if self.rsyncPath.stringValue.contains("$home") {
                let replaced = self.rsyncPath.stringValue.replacingOccurrences(of: "$home",
                                                                               with: self.nameandpaths?.userHomeDirectoryPath ?? "")
                self.rsyncPath.stringValue = replaced
            }
            self.statuslightpathrsync.isHidden = false
            if self.rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncpath = self.rsyncPath.stringValue + "/" + ViewControllerReference.shared.rsync
            } else {
                rsyncpath = self.rsyncPath.stringValue + ViewControllerReference.shared.rsync
            }
        } else {
            rsyncpath = nil
        }
        // use stock rsync
        guard self.version3rsync.state == .on else {
            ViewControllerReference.shared.norsync = false
            return
        }
        self.statuslightpathrsync.isHidden = false
        if verifypatexists(pathorfilename: rsyncpath) {
            self.noRsync.isHidden = true
            ViewControllerReference.shared.norsync = false
            self.statuslightpathrsync.image = #imageLiteral(resourceName: "green")
        } else {
            self.noRsync.isHidden = false
            ViewControllerReference.shared.norsync = true
            self.statuslightpathrsync.image = #imageLiteral(resourceName: "red")
        }
    }

    private func verifypathtorsyncosx() {
        var pathtorsyncosx: String?
        self.statuslightpathrsyncosx.isHidden = false
        guard self.pathRsyncOSX.stringValue.isEmpty == false else {
            self.nopathtorsyncosx()
            return
        }
        if self.pathRsyncOSX.stringValue.contains("$HOME") {
            let replaced = self.pathRsyncOSX.stringValue.replacingOccurrences(of: "$HOME",
                                                                              with: self.nameandpaths?.userHomeDirectoryPath ?? "")
            self.pathRsyncOSX.stringValue = replaced
        }
        if self.pathRsyncOSX.stringValue.contains("$home") {
            let replaced = self.pathRsyncOSX.stringValue.replacingOccurrences(of: "$home",
                                                                              with: self.nameandpaths?.userHomeDirectoryPath ?? "")
            self.pathRsyncOSX.stringValue = replaced
        }
        if self.pathRsyncOSX.stringValue.hasSuffix("/") == false {
            pathtorsyncosx = self.pathRsyncOSX.stringValue + "/"
        } else {
            pathtorsyncosx = self.pathRsyncOSX.stringValue
        }
        if verifypatexists(pathorfilename: pathtorsyncosx! + ViewControllerReference.shared.namersyncosx) {
            ViewControllerReference.shared.pathrsyncosx = pathtorsyncosx
            self.statuslightpathrsyncosx.image = #imageLiteral(resourceName: "green")
        } else {
            self.nopathtorsyncosx()
        }
    }

    private func verifypathtorsyncsched() {
        var pathtorsyncosxsched: String?
        self.statuslightpathrsyncosxsched.isHidden = false
        guard self.pathRsyncOSXsched.stringValue.isEmpty == false else {
            self.nopathtorsyncossched()
            return
        }
        if self.pathRsyncOSXsched.stringValue.contains("$HOME") {
            let replaced = self.pathRsyncOSXsched.stringValue.replacingOccurrences(of: "$HOME",
                                                                                   with: self.nameandpaths?.userHomeDirectoryPath ?? "")
            self.pathRsyncOSXsched.stringValue = replaced
        }
        if self.pathRsyncOSXsched.stringValue.contains("$home") {
            let replaced = self.pathRsyncOSXsched.stringValue.replacingOccurrences(of: "$home",
                                                                                   with: self.nameandpaths?.userHomeDirectoryPath ?? "")
            self.pathRsyncOSXsched.stringValue = replaced
        }
        if self.pathRsyncOSXsched.stringValue.hasSuffix("/") == false {
            pathtorsyncosxsched = self.pathRsyncOSXsched.stringValue + "/"
        } else {
            pathtorsyncosxsched = self.pathRsyncOSXsched.stringValue
        }
        if verifypatexists(pathorfilename: pathtorsyncosxsched! + ViewControllerReference.shared.namersyncosssched) {
            ViewControllerReference.shared.pathrsyncosxsched = pathtorsyncosxsched
            self.statuslightpathrsyncosxsched.image = #imageLiteral(resourceName: "green")
        } else {
            self.nopathtorsyncossched()
        }
    }

    private func nopathtorsyncossched() {
        ViewControllerReference.shared.pathrsyncosxsched = nil
        self.statuslightpathrsyncosxsched.image = #imageLiteral(resourceName: "red")
    }

    private func nopathtorsyncosx() {
        ViewControllerReference.shared.pathrsyncosx = nil
        self.statuslightpathrsyncosx.image = #imageLiteral(resourceName: "red")
    }

    private func verifypatexists(pathorfilename: String?) -> Bool {
        let fileManager = FileManager.default
        var path: String?
        if pathorfilename == nil {
            path = ViewControllerReference.shared.usrlocalbinrsync
        } else {
            path = pathorfilename
        }
        guard fileManager.fileExists(atPath: path ?? "") else { return false }
        return true
    }

    private func verifysshkeypath() {
        self.statuslightsshkeypath.isHidden = false
        if self.sshkeypathandidentityfile.stringValue.first != "~" {
            let tempsshkeypath = self.sshkeypathandidentityfile.stringValue
            if tempsshkeypath.count > 1 {
                self.sshkeypathandidentityfile.stringValue = "~" + tempsshkeypath
            }
        }
        let tempsshkeypath = self.sshkeypathandidentityfile.stringValue
        let sshkeypathandidentityfilesplit = tempsshkeypath.split(separator: "/")
        if sshkeypathandidentityfilesplit.count > 2 {
            guard sshkeypathandidentityfilesplit[1].count > 1 else {
                self.statuslightsshkeypath.image = #imageLiteral(resourceName: "red")
                return
            }
            guard sshkeypathandidentityfilesplit[2].count > 1 else {
                self.statuslightsshkeypath.image = #imageLiteral(resourceName: "red")
                return
            }
            self.statuslightsshkeypath.image = #imageLiteral(resourceName: "green")
        } else {
            self.statuslightsshkeypath.image = #imageLiteral(resourceName: "red")
        }
    }

    private func checksshkeypathbeforesaving() -> Bool {
        if self.sshkeypathandidentityfile.stringValue.first != "~" { return false }
        let tempsshkeypath = self.sshkeypathandidentityfile.stringValue
        let sshkeypathandidentityfilesplit = tempsshkeypath.split(separator: "/")
        guard sshkeypathandidentityfilesplit.count > 2 else { return false }
        guard sshkeypathandidentityfilesplit[1].count > 1 else { return false }
        guard sshkeypathandidentityfilesplit[2].count > 1 else { return false }
        return true
    }

    private func setsshparameters() {
        if self.sshkeypathandidentityfile.stringValue.isEmpty == false {
            guard self.checksshkeypathbeforesaving() == true else { return }
            ViewControllerReference.shared.sshkeypathandidentityfile = self.sshkeypathandidentityfile.stringValue
        } else {
            ViewControllerReference.shared.sshkeypathandidentityfile = nil
        }
        if self.sshport.stringValue.isEmpty == false {
            if let port = self.sshport {
                ViewControllerReference.shared.sshport = Int(port.stringValue)
            }
        } else {
            ViewControllerReference.shared.sshport = nil
        }
        self.reload = true
    }

    private func setjson() {
        if ViewControllerReference.shared.json {
            self.jsonlabel.stringValue = "JSON"
            self.json.state = .on
        } else {
            self.jsonlabel.stringValue = "PLIST"
            self.json.state = .off
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rsyncPath.delegate = self
        self.restorePath.delegate = self
        self.marknumberofdayssince.delegate = self
        self.pathRsyncOSX.delegate = self
        self.pathRsyncOSXsched.delegate = self
        self.environment.delegate = self
        self.sshkeypathandidentityfile.delegate = self
        self.sshport.delegate = self
        self.nologging.state = .on
        self.reloadconfigurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.reloadschedulesDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.nameandpaths = NamesandPaths(profileorsshrootpath: .profileroot)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.dirty = false
        self.marknumberofdayssince.stringValue = String(ViewControllerReference.shared.marknumberofdayssince)
        self.reload = false
        self.pathRsyncOSXsched.stringValue = ViewControllerReference.shared.pathrsyncosxsched ?? ""
        self.pathRsyncOSX.stringValue = ViewControllerReference.shared.pathrsyncosx ?? ""
        self.sshkeypathandidentityfile.stringValue = ViewControllerReference.shared.sshkeypathandidentityfile ?? ""
        if let sshport = ViewControllerReference.shared.sshport {
            self.sshport.stringValue = String(sshport)
        }
        self.checkUserConfig()
        self.verifyrsync()
        self.setjson()
        self.statuslighttemppath.isHidden = true
        self.statuslightpathrsync.isHidden = true
        self.statuslightpathrsyncosx.isHidden = true
        self.statuslightpathrsyncosxsched.isHidden = true
        self.statuslightsshkeypath.isHidden = true
        self.jsonischanged = ViewControllerReference.shared.json
    }

    // Function for check and set user configuration
    private func checkUserConfig() {
        if ViewControllerReference.shared.rsyncversion3 {
            self.version3rsync.state = .on
        } else {
            self.version3rsync.state = .off
        }
        if ViewControllerReference.shared.detailedlogging {
            self.detailedlogging.state = .on
        } else {
            self.detailedlogging.state = .off
        }
        if ViewControllerReference.shared.localrsyncpath != nil {
            self.rsyncPath.stringValue = ViewControllerReference.shared.localrsyncpath!
        } else {
            self.rsyncPath.stringValue = ""
        }
        if ViewControllerReference.shared.temporarypathforrestore != nil {
            self.restorePath.stringValue = ViewControllerReference.shared.temporarypathforrestore!
        } else {
            self.restorePath.stringValue = ""
        }
        if ViewControllerReference.shared.minimumlogging {
            self.minimumlogging.state = .on
        }
        if ViewControllerReference.shared.fulllogging {
            self.fulllogging.state = .on
        }
        if ViewControllerReference.shared.environment != nil {
            self.environment.stringValue = ViewControllerReference.shared.environment!
        } else {
            self.environment.stringValue = ""
        }
        if ViewControllerReference.shared.environmentvalue != nil {
            self.environmentvalue.stringValue = ViewControllerReference.shared.environmentvalue!
        } else {
            self.environmentvalue.stringValue = ""
        }
        if ViewControllerReference.shared.checkinput {
            self.togglecheckdatabutton.state = .on
        } else {
            self.togglecheckdatabutton.state = .off
        }
        if ViewControllerReference.shared.haltonerror {
            self.haltonerror.state = .on
        } else {
            self.haltonerror.state = .off
        }
        if ViewControllerReference.shared.monitornetworkconnection {
            self.monitornetworkconnection.state = .on
        } else {
            self.monitornetworkconnection.state = .off
        }
    }
}

extension ViewControllerUserconfiguration: NSTextFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        delayWithSeconds(0.5) {
            self.setdirty()
            switch (notification.object as? NSTextField)! {
            case self.rsyncPath:
                if self.rsyncPath.stringValue.isEmpty == false {
                    self.version3rsync.state = .on
                    ViewControllerReference.shared.rsyncversion3 = true
                }
                self.verifyrsync()
                self.newrsync()
            case self.restorePath:
                return
            case self.marknumberofdayssince:
                return
            case self.pathRsyncOSX:
                self.verifypathtorsyncsched()
                self.verifypathtorsyncosx()
            case self.pathRsyncOSXsched:
                self.verifypathtorsyncsched()
                self.verifypathtorsyncosx()
            case self.sshkeypathandidentityfile:
                self.verifysshkeypath()
            case self.sshport:
                return
            case self.environment:
                return
            default:
                return
            }
        }
    }
}
