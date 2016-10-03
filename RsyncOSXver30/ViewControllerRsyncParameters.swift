//
//  ViewControllerRsyncParameters.swift
//  Rsync
//  The ViewController for rsync parameters.
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

// protocol for returning if userparams is updated or not
protocol RsyncUserParams : class {
    func rsyncuserparamsupdated()
}

// Protocol for sending selected index in tableView
// The protocol is implemented in ViewControllertabMain
protocol SendSelecetedIndex : class {
    func getindex() -> Int
}

class ViewControllerRsyncParameters: NSViewController {
    
    // Object for calculating rsync parameters
    var parameters : RsyncParameters?
    // Delegate returning params updated or not
    weak var userparamsupdated_delegate : RsyncUserParams?
    // Get index of selected row
    weak var getindex_delegate : SendSelecetedIndex?
    // Dismisser
    weak var dismiss_delegate:DismissViewController?
    // Reference to rsync parameters
    var argumentArray:[String]?
    var argumentDictionary:[NSDictionary]?
    
    @IBOutlet weak var viewParameter1: NSTextField!
    @IBOutlet weak var viewParameter2: NSTextField!
    @IBOutlet weak var viewParameter3: NSTextField!
    @IBOutlet weak var viewParameter4: NSTextField!
    @IBOutlet weak var viewParameter5: NSTextField!
    // user selected parameter
    @IBOutlet weak var viewParameter8: NSTextField!
    @IBOutlet weak var viewParameter9: NSTextField!
    @IBOutlet weak var viewParameter10: NSTextField!
    @IBOutlet weak var viewParameter11: NSTextField!
    @IBOutlet weak var viewParameter12: NSTextField!
    @IBOutlet weak var viewParameter13: NSTextField!
    @IBOutlet weak var viewParameter14: NSTextField!
    @IBOutlet weak var rsyncdaemon: NSButton!
    @IBOutlet weak var sshport: NSTextField!
    
    // Comboboxes
    @IBOutlet weak var parameter8: NSComboBox!
    @IBOutlet weak var parameter9: NSComboBox!
    @IBOutlet weak var parameter10: NSComboBox!
    @IBOutlet weak var parameter11: NSComboBox!
    @IBOutlet weak var parameter12: NSComboBox!
    @IBOutlet weak var parameter13: NSComboBox!
    @IBOutlet weak var parameter14: NSComboBox!
    
    @IBAction func close(_ sender: NSButton) {
         self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create RsyncParameters object and load initial parameters
        self.parameters = RsyncParameters()
        self.argumentArray = parameters!.getArguments()
        self.argumentDictionary = parameters!.getArgumentsAndValues()
        if let pvc = self.presenting as? ViewControllertabMain {
            self.userparamsupdated_delegate = pvc
            self.getindex_delegate = pvc
        }
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismiss_delegate = pvc2
        }
    }
 
    
    override func viewDidAppear() {
        super.viewDidAppear()
        var configurations:[configuration] = SharingManagerConfiguration.sharedInstance.getConfigurations()
        let index = self.getindex_delegate?.getindex()
        self.viewParameter1.stringValue = configurations[index!].parameter1
        self.viewParameter2.stringValue = configurations[index!].parameter2
        self.viewParameter3.stringValue = configurations[index!].parameter3
        self.viewParameter4.stringValue = configurations[index!].parameter4
        self.viewParameter5.stringValue = configurations[index!].parameter5 + " " + configurations[index!].parameter6
        
        if (configurations[index!].parameter8 != nil) {
            self.resetComboBox(self.parameter8, index: (self.parameters!.getvalueCombobox(configurations[index!].parameter8!)))
            self.viewParameter8.stringValue = self.parameters!.getdisplayValue(configurations[index!].parameter8!)
        } else {
            self.resetComboBox(self.parameter8, index: (0))
            self.viewParameter8.stringValue = ""
        }
        if (configurations[index!].parameter9 != nil) {
            self.resetComboBox(self.parameter9, index: (self.parameters!.getvalueCombobox(configurations[index!].parameter9!)))
            self.viewParameter9.stringValue = self.parameters!.getdisplayValue(configurations[index!].parameter9!)
        } else {
            self.resetComboBox(self.parameter9, index: (0))
            self.viewParameter9.stringValue = ""
        }
        if (configurations[index!].parameter10 != nil) {
            self.resetComboBox(self.parameter10, index: (self.parameters!.getvalueCombobox(configurations[index!].parameter10!)))
            self.viewParameter10.stringValue = self.parameters!.getdisplayValue(configurations[index!].parameter10!)
        } else {
            self.resetComboBox(self.parameter10, index: (0))
            self.viewParameter10.stringValue = ""
        }
        if (configurations[index!].parameter11 != nil) {
            self.resetComboBox(self.parameter11, index: (self.parameters!.getvalueCombobox(configurations[index!].parameter11!)))
            self.viewParameter11.stringValue = self.parameters!.getdisplayValue(configurations[index!].parameter11!)
        } else {
            self.resetComboBox(self.parameter11, index: (0))
            self.viewParameter11.stringValue = ""
        }
        if (configurations[index!].parameter12 != nil) {
            self.resetComboBox(self.parameter12, index: (self.parameters!.getvalueCombobox(configurations[index!].parameter12!)))
            self.viewParameter12.stringValue = self.parameters!.getdisplayValue(configurations[index!].parameter12!)
        } else {
            self.resetComboBox(self.parameter12, index: (0))
            self.viewParameter12.stringValue = ""
        }
        if (configurations[index!].parameter13 != nil) {
            self.resetComboBox(self.parameter13, index: (self.parameters!.getvalueCombobox(configurations[index!].parameter13!)))
            self.viewParameter13.stringValue = self.parameters!.getdisplayValue(configurations[index!].parameter13!)
        } else {
            self.resetComboBox(self.parameter13, index: (0))
            self.viewParameter13.stringValue = ""
        }
        if (configurations[index!].parameter14 != nil) {
            self.resetComboBox(self.parameter14, index: (self.parameters!.getvalueCombobox(configurations[index!].parameter14!)))
            self.viewParameter14.stringValue = self.parameters!.getdisplayValue(configurations[index!].parameter14!)
        } else {
            self.resetComboBox(self.parameter14, index: (0))
            self.viewParameter14.stringValue = ""
        }
        if (configurations[index!].rsyncdaemon != nil) {
            self.rsyncdaemon.state = configurations[index!].rsyncdaemon!
        } else {
            self.rsyncdaemon.state = NSOffState
        }
        if (configurations[index!].sshport != nil) {
            self.sshport.stringValue = String(configurations[index!].sshport!)
        }
    }
    
    @IBAction func update(_ sender: NSButton) {
        var Configurations:[configuration] = storeAPI.sharedInstance.getConfigurations()
        // Get the index of selected configuration
        let index = self.getindex_delegate?.getindex()
        Configurations[index!].parameter8 = self.parameters!.getRsyncParameter(indexCombobox: self.parameter8.indexOfSelectedItem, value: self.viewParameter8.stringValue)
        Configurations[index!].parameter9 = self.parameters!.getRsyncParameter(indexCombobox: self.parameter9.indexOfSelectedItem, value: self.viewParameter9.stringValue)
        Configurations[index!].parameter10 = self.parameters!.getRsyncParameter(indexCombobox: self.parameter10.indexOfSelectedItem, value: self.viewParameter10.stringValue)
        Configurations[index!].parameter11 = self.parameters!.getRsyncParameter(indexCombobox: self.parameter11.indexOfSelectedItem, value: self.viewParameter11.stringValue)
        Configurations[index!].parameter12 = self.parameters!.getRsyncParameter(indexCombobox: self.parameter12.indexOfSelectedItem, value: self.viewParameter12.stringValue)
        Configurations[index!].parameter13 = self.parameters!.getRsyncParameter(indexCombobox: self.parameter13.indexOfSelectedItem, value: self.viewParameter13.stringValue)
        Configurations[index!].parameter14 = self.parameters!.getRsyncParameter(indexCombobox: self.parameter14.indexOfSelectedItem, value: self.viewParameter14.stringValue)
        Configurations[index!].rsyncdaemon = self.rsyncdaemon.state
        if let port = self.sshport {
            Configurations[index!].sshport = Int(port.stringValue)
        }
        // Update configuration in memory before saving
        SharingManagerConfiguration.sharedInstance.updateConfigurations(Configurations[index!], index: index!)
        storeAPI.sharedInstance.saveConfigFromMemory()
        // notify an update
        self.userparamsupdated_delegate?.rsyncuserparamsupdated()
        // Send dismiss delegate message
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
        
    private func resetComboBox (_ combobox:NSComboBox, index:Int) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: self.argumentArray as [String]!)
        combobox.selectItem(at: index)
    }
    
}
