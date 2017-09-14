//
//  ViewControllerUserconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

// Protocol for doing updates when optional path for rsync is changed
// or user enable or disable doubleclick to execte
protocol RsyncChanged : class {
    func rsyncchanged()
    func displayAllowDoubleclick()
}

class ViewControllerUserconfiguration: NSViewController {

    // Storage API
    var storageapi: PersistentStorageAPI?
    var dirty: Bool = false
    // Delegate to read configurations after toggeling between test- and real mode
    weak var rsyncchangedDelegate: RsyncChanged?
    weak var dismissDelegate: DismissViewController?

    @IBOutlet weak var rsyncPath: NSTextField!
    @IBOutlet weak var version3rsync: NSButton!
    @IBOutlet weak var detailedlogging: NSButton!
    @IBOutlet weak var noRsync: NSTextField!
    @IBOutlet weak var rsyncerror: NSButton!
    @IBOutlet weak var restorePath: NSTextField!

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
        self.rsyncchangedDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        self.rsyncchangedDelegate?.rsyncchanged()
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
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func toggleError(_ sender: NSButton) {
        if self.rsyncerror.state == .on {
            ViewControllerReference.shared.rsyncerror = true
        } else {
            ViewControllerReference.shared.rsyncerror = false
        }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisser is root controller
        if let pvc = self.presenting as? ViewControllertabMain {
            self.dismissDelegate = pvc
        } else if let pvc = self.presenting as? ViewControllertabSchedule {
            self.dismissDelegate = pvc
        } else if let pvc = self.presenting as? ViewControllerNewConfigurations {
            self.dismissDelegate = pvc
        }
        self.rsyncPath.delegate = self
        self.restorePath.delegate = self
        self.storageapi = PersistentStorageAPI(profile : nil)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.dirty = false
        // Set userconfig
        self.checkUserConfig()
        // Check path for rsync
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
    }

}

extension ViewControllerUserconfiguration : NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        self.version3rsync.state = .on
        self.dirty = true
    }

}
