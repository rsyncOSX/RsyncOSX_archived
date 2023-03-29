//
//  ViewControllerUserconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length type_body_length file_length cyclomatic_complexity

import Cocoa
import Foundation

class ViewControllerUserconfiguration: NSViewController, SetConfigurations, NewRsync, Delay, ChangeTemporaryRestorePath {
    var dirty: Bool = false
    weak var reloadconfigurationsDelegate: GetConfigurationsObject?
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
    @IBOutlet var statuslightpathrsync: NSImageView!
    @IBOutlet var statuslighttemppath: NSImageView!
    @IBOutlet var savebutton: NSButton!
    @IBOutlet var environment: NSTextField!
    @IBOutlet var environmentvalue: NSTextField!
    @IBOutlet var enableenvironment: NSButton!
    @IBOutlet var haltonerror: NSButton!
    @IBOutlet var sshport: NSTextField!
    @IBOutlet var sshkeypathandidentityfile: NSTextField!
    @IBOutlet var statuslightsshkeypath: NSImageView!
    @IBOutlet var monitornetworkconnection: NSButton!

    @IBAction func copyconfigfiles(_: NSButton) {
        _ = Backupconfigfiles()
        view.window?.close()
    }

    @IBAction func togglehaltonerror(_: NSButton) {
        if SharedReference.shared.haltonerror {
            haltonerror.state = .off
            SharedReference.shared.haltonerror = false
        } else {
            haltonerror.state = .on
            SharedReference.shared.haltonerror = true
        }
        setdirty()
    }

    @IBAction func toggleenableenvironment(_: NSButton) {
        switch enableenvironment.state {
        case .on:
            environment.isEnabled = true
            environmentvalue.isEnabled = true
        case .off:
            environment.isEnabled = false
            environmentvalue.isEnabled = false
        default:
            return
        }
        setdirty()
    }

    @IBAction func toggleversion3rsync(_: NSButton) {
        if version3rsync.state == .on {
            SharedReference.shared.rsyncversion3 = true
            if rsyncPath.stringValue == "" {
                SharedReference.shared.localrsyncpath = nil
            } else {
                _ = Setrsyncpath(path: rsyncPath.stringValue)
            }
        } else {
            SharedReference.shared.rsyncversion3 = false
        }
        newrsync()
        setdirty()
        verifyrsync()
    }

    @IBAction func toggleDetailedlogging(_: NSButton) {
        if detailedlogging.state == .on {
            SharedReference.shared.detailedlogging = true
        } else {
            SharedReference.shared.detailedlogging = false
        }
        setdirty()
    }

    @IBAction func togglemonitornetworkconnection(_: NSButton) {
        if monitornetworkconnection.state == .on {
            SharedReference.shared.monitornetworkconnection = true
        } else {
            SharedReference.shared.monitornetworkconnection = false
        }
        setdirty()
    }

    @IBAction func close(_: NSButton) {
        if dirty {
            // Before closing save changed configuration
            _ = Setrsyncpath(path: rsyncPath.stringValue)
            setRestorePath()
            setmarknumberofdayssince()
            setEnvironment()
            setsshparameters()
            // WriteUserConfigurationPLIST()
            WriteUserConfigurationJSON(UserConfiguration())
            if reload {
                // Do a reload of config data
                _ = Selectprofile(profile: configurations?.getProfile(), selectedindex: nil)
            }
            loadsshparametersDelegate = SharedReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
            loadsshparametersDelegate?.loadsshparameters()
            changetemporaryrestorepath()
        }
        view.window?.close()
        _ = RsyncVersionString()
    }

    @IBAction func logging(_: NSButton) {
        if fulllogging.state == .on {
            SharedReference.shared.fulllogging = true
            SharedReference.shared.minimumlogging = false
        } else if minimumlogging.state == .on {
            SharedReference.shared.fulllogging = false
            SharedReference.shared.minimumlogging = true
        } else if nologging.state == .on {
            SharedReference.shared.fulllogging = false
            SharedReference.shared.minimumlogging = false
        }
        setdirty()
    }

    private func setdirty() {
        dirty = true
        savebutton.title = NSLocalizedString("Save", comment: "Userconfig ")
    }

    private func setmarknumberofdayssince() {
        if let marknumberofdayssince = Double(marknumberofdayssince.stringValue) {
            oldmarknumberofdayssince = SharedReference.shared.marknumberofdayssince
            SharedReference.shared.marknumberofdayssince = marknumberofdayssince
            if oldmarknumberofdayssince != marknumberofdayssince {
                reload = true
            }
        }
    }

    private func setRestorePath() {
        if restorePath.stringValue.isEmpty == false {
            if restorePath.stringValue.hasSuffix("/") == false {
                restorePath.stringValue += "/"
                SharedReference.shared.pathforrestore = restorePath.stringValue
            } else {
                SharedReference.shared.pathforrestore = restorePath.stringValue
            }
        } else {
            SharedReference.shared.pathforrestore = nil
        }
        setdirty()
    }

    private func setEnvironment() {
        if environment.stringValue.isEmpty == false {
            guard environmentvalue.stringValue.isEmpty == false else { return }
            SharedReference.shared.environment = environment.stringValue
            SharedReference.shared.environmentvalue = environmentvalue.stringValue
        } else {
            SharedReference.shared.environment = nil
            SharedReference.shared.environmentvalue = nil
        }
    }

    private func verifyrsync() {
        var rsyncpath: String?
        if rsyncPath.stringValue.isEmpty == false {
            if rsyncPath.stringValue.contains("$HOME") {
                let replaced = rsyncPath.stringValue.replacingOccurrences(of: "$HOME",
                                                                          with: nameandpaths?.userHomeDirectoryPath ?? "")
                rsyncPath.stringValue = replaced
            }
            if rsyncPath.stringValue.contains("$home") {
                let replaced = rsyncPath.stringValue.replacingOccurrences(of: "$home",
                                                                          with: nameandpaths?.userHomeDirectoryPath ?? "")
                rsyncPath.stringValue = replaced
            }
            statuslightpathrsync.isHidden = false
            if rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncpath = rsyncPath.stringValue + "/" + SharedReference.shared.rsync
            } else {
                rsyncpath = rsyncPath.stringValue + SharedReference.shared.rsync
            }
        } else {
            rsyncpath = nil
        }
        // use stock rsync
        guard version3rsync.state == .on else {
            SharedReference.shared.norsync = false
            return
        }
        statuslightpathrsync.isHidden = false
        if verifypatexists(pathorfilename: rsyncpath) {
            noRsync.isHidden = true
            SharedReference.shared.norsync = false
            statuslightpathrsync.image = #imageLiteral(resourceName: "green")
        } else {
            noRsync.isHidden = false
            SharedReference.shared.norsync = true
            statuslightpathrsync.image = #imageLiteral(resourceName: "red")
        }
    }

    private func verifypatexists(pathorfilename: String?) -> Bool {
        let fileManager = FileManager.default
        var path: String?
        if pathorfilename == nil {
            if SharedReference.shared.macosarm {
                path = SharedReference.shared.opthomebrewbinrsync
            } else {
                path = SharedReference.shared.usrlocalbinrsync
            }
        } else {
            path = pathorfilename
        }
        guard fileManager.fileExists(atPath: path ?? "") else { return false }
        return true
    }

    private func verifysshkeypath() {
        statuslightsshkeypath.isHidden = false
        if sshkeypathandidentityfile.stringValue.first != "~" {
            let tempsshkeypath = sshkeypathandidentityfile.stringValue
            if tempsshkeypath.count > 1 {
                sshkeypathandidentityfile.stringValue = "~" + tempsshkeypath
            }
        }
        let tempsshkeypath = sshkeypathandidentityfile.stringValue
        let sshkeypathandidentityfilesplit = tempsshkeypath.split(separator: "/")
        if sshkeypathandidentityfilesplit.count > 2 {
            guard sshkeypathandidentityfilesplit[1].count > 1 else {
                statuslightsshkeypath.image = #imageLiteral(resourceName: "red")
                return
            }
            guard sshkeypathandidentityfilesplit[2].count > 1 else {
                statuslightsshkeypath.image = #imageLiteral(resourceName: "red")
                return
            }
            statuslightsshkeypath.image = #imageLiteral(resourceName: "green")
        } else {
            statuslightsshkeypath.image = #imageLiteral(resourceName: "red")
        }
    }

    private func checksshkeypathbeforesaving() -> Bool {
        if sshkeypathandidentityfile.stringValue.first != "~" { return false }
        let tempsshkeypath = sshkeypathandidentityfile.stringValue
        let sshkeypathandidentityfilesplit = tempsshkeypath.split(separator: "/")
        guard sshkeypathandidentityfilesplit.count > 2 else { return false }
        guard sshkeypathandidentityfilesplit[1].count > 1 else { return false }
        guard sshkeypathandidentityfilesplit[2].count > 1 else { return false }
        return true
    }

    private func setsshparameters() {
        if sshkeypathandidentityfile.stringValue.isEmpty == false {
            guard checksshkeypathbeforesaving() == true else { return }
            SharedReference.shared.sshkeypathandidentityfile = sshkeypathandidentityfile.stringValue
        } else {
            SharedReference.shared.sshkeypathandidentityfile = nil
        }
        if sshport.stringValue.isEmpty == false {
            if let port = sshport {
                SharedReference.shared.sshport = Int(port.stringValue)
            }
        } else {
            SharedReference.shared.sshport = nil
        }
        reload = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rsyncPath.delegate = self
        restorePath.delegate = self
        marknumberofdayssince.delegate = self
        environment.delegate = self
        sshkeypathandidentityfile.delegate = self
        sshport.delegate = self
        nologging.state = .on
        reloadconfigurationsDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        nameandpaths = NamesandPaths(.configurations)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        dirty = false
        marknumberofdayssince.stringValue = String(SharedReference.shared.marknumberofdayssince)
        reload = false
        sshkeypathandidentityfile.stringValue = SharedReference.shared.sshkeypathandidentityfile ?? ""
        if let sshport = SharedReference.shared.sshport {
            self.sshport.stringValue = String(sshport)
        }
        checkUserConfig()
        verifyrsync()
        statuslighttemppath.isHidden = true
        statuslightpathrsync.isHidden = true
        statuslightsshkeypath.isHidden = true
    }

    // Function for check and set user configuration
    private func checkUserConfig() {
        if SharedReference.shared.rsyncversion3 {
            version3rsync.state = .on
        } else {
            version3rsync.state = .off
        }
        if SharedReference.shared.detailedlogging {
            detailedlogging.state = .on
        } else {
            detailedlogging.state = .off
        }
        if SharedReference.shared.localrsyncpath != nil {
            rsyncPath.stringValue = SharedReference.shared.localrsyncpath!
        } else {
            rsyncPath.stringValue = ""
        }
        if SharedReference.shared.pathforrestore != nil {
            restorePath.stringValue = SharedReference.shared.pathforrestore!
        } else {
            restorePath.stringValue = ""
        }
        if SharedReference.shared.minimumlogging {
            minimumlogging.state = .on
        }
        if SharedReference.shared.fulllogging {
            fulllogging.state = .on
        }
        if SharedReference.shared.environment != nil {
            environment.stringValue = SharedReference.shared.environment!
        } else {
            environment.stringValue = ""
        }
        if SharedReference.shared.environmentvalue != nil {
            environmentvalue.stringValue = SharedReference.shared.environmentvalue!
        } else {
            environmentvalue.stringValue = ""
        }
        if SharedReference.shared.haltonerror {
            haltonerror.state = .on
        } else {
            haltonerror.state = .off
        }
        if SharedReference.shared.monitornetworkconnection {
            monitornetworkconnection.state = .on
        } else {
            monitornetworkconnection.state = .off
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
                    SharedReference.shared.rsyncversion3 = true
                }
                self.verifyrsync()
                self.newrsync()
            case self.restorePath:
                return
            case self.marknumberofdayssince:
                return
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
