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
    
    // Delegate returning params updated or not
    weak var userparamsupdated_delegate : RsyncUserParams?
    // Get index of selected row
    weak var getindex_delegate : SendSelecetedIndex?
    // Dismisser
    weak var dismiss_delegate:DismissViewController?
    
    // Static initial arguments
    // DO NOT change order
    let staticargumentArray:[String] = [
        "select",
        "--stats",
        "--backup",
        "--backup-dir",
        "--exclude-from",
        "--include-from",
        "--files-from",
        "--max-size",
        "--suffix",
        "delete"]
    
    // --backup-dir=../backup
    // --suffix=_$(date +%Y-%m-%d.%H.%M)
    
    var argumentArray:[String]?
    var argumentDictionary = [NSMutableDictionary]()
    
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
        
        // Initialize rsyncarguments
        self.argumentDictionary.removeAll()
        self.fillargumentsDictionary()
        self.argumentArray = self.createArgumentsDictionary()
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
        
        var Configurations = SharingManagerConfiguration.sharedInstance.getConfigurations()
        let index = self.getindex_delegate?.getindex()
        
        self.viewParameter1.stringValue = Configurations[index!].parameter1
        self.viewParameter2.stringValue = Configurations[index!].parameter2
        self.viewParameter3.stringValue = Configurations[index!].parameter3
        self.viewParameter4.stringValue = Configurations[index!].parameter4
        self.viewParameter5.stringValue = Configurations[index!].parameter5 + " " + Configurations[index!].parameter6
        
        if (Configurations[index!].parameter8 != nil) {
            self.displayValues(self.viewParameter8, box: self.parameter8, parameter: Configurations[index!].parameter8!)
        } else {
            self.resetComboBox(self.parameter8, index: (0))
            self.viewParameter8.stringValue = ""
        }
        if (Configurations[index!].parameter9 != nil) {
            self.displayValues(self.viewParameter9, box: self.parameter9, parameter: Configurations[index!].parameter9!)
        } else {
            self.resetComboBox(self.parameter9, index: (0))
            self.viewParameter9.stringValue = ""
        }
        if (Configurations[index!].parameter10 != nil) {
            self.displayValues(self.viewParameter10, box: self.parameter10, parameter: Configurations[index!].parameter10!)
        } else {
            self.resetComboBox(self.parameter10, index: (0))
            self.viewParameter10.stringValue = ""
        }
        if (Configurations[index!].parameter11 != nil) {
            self.displayValues(self.viewParameter11, box: self.parameter11, parameter: Configurations[index!].parameter11!)
        } else {
            self.resetComboBox(self.parameter11, index: (0))
            self.viewParameter11.stringValue = ""
        }
        if (Configurations[index!].parameter12 != nil) {
            self.displayValues(self.viewParameter12, box: self.parameter12, parameter: Configurations[index!].parameter12!)
        } else {
            self.resetComboBox(self.parameter12, index: (0))
            self.viewParameter12.stringValue = ""
        }
        if (Configurations[index!].parameter13 != nil) {
            self.displayValues(self.viewParameter13, box: self.parameter13, parameter: Configurations[index!].parameter13!)
        } else {
            self.resetComboBox(self.parameter13, index: (0))
            self.viewParameter13.stringValue = ""
        }
        if (Configurations[index!].parameter14 != nil) {
            self.displayValues(self.viewParameter14, box: self.parameter14, parameter: Configurations[index!].parameter14!)
        } else {
            self.resetComboBox(self.parameter14, index: (0))
            self.viewParameter14.stringValue = ""
        }
        if (Configurations[index!].rsyncdaemon != nil) {
            self.rsyncdaemon.state = Configurations[index!].rsyncdaemon!
        } else {
            self.rsyncdaemon.state = NSOffState
        }
        if (Configurations[index!].sshport != nil) {
            self.sshport.stringValue = String(Configurations[index!].sshport!)
        }

    }
    
    @IBAction func update(_ sender: NSButton) {
        
        var Configurations = storeAPI.sharedInstance.getConfigurations()
        // Get the index of selected configuration
        let index = self.getindex_delegate?.getindex()
        
        if let str = self.argumentString(self.parameter8.indexOfSelectedItem, value: self.viewParameter8.stringValue) {
            Configurations[index!].parameter8 = str
        } else {
            if (self.param(str1: self.parameter8.stringValue)) {
                Configurations[index!].parameter8 = self.parameter8.stringValue + "=" + self.viewParameter8.stringValue
            } else {
                Configurations[index!].parameter8 = ""
            }
        }
        if let str = self.argumentString(self.parameter9.indexOfSelectedItem, value: self.viewParameter9.stringValue) {
            Configurations[index!].parameter9 = str
        } else {
            if (self.param(str1: self.parameter9.stringValue)) {
                Configurations[index!].parameter9 = self.parameter9.stringValue + "=" + self.viewParameter9.stringValue
            } else {
                Configurations[index!].parameter9 = ""
            }
        }
        if let str = self.argumentString(self.parameter10.indexOfSelectedItem, value: self.viewParameter10.stringValue) {
            Configurations[index!].parameter10 = str
        } else {
            if (self.param(str1: self.parameter10.stringValue)) {
                Configurations[index!].parameter10 = self.parameter10.stringValue + "=" + self.viewParameter10.stringValue
            } else {
                Configurations[index!].parameter10 = ""
            }
        }
        if let str = self.argumentString(self.parameter11.indexOfSelectedItem, value: self.viewParameter11.stringValue) {
            Configurations[index!].parameter11 = str
        } else {
            if (self.param(str1: self.parameter11.stringValue)) {
                Configurations[index!].parameter11 = self.parameter11.stringValue + "=" + self.viewParameter11.stringValue
            } else {
                Configurations[index!].parameter11 = ""
            }
        }
        if let str = self.argumentString(self.parameter12.indexOfSelectedItem, value: self.viewParameter12.stringValue) {
            Configurations[index!].parameter12 = str
        } else {
            if (self.param(str1: self.parameter12.stringValue)) {
                Configurations[index!].parameter12 = self.parameter12.stringValue + "=" + self.viewParameter12.stringValue
            } else {
                Configurations[index!].parameter12 = ""
            }
        }
        if let str = self.argumentString(self.parameter13.indexOfSelectedItem, value: self.viewParameter13.stringValue) {
            Configurations[index!].parameter13 = str
        } else {
            if (self.param(str1: self.parameter13.stringValue)) {
                Configurations[index!].parameter13 = self.parameter13.stringValue + "=" + self.viewParameter13.stringValue
            } else {
                Configurations[index!].parameter13 = ""
            }
        }
        if let str = self.argumentString(self.parameter14.indexOfSelectedItem, value: self.viewParameter14.stringValue) {
            Configurations[index!].parameter14 = str
        } else {
            if (self.param(str1: self.parameter14.stringValue)) {
                Configurations[index!].parameter14 = self.parameter14.stringValue + "=" + self.viewParameter14.stringValue

            } else {
                Configurations[index!].parameter14 = ""
            }
        }
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
    
    
    // Returns Int value of argument
    private func valueInt (_ argument:String) -> Int {
        var index:Int = -1
        loop : for i in 0 ..< self.argumentArray!.count {
            if argument == self.argumentArray![i] {
                index = i
                break loop
            }
        }
        return index
    }
    
    
    // Returns nil if new argument and value is entered
    private func argumentString (_ rsyncIndexargument: Int, value:String) -> String? {
        
        var str:String?
        var addValue:Bool?
        
        if rsyncIndexargument >= 0 {
            
            let rsyncarg = self.argumentArray?[rsyncIndexargument]
            let result = self.argumentDictionary.filter({return ($0.value(forKey: "index") as? Int == rsyncIndexargument)})
            if result.count > 0 {
                addValue = (result[0].value(forKey: "value") as? Bool)!
            } else {
                addValue = false
            }
            
            if (addValue!) {
                if value.isEmpty {
                    str = nil
                } else {
                    if (rsyncarg != self.argumentArray![0]) {
                        str = rsyncarg! + "=" + value
                    } else {
                        str = value
                    }
                }
            } else {
                if (rsyncarg == self.argumentArray![1]) {
                    str = "--stats"
                } else if (rsyncarg == self.argumentArray![2]) {
                    str = "--backup"
                } else if (rsyncarg == self.argumentArray![9]) {
                    str = ""
                } else {
                    str = value
                }
            }
        }
        return str
    }
    
    private func resetComboBox (_ combobox:NSComboBox, index:Int) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: self.argumentArray as [String]!)
        combobox.selectItem(at: index)
    }
    
    // Split an Rsync argument into argument and value
    private func split (_ str:String) -> [String] {
        let argument:String?
        let value:String?
        var split = str.components(separatedBy: "=")
        argument = String(split[0])
        if split.count > 1 {
            value = String(split[1])
        } else {
            value = argument
        }
        return [argument!,value!]
    }
    
    // Display value in combobox and value
    private func displayValues (_ textfield: NSTextField, box: NSComboBox, parameter:String) {
        self.resetComboBox(box, index: (self.argumentArray!.count - 1))
        let splitstr:[String] = self.split(parameter)
        if splitstr.count > 1 {
            let argument = splitstr[0]
            let value = splitstr[1]
            if (argument != value && self.valueInt(argument) >= 0)  {
                box.selectItem(at: self.valueInt(argument))
                textfield.stringValue = value
            } else {
                if self.valueInt(splitstr[0]) >= 0 {
                    box.selectItem(at: self.valueInt(argument))
                    let txt = "\"" + argument + "\" " + "no arguments"
                    textfield.stringValue = txt
                } else {
                    box.selectItem(at: 0)
                    if (argument != value) {
                        textfield.stringValue = argument + "=" + value
                    } else {
                        textfield.stringValue = value
                    }
                }
            }
        }
    }
    
    // Predefined userselected paramaters are filled in a [NSMutableDictionary]
    private func fillargumentsDictionary() {
        var value:Bool = true
        for i in 0 ..< self.staticargumentArray.count {
            switch self.staticargumentArray[i] {
            case "delete":
                value = false
            case "--stats":
                value = false
            case "--backup":
                value = false
            default:
                value = true
            }
            let dict:NSMutableDictionary = [
                "argument": self.staticargumentArray[i],
                "value":value,
                "index":i
            ]
            self.argumentDictionary.append(dict)
        }
    }
    
    // Function to validate if parameter is to be set nil or not
    // Used in function update
    private func param(str1:String) -> Bool {
        if str1 == "delete" {
            return false
        } else if str1 == "select" {
            return false
        } else {
            return true
        }
    }
    
    
    // Predefined rsyncarguments are filled in here, the user might in
    // the future fill in theire own parameters
    private func createArgumentsDictionary() -> [String]{
        var createargumentArray = [String]()
        for i in 0 ..< self.argumentDictionary.count {
            createargumentArray.append((self.argumentDictionary[i].value(forKey: "argument") as? String)!)
        }
        return createargumentArray
    }
    
    // Return index of an presedefined argument
    func indexOfargument(_ argument : String) -> Int {
        let result = self.argumentDictionary.filter({return ($0.value(forKey: "argument") as? String == argument)})
        if (result.count > 0) {
            let dict:NSDictionary = result[0]
            return (dict.value(forKey: "index") as? Int)!
        } else {
            return -1
        }
    }
    
}
