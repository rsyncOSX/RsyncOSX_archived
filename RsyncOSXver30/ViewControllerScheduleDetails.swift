//
//  ViewControllerScheduleDetails.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 06/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa


// Protocol for getting the hiddenID for a configuration
protocol GetHiddenID : class {
    func gethiddenID() -> Int
}

class ViewControllerScheduleDetails : NSViewController {
    
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    
    // Delegate functions
    // Pick up hiddenID from row
    weak var getHiddenID_delegate:GetHiddenID?
    weak var refresh_delegate:RefreshtableView?
    weak var refresh_delegate2:RefreshtableViewtabSchedule?
    // Dismisser
    weak var dismiss_delegate:DismissViewController?
    
    var hiddendID:Int?
    // Data for tableView
    var data:[NSMutableDictionary]?
    // Notification center
    var observationCenter : NSObjectProtocol!
    
    @IBOutlet weak var scheduletable: NSTableView!
    
    // Close view and either stop or delete Schedules
    @IBAction func close(_ sender: NSButton) {
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    @IBAction func update(_ sender: NSButton) {
        if let data = self.data {
            SharingManagerSchedule.sharedInstance.deleteOrStopSchedules(data : data)
            self.refresh_delegate?.refresh()
            self.refresh_delegate2?.refreshInSchedule()
        }
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pvc = self.presenting as? ViewControllertabMain {
            self.refresh_delegate = pvc
        }
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabSchedule {
            self.dismiss_delegate = pvc2
            self.refresh_delegate2 = pvc2
        }
        // Do view setup here.
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        if let pvc3 = self.presenting as? ViewControllertabSchedule {
            self.getHiddenID_delegate = pvc3
            self.hiddendID = self.getHiddenID_delegate?.gethiddenID()
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.hiddendID = self.getHiddenID_delegate?.gethiddenID()
        self.data = SharingManagerSchedule.sharedInstance.readScheduledata(self.hiddendID!)
        
        GlobalMainQueue.async(execute: { () -> Void in
            self.scheduletable.reloadData()
        })
        self.localCatalog.stringValue = SharingManagerConfiguration.sharedInstance.getlocalCatalog(self.hiddendID!)
        self.remoteCatalog.stringValue = SharingManagerConfiguration.sharedInstance.getremoteCatalog(self.hiddendID!)
        self.offsiteServer.stringValue = SharingManagerConfiguration.sharedInstance.getoffSiteserver(self.hiddendID!)
    }
}

extension ViewControllerScheduleDetails : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if (self.hiddendID != nil && self.data != nil) {
            return (self.data!.count)
        } else {
            return 0
        }
    }
    
}

extension ViewControllerScheduleDetails : NSTableViewDelegate {
    
    // TableView delegates
    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if (row < self.data!.count) {
            let object:NSMutableDictionary = self.data![row]
            if ((tableColumn!.identifier) == "stopCellID" || (tableColumn!.identifier) == "deleteCellID") {
                return object[tableColumn!.identifier] as? Int
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
        return nil
    }

    @objc(tableView:setObjectValue:forTableColumn:row:) func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if ((tableColumn!.identifier) == "stopCellID" || (tableColumn!.identifier) == "deleteCellID") {
            switch tableColumn!.identifier {
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
