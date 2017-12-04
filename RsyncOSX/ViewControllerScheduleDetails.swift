//
//  ViewControllerScheduleDetails.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 06/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

// Protocol for getting the hiddenID for a configuration
protocol GetHiddenID: class {
    func gethiddenID() -> Int?
}

class ViewControllerScheduleDetails: NSViewController, SetConfigurations, SetSchedules, SetDismisser, ReloadTable {

    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    weak var getHiddenIDDelegate: GetHiddenID?

    var hiddendID: Int?
    var data: [NSMutableDictionary]?
    var tools: Tools?

    @IBOutlet weak var scheduletable: NSTableView!

    // Close view and either stop or delete Schedules
    @IBAction func close(_ sender: NSButton) {
        if self.configurations!.allowNotifyinMain == true {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else {
            self.dismissview(viewcontroller: self, vcontroller: .vctabschedule)
        }
    }

    @IBAction func update(_ sender: NSButton) {
        if let data = self.data {
            self.schedules!.deleteorstopschedule(data: data)
            self.reloadtable(vcontroller: .vctabmain)
            self.reloadtable(vcontroller: .vctabschedule)
        }
        if self.configurations!.allowNotifyinMain == true {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else {
            self.dismissview(viewcontroller: self, vcontroller: .vctabschedule)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tools = Tools()
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Decide which viewcontroller calling the view
        if self.configurations!.allowNotifyinMain == true {
            self.getHiddenIDDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        } else {
            self.getHiddenIDDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
        }
        self.hiddendID = self.getHiddenIDDelegate?.gethiddenID()
        self.data = self.schedules!.readscheduleonetask(self.hiddendID)
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
        guard self.hiddendID != nil else { return }
        self.localCatalog.stringValue = self.configurations!.getResourceConfiguration(self.hiddendID!, resource: .localCatalog)
        self.remoteCatalog.stringValue = self.configurations!.getResourceConfiguration(self.hiddendID!, resource: .remoteCatalog)
        self.offsiteServer.stringValue = self.configurations!.getResourceConfiguration(self.hiddendID!, resource: .offsiteServer)
        if self.tools == nil { self.tools = Tools()}
    }
}

extension ViewControllerScheduleDetails: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if self.hiddendID != nil && self.data != nil {
            return (self.data!.count)
        } else {
            return 0
        }
    }

}

extension ViewControllerScheduleDetails: NSTableViewDelegate, Attributtedestring {

    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        // If active schedule color row red
        var active: Bool = false
        guard self.data != nil else { return nil }
        if row < self.data!.count {
            let object: NSMutableDictionary = self.data![row]
            if  object.value(forKey: "schedule") as? String == "once" ||
                object.value(forKey: "schedule") as? String == "daily" ||
                object.value(forKey: "schedule") as? String == "weekly" {
                let dateformatter = self.tools!.setDateformat()
                let dateStop: Date = dateformatter.date(from: (object.value(forKey: "dateStop") as? String)!)!
                if dateStop.timeIntervalSinceNow > 0 {
                    active = true
                } else {
                    active = false
                }
            }
            if tableColumn!.identifier.rawValue == "stopCellID" || tableColumn!.identifier.rawValue == "deleteCellID" {
                   return object[tableColumn!.identifier] as? Int
            } else {
                if active {
                    let text = object[tableColumn!.identifier] as? String
                    return self.attributtedstring(str: text!, color: NSColor.green, align: .left)
                } else {
                    return object[tableColumn!.identifier] as? String
                }
            }
        }
        return nil
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if tableColumn!.identifier.rawValue == "stopCellID" || tableColumn!.identifier.rawValue == "deleteCellID" {
            var stop: Int = (self.data![row].value(forKey: "stopCellID") as? Int)!
            var delete: Int = (self.data![row].value(forKey: "deleteCellID") as? Int)!
            if stop == 0 { stop = 1 } else if stop == 1 { stop = 0 }
            if delete == 0 { delete = 1 } else if delete == 1 { delete = 0 }
            switch tableColumn!.identifier.rawValue {
            case "stopCellID":
                self.data![row].setValue(stop, forKey: "stopCellID")
            case "deleteCellID":
                self.data![row].setValue(delete, forKey: "deleteCellID")
            default:
                break
            }
        }
    }

}
