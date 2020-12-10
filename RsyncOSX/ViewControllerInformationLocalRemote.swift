//
//  ViewControllerInformationLocalRemote.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.05.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

struct LocaleRemoteInfo {
    var localremote: [NSDictionary]?

    func getlocalremoteinfo(index: Int) -> [NSDictionary]? {
        if let info = self.localremote?.filter({ ($0.value(forKey: DictionaryStrings.index.rawValue) as? Int) ?? -1 == index }) {
            return info
        } else {
            return nil
        }
    }

    mutating func setlocalremoteinfo(info: NSMutableDictionary?) {
        if let info = info {
            if self.localremote == nil {
                self.localremote?.append(info)
            } else {
                self.localremote?.append(info)
            }
        }
    }

    init() {
        self.localremote = [NSDictionary]()
    }
}

class ViewControllerInformationLocalRemote: NSViewController, SetDismisser, Index, SetConfigurations, Setcolor, Connected {
    private var index: Int?
    private var outputprocess: OutputProcess?
    private var complete: Bool = false
    private var localremoteinfo: LocaleRemoteInfo?

    @IBOutlet var transferredNumber: NSTextField!
    @IBOutlet var transferredNumberSizebytes: NSTextField!
    @IBOutlet var newfiles: NSTextField!
    @IBOutlet var deletefiles: NSTextField!
    @IBOutlet var totalNumber: NSTextField!
    @IBOutlet var totalDirs: NSTextField!
    @IBOutlet var totalNumberSizebytes: NSTextField!
    @IBOutlet var localtotalNumber: NSTextField!
    @IBOutlet var localtotalDirs: NSTextField!
    @IBOutlet var localtotalNumberSizebytes: NSTextField!
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var gotit: NSTextField!
    @IBOutlet var datelastbackup: NSTextField!
    @IBOutlet var dayslastbackup: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcinfolocalremote, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.complete = false
        self.index = self.index()
        if let index = self.index {
            let datelastbackup = self.configurations?.getConfigurations()?[index].dateRun ?? ""
            if datelastbackup.isEmpty == false {
                let date = datelastbackup.en_us_date_from_string()
                self.datelastbackup.stringValue = NSLocalizedString("Date last synchronize:", comment: "Remote Info")
                    + " " + date.localized_string_from_date()
            } else {
                self.datelastbackup.stringValue = NSLocalizedString("Date last synchronize:", comment: "Remote Info")
            }
            let numberlastbackup = self.configurations?.getConfigurations()?[index].dayssincelastbackup ?? ""
            self.dayslastbackup.stringValue = NSLocalizedString("Days since last synchronize:", comment: "Remote Info")
                + " " + numberlastbackup
            if self.connected(config: self.configurations?.getConfigurations()?[index]) == true {
                self.localremoteinfo = LocaleRemoteInfo()
                self.working.startAnimation(nil)
                self.outputprocess = OutputProcess()
                let estimation = EstimateremoteInformationOnetask(index: index, outputprocess: self.outputprocess, local: true, processtermination: self.processtermination, filehandler: self.filehandler)
                estimation.startestimation()
            } else {
                self.gotit.stringValue = NSLocalizedString("Seems not to be connected...", comment: "Remote Info")
                self.gotit.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            }
        }
    }

    @IBAction func close(_: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    private func setnumbers(outputprocess: OutputProcess?, local: Bool) {
        globalMainQueue.async { () -> Void in
            let infotask = RemoteinfonumbersOnetask(outputprocess: outputprocess)
            if local {
                self.localtotalNumber.stringValue = infotask.totalNumber ?? ""
                self.localtotalNumberSizebytes.stringValue = infotask.totalNumberSizebytes ?? ""
                self.localtotalDirs.stringValue = infotask.totalDirs ?? ""
                self.localremoteinfo?.setlocalremoteinfo(info: infotask.recordremotenumbers(index: self.index ?? -1))
            } else {
                self.transferredNumber.stringValue = infotask.transferredNumber ?? ""
                self.transferredNumberSizebytes.stringValue = infotask.transferredNumberSizebytes ?? ""
                self.totalNumber.stringValue = infotask.totalNumber ?? ""
                self.totalNumberSizebytes.stringValue = infotask.totalNumberSizebytes ?? ""
                self.totalDirs.stringValue = infotask.totalDirs ?? ""
                self.newfiles.stringValue = infotask.newfiles ?? ""
                self.deletefiles.stringValue = infotask.deletefiles ?? ""
                self.localremoteinfo?.setlocalremoteinfo(info: infotask.recordremotenumbers(index: self.index ?? -1))
                self.working.stopAnimation(nil)
                self.gotit.stringValue = NSLocalizedString("Got it...", comment: "Remote Info")
                self.gotit.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            }
        }
    }
}

extension ViewControllerInformationLocalRemote {
    func processtermination() {
        if self.complete == false {
            self.setnumbers(outputprocess: self.outputprocess, local: true)
        } else {
            self.setnumbers(outputprocess: self.outputprocess, local: false)
        }
        if let index = self.index {
            if self.complete == false {
                self.complete = true
                self.outputprocess = OutputProcess()
                let estimation = EstimateremoteInformationOnetask(index: index, outputprocess: self.outputprocess, local: false, processtermination: self.processtermination, filehandler: self.filehandler)
                estimation.startestimation()
            }
        }
    }

    func filehandler() {
        //
    }
}
