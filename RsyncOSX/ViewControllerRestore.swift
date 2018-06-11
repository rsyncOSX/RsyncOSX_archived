//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerRestore: NSViewController, SetConfigurations, SetDismisser, GetIndex {

    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var working: NSProgressIndicator!

    var outputprocess: OutputProcess?
    private var numbers: NSMutableDictionary?

    // Close and dismiss view
    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcrestore, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.sshport.stringValue = ""
        if let index = self.index(viewcontroller: .vctabmain) {
            let config: Configuration = self.configurations!.getConfigurations()[index]
            self.localCatalog.stringValue = config.localCatalog
            self.offsiteCatalog.stringValue = config.offsiteCatalog
            self.offsiteUsername.stringValue = config.offsiteUsername
            self.offsiteServer.stringValue = config.offsiteServer
            self.backupID.stringValue = config.backupID
            if let port = config.sshport {
                self.sshport.stringValue = String(port)
            }
            self.working.startAnimation(nil)
            self.outputprocess = OutputProcess()
            _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: true)
        }
    }

    private func setNumbers(outputprocess: OutputProcess?) {
        globalMainQueue.async(execute: { () -> Void in
            let infotask = RemoteInfoTask(outputprocess: outputprocess)
            self.numbers = NSMutableDictionary()
            self.numbers?.setValue(infotask.transferredNumber!, forKey: "transferredNumber")
            self.numbers?.setValue(infotask.transferredNumberSizebytes!, forKey: "transferredNumberSizebytes")
            self.numbers?.setValue(infotask.totalNumber!, forKey: "totalNumber")
            self.numbers?.setValue(infotask.totalNumberSizebytes!, forKey: "totalNumberSizebytes")
            self.numbers?.setValue(infotask.totalDirs!, forKey: "totalDirs")
            self.numbers?.setValue(infotask.newfiles!, forKey: "newfiles")
            self.numbers?.setValue(infotask.deletefiles!, forKey: "deletefiles")
            self.working.stopAnimation(nil)
            // self.gotit.stringValue = "Got it..."
        })
    }
}

extension ViewControllerRestore: UpdateProgress {
    func processTermination() {
        self.setNumbers(outputprocess: self.outputprocess)
    }

    func fileHandler() {
        //
    }
}
