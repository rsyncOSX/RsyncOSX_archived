//
//  ViewControllerUserconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

protocol OperationChanged: class {
    func operationsmethod()
}
class ViewControllerUserconfiguration: NSViewController, NewRsync, SetDismisser, Delay {

    var storageapi: PersistentStorageAPI?
    var dirty: Bool = false
    weak var operationchangeDelegate: OperationChanged?

    @IBOutlet weak var rsyncPath: NSTextField!
    @IBOutlet weak var version3rsync: NSButton!
    @IBOutlet weak var detailedlogging: NSButton!
    @IBOutlet weak var noRsync: NSTextField!
    @IBOutlet weak var rsyncerror: NSButton!
    @IBOutlet weak var restorePath: NSTextField!
    @IBOutlet weak var operation: NSButton!

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
        self.dirty = true
        self.verifyRsync()
    }

    @IBAction func toggleDetailedlogging(_ sender: NSButton) {
        if self.detailedlogging.state == .on {
            ViewControllerReference.shared.detailedlogging = true
        } else {
            ViewControllerReference.shared.detailedlogging = false
        }
        self.dirty = true
    }

    @IBAction func close(_ sender: NSButton) {
        if self.dirty {
            // Before closing save changed configuration
            self.setRsyncPath()
            self.verifyRsync()
            self.setRestorePath()
            _ = self.storageapi!.saveUserconfiguration()
        }
        if (self.presenting as? ViewControllertabMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presenting as? ViewControllertabSchedule) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presenting as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        }
    }

    @IBAction func toggleError(_ sender: NSButton) {
        if self.rsyncerror.state == .on {
            ViewControllerReference.shared.rsyncerror = true
        } else {
            ViewControllerReference.shared.rsyncerror = false
        }
        self.dirty = true
    }

    @IBAction func toggleOperation(_ sender: NSButton) {
        if self.operation.state == .on {
            ViewControllerReference.shared.operation = .dispatch
        } else {
            ViewControllerReference.shared.operation = .timer
        }
        self.operationchangeDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
        self.operationchangeDelegate?.operationsmethod()
        self.dirty = true
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
        self.dirty = true
    }

    private func setRestorePath() {
        if self.restorePath.stringValue.isEmpty == false {
            if restorePath.stringValue.hasSuffix("/") == false {
                restorePath.stringValue += "/"
                ViewControllerReference.shared.restorePath = restorePath.stringValue
            }
        } else {
            ViewControllerReference.shared.restorePath = nil
        }
        self.dirty = true
    }

    // Function verifying rsync in path
    private func verifyRsync() {
        var path: String?
        let fileManager = FileManager.default
        if self.version3rsync.state == .on {
            if let rsyncPath = ViewControllerReference.shared.rsyncPath {
                path = rsyncPath + "rsync"
            } else {
                path = "/usr/local/bin/" + "rsync"
            }
        } else {
            path = "/usr/bin/" + "rsync"
        }
        if fileManager.fileExists(atPath: path!) {
            self.noRsync.isHidden = true
            ViewControllerReference.shared.norsync = false
        } else {
            self.noRsync.isHidden = false
            ViewControllerReference.shared.norsync = true
        }
    }

    private func testforrsync() {
        let rsyncpath: String?
        let fileManager = FileManager.default
        if self.rsyncPath.stringValue.isEmpty == false {
            if self.rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncpath = self.rsyncPath.stringValue + "/" + "rsync"
            } else {
                rsyncpath = self.rsyncPath.stringValue + "rsync"
            }
        } else {
            rsyncpath = nil
        }
        guard rsyncpath != nil else {
            self.noRsync.isHidden = true
            return
        }
        if fileManager.fileExists(atPath: rsyncpath!) {
            self.noRsync.isHidden = true
        } else {
            self.noRsync.isHidden = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rsyncPath.delegate = self
        self.restorePath.delegate = self
        self.storageapi = PersistentStorageAPI(profile: nil)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.dirty = false
        self.checkUserConfig()
        self.verifyRsync()
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
        if ViewControllerReference.shared.rsyncerror {
            self.rsyncerror.state = .on
        } else {
            self.rsyncerror.state = .off
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
    }

}

extension ViewControllerUserconfiguration: NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        self.version3rsync.state = .on
        self.dirty = true
        delayWithSeconds(0.5) {
            self.testforrsync()
        }
    }

}
