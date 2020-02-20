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

protocol SetLocalRemoteInfo: AnyObject {
    func setlocalremoteinfo(info: NSMutableDictionary?)
    func getlocalremoteinfo(index: Int) -> [NSDictionary]?
}

class ViewControllerInformationLocalRemote: NSViewController, SetDismisser, Index, SetConfigurations, Setcolor, Connected {
    private var index: Int?
    private var outputprocess: OutputProcess?
    private var complete: Bool = false
    weak var localremoteinfoDelegate: SetLocalRemoteInfo?

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
        self.localremoteinfoDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.complete = false
        self.index = self.index()
        if let index = self.index {
            let datelastbackup = self.configurations?.getConfigurations()[index].dateRun ?? ""
            if datelastbackup.isEmpty == false {
                let date = datelastbackup.en_us_date_from_string()
                self.datelastbackup.stringValue = NSLocalizedString("Date last synchronize:", comment: "Remote Info")
                    + " " + date.localized_string_from_date()
            } else {
                self.datelastbackup.stringValue = NSLocalizedString("Date last synchronize:", comment: "Remote Info")
            }
            let numberlastbackup = self.configurations?.getConfigurations()[index].dayssincelastbackup ?? ""
            self.dayslastbackup.stringValue = NSLocalizedString("Days since last synchronize:", comment: "Remote Info")
                + " " + numberlastbackup
            if self.localremoteinfoDelegate?.getlocalremoteinfo(index: index)?.count ?? 0 > 0 {
                self.setcachedNumbers(dict: self.localremoteinfoDelegate?.getlocalremoteinfo(index: index))
            } else {
                if self.connected(config: self.configurations!.getConfigurations()[index]) == true {
                    self.working.startAnimation(nil)
                    self.outputprocess = OutputProcess()
                    _ = EstimateremoteInformationOnetask(index: index, outputprocess: self.outputprocess, local: true, updateprogress: self)
                } else {
                    self.gotit.stringValue = NSLocalizedString("Seems not to be connected...", comment: "Remote Info")
                    self.gotit.textColor = self.setcolor(nsviewcontroller: self, color: .green)
                }
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
                self.localtotalNumber.stringValue = infotask.totalNumber!
                self.localtotalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.localtotalDirs.stringValue = infotask.totalDirs!
                self.localremoteinfoDelegate!.setlocalremoteinfo(info: infotask.recordremotenumbers(index: self.index ?? -1))
            } else {
                self.transferredNumber.stringValue = infotask.transferredNumber!
                self.transferredNumberSizebytes.stringValue = infotask.transferredNumberSizebytes!
                self.totalNumber.stringValue = infotask.totalNumber!
                self.totalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.totalDirs.stringValue = infotask.totalDirs!
                self.newfiles.stringValue = infotask.newfiles!
                self.deletefiles.stringValue = infotask.deletefiles!
                self.localremoteinfoDelegate!.setlocalremoteinfo(info: infotask.recordremotenumbers(index: self.index ?? -1))
                self.working.stopAnimation(nil)
                self.gotit.stringValue = NSLocalizedString("Got it...", comment: "Remote Info")
                self.gotit.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            }
        }
    }

    private func setcachedNumbers(dict: [NSDictionary]?) {
        if let infodictes = dict {
            guard infodictes.count == 2 else { return }
            self.localtotalNumber.stringValue = (infodictes[0].value(forKey: "totalNumber") as? String) ?? ""
            self.localtotalNumberSizebytes.stringValue = (infodictes[0].value(forKey: "totalNumberSizebytes") as? String) ?? ""
            self.localtotalDirs.stringValue = (infodictes[0].value(forKey: "totalDirs") as? String) ?? ""
            self.transferredNumber.stringValue = (infodictes[1].value(forKey: "transferredNumber") as? String) ?? ""
            self.transferredNumberSizebytes.stringValue = (infodictes[1].value(forKey: "transferredNumberSizebytes") as? String) ?? ""
            self.totalNumber.stringValue = (infodictes[1].value(forKey: "totalNumber") as? String) ?? ""
            self.totalNumberSizebytes.stringValue = (infodictes[1].value(forKey: "totalNumberSizebytes") as? String) ?? ""
            self.totalDirs.stringValue = (infodictes[1].value(forKey: "totalDirs") as? String) ?? ""
            self.newfiles.stringValue = (infodictes[1].value(forKey: "newfiles") as? String) ?? ""
            self.deletefiles.stringValue = (infodictes[1].value(forKey: "deletefiles") as? String) ?? ""
            self.gotit.stringValue = NSLocalizedString("Loaded cached data...", comment: "Remote Info")
            self.gotit.textColor = self.setcolor(nsviewcontroller: self, color: .green)
        }
    }
}

extension ViewControllerInformationLocalRemote: UpdateProgress {
    func processTermination() {
        if self.complete == false {
            self.setnumbers(outputprocess: self.outputprocess, local: true)
        } else {
            self.setnumbers(outputprocess: self.outputprocess, local: false)
        }
        if let index = self.index {
            if self.complete == false {
                self.complete = true
                self.outputprocess = OutputProcess()
                _ = EstimateremoteInformationOnetask(index: index, outputprocess: self.outputprocess, local: false, updateprogress: self)
            }
        }
    }

    func fileHandler() {
        //
    }
}
