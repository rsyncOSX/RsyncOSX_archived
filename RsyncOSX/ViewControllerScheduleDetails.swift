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
protocol GetHiddenID : class {
    func gethiddenID() -> Int?
}

class ViewControllerScheduleDetails: NSViewController {

    weak var configurationsDelegate: GetConfigurationsObject?
    var configurations: Configurations?
    weak var schedulesDelegate: GetSchedulesObject?
    var schedules: Schedules?

    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!

    weak var getHiddenIDDelegate: GetHiddenID?
    // Protocolfunction for doing a refresh in ViewControllertabMain
    weak var refreshDelegate: Reloadandrefresh?
    weak var refreshDelegate2: Reloadandrefresh?
    weak var dismissDelegate: DismissViewController?

    var hiddendID: Int?
    var data: [NSMutableDictionary]?
    var tools: Tools?

    @IBOutlet weak var scheduletable: NSTableView!

    // Close view and either stop or delete Schedules
    @IBAction func close(_ sender: NSButton) {
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func update(_ sender: NSButton) {
        if let data = self.data {
            self.schedules!.deleteorstopschedule(data : data)
            // Do a refresh of tableViews in both ViewControllertabMain and ViewControllertabSchedule
            self.refreshDelegate?.reloadtabledata()
            self.refreshDelegate2?.reloadtabledata()
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tools = Tools()
        self.refreshDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.refreshDelegate2 = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        self.configurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.schedulesDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.configurations = self.configurationsDelegate?.getconfigurationsobject()
        self.schedules = self.schedulesDelegate?.getschedulesobject()
        // Decide which viewcontroller calling the view
        if self.configurations!.allowNotifyinMain == true {
            self.getHiddenIDDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        } else {
            self.getHiddenIDDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
            self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
        }
        self.hiddendID = self.getHiddenIDDelegate?.gethiddenID()
        self.data = self.schedules!.readscheduleonetask(self.hiddendID)
        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
        guard self.hiddendID != nil else {
            return
        }
        self.localCatalog.stringValue = self.configurations!.getResourceConfiguration(self.hiddendID!, resource: .localCatalog)
        self.remoteCatalog.stringValue = self.configurations!.getResourceConfiguration(self.hiddendID!, resource: .remoteCatalog)
        self.offsiteServer.stringValue = self.configurations!.getResourceConfiguration(self.hiddendID!, resource: .offsiteServer)
        if self.tools == nil { self.tools = Tools()}
    }
}

extension ViewControllerScheduleDetails : NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if self.hiddendID != nil && self.data != nil {
            return (self.data!.count)
        } else {
            return 0
        }
    }

}

extension ViewControllerScheduleDetails : NSTableViewDelegate {

    // TableView delegates
    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        // If active schedule color row red
        var active: Bool = false
        guard self.data != nil else {
            return nil
        }
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
                    let attributedString = NSMutableAttributedString(string:(text!))
                    let range = (text! as NSString).range(of: text!)
                    attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: NSColor.red, range: range)
                    return attributedString
                } else {
                    return object[tableColumn!.identifier] as? String
                }
            }
        }
        return nil
    }

    @objc(tableView:setObjectValue:forTableColumn:row:) func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if tableColumn!.identifier.rawValue == "stopCellID" || tableColumn!.identifier.rawValue == "deleteCellID" {
            switch tableColumn!.identifier.rawValue {
            case "stopCellID":
                self.data![row].setValue(1, forKey: "stopCellID")
            case "deleteCellID":
                self.data![row].setValue(1, forKey: "deleteCellID")
            default:
                break
            }
        }
    }

}
