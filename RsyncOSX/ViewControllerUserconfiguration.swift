//
//  ViewControllerUserconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

//swiftlint:disable syntactic_sugar file_length cyclomatic_complexity line_length

import Foundation
import Cocoa

// Protocol for doing updates when optional path for rsync is changed
// or user enable or disable doubleclick to execte
protocol RsyncChanged : class {
    func rsyncchanged()
    func displayAllowDoubleclick()
}

class ViewControllerUserconfiguration: NSViewController {

    var dirty: Bool = false
    // Delegate to read configurations after toggeling between
    // test- and real mode
    weak var rsyncchangedDelegate: RsyncChanged?
    // Dismisser
    weak var dismissDelegate: DismissViewController?

    @IBOutlet weak var rsyncPath: NSTextField!
    @IBOutlet weak var version3rsync: NSButton!
    @IBOutlet weak var detailedlogging: NSButton!
    @IBOutlet weak var allowDoubleClick: NSButton!
    @IBOutlet weak var noRsync: NSTextField!
    @IBOutlet weak var rsyncerror: NSButton!
    @IBOutlet weak var restorePath: NSTextField!

    @IBAction func toggleversion3rsync(_ sender: NSButton) {
        if self.version3rsync.state == .on {
            SharingManagerConfiguration.sharedInstance.rsyncVer3 = true
        } else {
            SharingManagerConfiguration.sharedInstance.rsyncVer3 = false
        }
        if let pvc = self.presenting as? ViewControllertabMain {
            self.rsyncchangedDelegate = pvc
            self.rsyncchangedDelegate?.rsyncchanged()
        }
        self.dirty = true
        self.verifyRsync()
    }

    @IBAction func toggleDetailedlogging(_ sender: NSButton) {
        if self.detailedlogging.state == .on {
            SharingManagerConfiguration.sharedInstance.detailedlogging = true
        } else {
            SharingManagerConfiguration.sharedInstance.detailedlogging = false
        }
        self.dirty = true
    }

    @IBAction func close(_ sender: NSButton) {
        if self.dirty {
            // Before closing save changed configuration
            self.setRsyncPath()
            self.verifyRsync()
            self.setRestorePath()
            _ = PersistentStoreAPI.sharedInstance.saveUserconfiguration()
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func toggleAllowDoubleclick(_ sender: NSButton) {
        if self.allowDoubleClick.state == .on {
            SharingManagerConfiguration.sharedInstance.allowDoubleclick = true
        } else {
            SharingManagerConfiguration.sharedInstance.allowDoubleclick = false
        }
        if let pvc = self.presenting as? ViewControllertabMain {
            self.rsyncchangedDelegate = pvc
            self.rsyncchangedDelegate?.displayAllowDoubleclick()
        }
        self.dirty = true

    }

    @IBAction func toggleError(_ sender: NSButton) {
        if self.rsyncerror.state == .on {
            SharingManagerConfiguration.sharedInstance.rsyncerror = true
        } else {
            SharingManagerConfiguration.sharedInstance.rsyncerror = false
        }
        self.dirty = true
    }

    private func setRsyncPath() {
        if self.rsyncPath.stringValue.isEmpty == false {
            if rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncPath.stringValue += "/"
                SharingManagerConfiguration.sharedInstance.rsyncPath = rsyncPath.stringValue
            }
        } else {
            SharingManagerConfiguration.sharedInstance.rsyncPath = nil
        }
        self.dirty = true
    }

    private func setRestorePath() {
        if self.restorePath.stringValue.isEmpty == false {
            if restorePath.stringValue.hasSuffix("/") == false {
                restorePath.stringValue += "/"
                SharingManagerConfiguration.sharedInstance.restorePath = restorePath.stringValue
            }
        } else {
            SharingManagerConfiguration.sharedInstance.restorePath = nil
        }
        self.dirty = true
    }

    // Function verifying rsync in path
    private func verifyRsync() {
        if self.version3rsync.state == .on {
            let fileManager = FileManager.default
            if let rsyncPath = SharingManagerConfiguration.sharedInstance.rsyncPath {
                let path = rsyncPath + "rsync"
                if fileManager.fileExists(atPath: path) == false {
                    self.noRsync.isHidden = false
                    SharingManagerConfiguration.sharedInstance.noRysync = true
                } else {
                    SharingManagerConfiguration.sharedInstance.noRysync = false
                    self.noRsync.isHidden = true
                }
            } else {
                let path = "/usr/local/bin/rsync"
                if fileManager.fileExists(atPath: path) == false {
                    self.noRsync.isHidden = false
                    SharingManagerConfiguration.sharedInstance.noRysync = true
                } else {
                    SharingManagerConfiguration.sharedInstance.noRysync = false
                    self.noRsync.isHidden = true
                }
            }
        } else {
            SharingManagerConfiguration.sharedInstance.noRysync = false
            self.noRsync.isHidden = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismissDelegate = pvc2
        } else if let pvc2 = self.presenting as? ViewControllertabSchedule {
            self.dismissDelegate = pvc2
        } else if let pvc2 = self.presenting as? ViewControllerNewConfigurations {
            self.dismissDelegate = pvc2
        }
        self.rsyncPath.delegate = self
        self.restorePath.delegate = self
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
        if SharingManagerConfiguration.sharedInstance.rsyncVer3 {
            self.version3rsync.state = .on
        } else {
            self.version3rsync.state = .off
        }
        if SharingManagerConfiguration.sharedInstance.detailedlogging {
            self.detailedlogging.state = .on
        } else {
            self.detailedlogging.state = .off
        }
        if SharingManagerConfiguration.sharedInstance.rsyncPath != nil {
            self.rsyncPath.stringValue = SharingManagerConfiguration.sharedInstance.rsyncPath!
        } else {
            self.rsyncPath.stringValue = ""
        }
        if SharingManagerConfiguration.sharedInstance.allowDoubleclick {
            self.allowDoubleClick.state = .on
        } else {
            self.allowDoubleClick.state = .off
        }
        if SharingManagerConfiguration.sharedInstance.rsyncerror {
            self.rsyncerror.state = .on
        } else {
            self.rsyncerror.state = .off
        }
        if SharingManagerConfiguration.sharedInstance.restorePath != nil {
            self.restorePath.stringValue = SharingManagerConfiguration.sharedInstance.restorePath!
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
