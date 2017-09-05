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
    func gethiddenID() -> Int
}

class ViewControllerScheduleDetails: NSViewController {

    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!

    // Delegate functions
    // Pick up hiddenID from row
    weak var getHiddenIDDelegate: GetHiddenID?
    // Protocolfunction for doing a refresh in ViewControllertabMain
    weak var refreshDelegate: RefreshtableView?
    // Protocolfunction for doing a refresh in ViewControllertabSchedule
    weak var refreshDelegate2: RefreshtableView?
    // Protocolfunction for dismiss the ViewController
    weak var dismissDelegate: DismissViewController?

    var hiddendID: Int?
    // Data for tableView
    var data: [NSMutableDictionary]?
    // Notification center
    var observationCenter: NSObjectProtocol!
    var tools: Tools?

    @IBOutlet weak var scheduletable: NSTableView!

    // Close view and either stop or delete Schedules
    @IBAction func close(_ sender: NSButton) {
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func update(_ sender: NSButton) {
        if let data = self.data {
            Schedules.shared.deleteorstopschedule(data : data)
            // Do a refresh of tableViews in both ViewControllertabMain and ViewControllertabSchedule
            self.refreshDelegate?.refresh()
            self.refreshDelegate2?.refresh()
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tools = Tools()
        if let pvc = self.presenting as? ViewControllertabMain {
            self.refreshDelegate = pvc
        }
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabSchedule {
            self.dismissDelegate = pvc2
            self.refreshDelegate2 = pvc2
        }
        // Do view setup here.
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        if let pvc3 = self.presenting as? ViewControllertabSchedule {
            self.getHiddenIDDelegate = pvc3
            self.hiddendID = self.getHiddenIDDelegate?.gethiddenID()
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.hiddendID = self.getHiddenIDDelegate?.gethiddenID()
        self.data = Schedules.shared.readschedule(self.hiddendID!)

        globalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
        self.localCatalog.stringValue = Configurations.shared.getResourceConfiguration(self.hiddendID!, resource: .localCatalog)
        self.remoteCatalog.stringValue = Configurations.shared.getResourceConfiguration(self.hiddendID!, resource: .remoteCatalog)
        self.offsiteServer.stringValue = Configurations.shared.getResourceConfiguration(self.hiddendID!, resource: .offsiteServer)
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

        // If active schedule color row blue
        var active: Bool = false

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
