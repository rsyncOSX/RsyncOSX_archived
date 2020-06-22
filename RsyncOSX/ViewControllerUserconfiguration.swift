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

class ViewControllerUserconfiguration: NSViewController, NewRsync, SetDismisser, Delay, ChangeTemporaryRestorePath {
    var dirty: Bool = false
    weak var reloadconfigurationsDelegate: Createandreloadconfigurations?
    weak var menuappDelegate: MenuappChanged?
    var oldmarknumberofdayssince: Double?
    var reload: Bool = false

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
    @IBOutlet var automaticexecutelocalvolumes: NSButton!
    @IBOutlet var environment: NSTextField!
    @IBOutlet var environmentvalue: NSTextField!
    @IBOutlet var enableenvironment: NSButton!
    @IBOutlet var togglecheckdatabutton: NSButton!
    @IBOutlet var haltonerror: NSButton!
    @IBOutlet var sshport: NSTextField!
    @IBOutlet var sshkeypathandidentityfile: NSTextField!
    @IBOutlet var statuslightsshkeypath: NSImageView!
    @IBOutlet var closebutton: NSButton!
    @IBOutlet var monitornetworkconnection: NSButton!

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

    @IBAction func toggleautomaticexecutelocalvolumes(_: NSButton) {
        if automaticexecutelocalvolumes.state == .on {
            ViewControllerReference.shared.automaticexecutelocalvolumes = true
        } else {
            ViewControllerReference.shared.automaticexecutelocalvolumes = false
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
            _ = PersistentStorageUserconfiguration().saveuserconfiguration()
            if self.reload {
                self.reloadconfigurationsDelegate?.createandreloadconfigurations()
            }
            self.menuappDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
            self.menuappDelegate?.menuappchanged()
            self.changetemporaryrestorepath()
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
        _ = RsyncVersionString()
    }

    @IBAction func closenosave(_: NSButton) {
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
        self.closebutton.isHidden = false
        self.closebutton.isEnabled = true
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
        self.statuslighttemppath.isHidden = true
        self.statuslightpathrsync.isHidden = true
        self.statuslightpathrsyncosx.isHidden = true
        self.statuslightpathrsyncosxsched.isHidden = true
        self.statuslightsshkeypath.isHidden = true
        self.closebutton.isHidden = true
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
        if ViewControllerReference.shared.automaticexecutelocalvolumes {
            self.automaticexecutelocalvolumes.state = .on
        } else {
            self.automaticexecutelocalvolumes.state = .off
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
