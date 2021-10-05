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
        if let info = localremote?.filter({ ($0.value(forKey: DictionaryStrings.index.rawValue) as? Int) ?? -1 == index }) {
            return info
        } else {
            return nil
        }
    }

    mutating func setlocalremoteinfo(info: NSMutableDictionary?) {
        if let info = info {
            if localremote == nil {
                localremote?.append(info)
            } else {
                localremote?.append(info)
            }
        }
    }

    init() {
        localremote = [NSDictionary]()
    }
}

class ViewControllerInformationLocalRemote: NSViewController, SetDismisser, Index, SetConfigurations, Setcolor, Connected {
    private var index: Int?
    private var outputprocess: OutputfromProcess?
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
        SharedReference.shared.setvcref(viewcontroller: .vcinfolocalremote, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        complete = false
        index = index()
        if let index = index {
            let datelastbackup = configurations?.getConfigurations()?[index].dateRun ?? ""
            if datelastbackup.isEmpty == false {
                let date = datelastbackup.en_us_date_from_string()
                self.datelastbackup.stringValue = NSLocalizedString("Date last synchronize:", comment: "Remote Info")
                    + " " + date.localized_string_from_date()
            } else {
                self.datelastbackup.stringValue = NSLocalizedString("Date last synchronize:", comment: "Remote Info")
            }
            let numberlastbackup = configurations?.getConfigurations()?[index].dayssincelastbackup ?? ""
            dayslastbackup.stringValue = NSLocalizedString("Days since last synchronize:", comment: "Remote Info")
                + " " + numberlastbackup
            if connected(config: configurations?.getConfigurations()?[index]) == true {
                localremoteinfo = LocaleRemoteInfo()
                working.startAnimation(nil)
                outputprocess = OutputfromProcess()
                let estimation = EstimateremoteInformationOnetask(index: index, outputprocess: outputprocess, local: true, processtermination: processtermination, filehandler: filehandler)
                estimation.startestimation()
            } else {
                gotit.stringValue = NSLocalizedString("Seems not to be connected...", comment: "Remote Info")
                gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
            }
        }
    }

    @IBAction func close(_: NSButton) {
        dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    private func setnumbers(outputprocess: OutputfromProcess?, local: Bool) {
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
        if complete == false {
            setnumbers(outputprocess: outputprocess, local: true)
        } else {
            setnumbers(outputprocess: outputprocess, local: false)
        }
        if let index = index {
            if complete == false {
                complete = true
                outputprocess = OutputfromProcess()
                let estimation = EstimateremoteInformationOnetask(index: index, outputprocess: outputprocess, local: false, processtermination: processtermination, filehandler: filehandler)
                estimation.startestimation()
            }
        }
    }

    func filehandler() {
        //
    }
}
