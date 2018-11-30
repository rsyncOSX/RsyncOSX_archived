//
//  ViewControllerUserconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length type_body_length

import Foundation
import Cocoa

protocol OperationChanged: class {
    func operationsmethod()
}

protocol MenuappChanged: class {
    func menuappchanged()
}

class ViewControllerUserconfiguration: NSViewController, NewRsync, SetDismisser, Delay, ChangeTemporaryRestorePath {

    var storageapi: PersistentStorageAPI?
    var dirty: Bool = false
    weak var operationchangeDelegate: OperationChanged?
    weak var reloadconfigurationsDelegate: Createandreloadconfigurations?
    weak var menuappDelegate: MenuappChanged?
    var oldmarknumberofdayssince: Double?
    var reload: Bool = false

    @IBOutlet weak var rsyncPath: NSTextField!
    @IBOutlet weak var version3rsync: NSButton!
    @IBOutlet weak var detailedlogging: NSButton!
    @IBOutlet weak var noRsync: NSTextField!
    @IBOutlet weak var restorePath: NSTextField!
    @IBOutlet weak var operation: NSButton!
    @IBOutlet weak var fulllogging: NSButton!
    @IBOutlet weak var minimumlogging: NSButton!
    @IBOutlet weak var nologging: NSButton!
    @IBOutlet weak var marknumberofdayssince: NSTextField!
    @IBOutlet weak var pathRsyncOSX: NSTextField!
    @IBOutlet weak var pathRsyncOSXsched: NSTextField!
    @IBOutlet weak var executescheduledappsinmenuapp: NSButton!
    @IBOutlet weak var statuslightpathrsync: NSImageView!
    @IBOutlet weak var statuslighttemppath: NSImageView!
    @IBOutlet weak var statuslightpathrsyncosx: NSImageView!
    @IBOutlet weak var statuslightpathrsyncosxsched: NSImageView!
    @IBOutlet weak var savebutton: NSButton!

    @IBAction func toggleversion3rsync(_ sender: NSButton) {
        if self.version3rsync.state == .on {
            ViewControllerReference.shared.rsyncVer3 = true
            if self.rsyncPath.stringValue == "" {
                ViewControllerReference.shared.rsyncPath = nil
            } else {
                self.setRsyncPath()
            }
        } else {
            ViewControllerReference.shared.rsyncVer3 = false
        }
        self.newrsync()
        self.setdirty()
        self.verifyrsync()
    }

    @IBAction func toggleDetailedlogging(_ sender: NSButton) {
        if self.detailedlogging.state == .on {
            ViewControllerReference.shared.detailedlogging = true
        } else {
            ViewControllerReference.shared.detailedlogging = false
        }
        self.setdirty()
    }

    @IBAction func close(_ sender: NSButton) {
        if self.dirty {
            // Before closing save changed configuration
            self.setRsyncPath()
            self.setRestorePath()
            self.setmarknumberofdayssince()
            _ = self.storageapi!.saveUserconfiguration()
            if self.reload {
                self.reloadconfigurationsDelegate?.createandreloadconfigurations()
            }
            self.menuappDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            self.menuappDelegate?.menuappchanged()
            self.changetemporaryrestorepath()
        }
        if (self.presenting as? ViewControllertabMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presenting as? ViewControllertabSchedule) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presenting as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presenting as? ViewControllerCopyFiles) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        }
        _ = RsyncVersionString()
    }

    @IBAction func toggleOperation(_ sender: NSButton) {
        if self.operation.state == .on {
            ViewControllerReference.shared.operation = .dispatch
        } else {
            ViewControllerReference.shared.operation = .timer
        }
        self.operationchangeDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
        self.operationchangeDelegate?.operationsmethod()
        self.setdirty()
    }

    @IBAction func logging(_ sender: NSButton) {
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
        self.savebutton.title = "Save"
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

    private func setRsyncPath() {
        if self.rsyncPath.stringValue.isEmpty == false {
            if rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncPath.stringValue += "/"
                ViewControllerReference.shared.rsyncPath = rsyncPath.stringValue
            }
        } else {
            ViewControllerReference.shared.rsyncPath = nil
        }
        self.setdirty()
    }

    private func setRestorePath() {
        if self.restorePath.stringValue.isEmpty == false {
            if restorePath.stringValue.hasSuffix("/") == false {
                restorePath.stringValue += "/"
                ViewControllerReference.shared.restorePath = restorePath.stringValue
            } else {
                ViewControllerReference.shared.restorePath = restorePath.stringValue
            }
        } else {
            ViewControllerReference.shared.restorePath = nil
        }
        self.setdirty()
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
            self.enablestateexecutescheduledappsinmenuapp()
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
            self.enablestateexecutescheduledappsinmenuapp()
        } else {
            self.nopathtorsyncossched()
        }
    }

    private func nopathtorsyncossched() {
        ViewControllerReference.shared.executescheduledtasksmenuapp = false
        ViewControllerReference.shared.pathrsyncosxsched = nil
        self.statuslightpathrsyncosxsched.image = #imageLiteral(resourceName: "red")
        self.executescheduledappsinmenuapp.state = .off
    }

    private func nopathtorsyncosx() {
        ViewControllerReference.shared.executescheduledtasksmenuapp = false
        ViewControllerReference.shared.pathrsyncosx = nil
        self.statuslightpathrsyncosx.image = #imageLiteral(resourceName: "red")
        self.executescheduledappsinmenuapp.state = .off
    }

    private func enablestateexecutescheduledappsinmenuapp() {
        guard ViewControllerReference.shared.pathrsyncosxsched != nil && ViewControllerReference.shared.pathrsyncosx != nil  else { return }
        ViewControllerReference.shared.executescheduledtasksmenuapp = true
        self.executescheduledappsinmenuapp.state = .on
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rsyncPath.delegate = self
        self.restorePath.delegate = self
        self.marknumberofdayssince.delegate = self
        self.pathRsyncOSX.delegate = self
        self.pathRsyncOSXsched.delegate = self
        self.storageapi = PersistentStorageAPI(profile: nil)
        self.nologging.state = .on
        self.reloadconfigurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.dirty = false
        self.checkUserConfig()
        self.verifyrsync()
        self.marknumberofdayssince.stringValue = String(ViewControllerReference.shared.marknumberofdayssince)
        self.reload = false
        self.pathRsyncOSXsched.stringValue = ViewControllerReference.shared.pathrsyncosxsched ?? ""
        self.pathRsyncOSX.stringValue = ViewControllerReference.shared.pathrsyncosx ?? ""
        if ViewControllerReference.shared.executescheduledtasksmenuapp {
            self.executescheduledappsinmenuapp.state = .on
        } else {
            self.executescheduledappsinmenuapp.state = .off
        }
        self.statuslighttemppath.isHidden = true
        self.statuslightpathrsync.isHidden = true
        self.statuslightpathrsyncosx.isHidden = true
        self.statuslightpathrsyncosxsched.isHidden = true
    }

    // Function for check and set user configuration
    private func checkUserConfig() {
        if ViewControllerReference.shared.rsyncVer3 {
            self.version3rsync.state = .on
        } else {
            self.version3rsync.state = .off
        }
        if ViewControllerReference.shared.detailedlogging {
            self.detailedlogging.state = .on
        } else {
            self.detailedlogging.state = .off
        }
        if ViewControllerReference.shared.rsyncPath != nil {
            self.rsyncPath.stringValue = ViewControllerReference.shared.rsyncPath!
        } else {
            self.rsyncPath.stringValue = ""
        }
        if ViewControllerReference.shared.restorePath != nil {
            self.restorePath.stringValue = ViewControllerReference.shared.restorePath!
        } else {
            self.restorePath.stringValue = ""
        }
        switch ViewControllerReference.shared.operation {
        case .dispatch:
            self.operation.state = .on
        case .timer:
            self.operation.state = .off
        }
        if ViewControllerReference.shared.minimumlogging {
            self.minimumlogging.state = .on
        }
        if ViewControllerReference.shared.fulllogging {
            self.fulllogging.state = .on
        }
    }
}

extension ViewControllerUserconfiguration: NSTextFieldDelegate {

    override func controlTextDidChange(_ notification: Notification) {
        delayWithSeconds(0.5) {
            self.setdirty()
            switch (notification.object as? NSTextField)! {
            case self.rsyncPath:
                if self.rsyncPath.stringValue.isEmpty == false {
                    self.version3rsync.state = .on
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
            default:
                return
            }
        }
    }
}
