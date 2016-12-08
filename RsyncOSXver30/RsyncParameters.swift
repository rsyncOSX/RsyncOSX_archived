//
//  RsyncParameters.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class RsyncParameters {
    
    // Tuple for rsync argument and value
    typealias argument = (String , Int)
    // Static initial arguments, DO NOT change order
    private let rsyncArguments:[argument] = [
        ("user",1),
        ("delete",0),
        ("--stats",0),
        ("--backup",0),
        ("--backup-dir",1),
        ("--exclude-from",1),
        ("--include-from",1),
        ("--files-from",1),
        ("--max-size",1),
        ("--suffix",1)]
    
    // Preselected parameters for storing a backup of deleted or changed files before
    // rsync synchonises the directories
    private let backupString = ["--backup","--backup-dir=../backup","--suffix=_$(date +%Y-%m-%d.%H.%M)"]

    // Getter for backup parameters
    func getBackupString() -> [String] {
        return self.backupString
    }

    // Getter for rsync arguments to use in comboxes in ViewControllerRsyncParameters
    func getComboBoxValues() -> [String] {
        var values = Array<String>()
        for i in 0 ..< self.rsyncArguments.count {
            values.append(self.rsyncArguments[i].0)
        }
        return values
    }
    
    // Computes the raw argument for rsync to save in configuration
    func getRsyncParameter (indexComboBox:Int, value:String?) -> String {
        
        guard  indexComboBox < self.rsyncArguments.count else {
            return ""
        }
        
        switch (self.rsyncArguments[indexComboBox].1) {
        case 0:
            // Predefined rsync argument from combobox
            // Must check if DELETE is selected
            if self.rsyncArguments[indexComboBox].0 == self.rsyncArguments[1].0 {
                return ""
            } else {
                return  self.rsyncArguments[indexComboBox].0
            }
        case 1:
            // If value == nil value is deleted and return empty string
            guard value != nil else {
                return ""
            }
            if self.rsyncArguments[indexComboBox].0 != self.rsyncArguments[0].0 {
                return self.rsyncArguments[indexComboBox].0 + "=" + value!
            } else {
                // Userselected argument and value
                return value!
            }
        default:
            return  ""
        }
    }
    
    
    // Returns Int value of argument
    private func indexValue (_ argument:String) -> Int {
        var index:Int = -1
        loop : for i in 0 ..< self.rsyncArguments.count {
            if argument == self.rsyncArguments[i].0 {
                index = i
                break loop
            }
        }
        return index
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
    
    // Get the rsync parameter to store in the configuration.
    // Function computes which parameters are arguments only 
    // e.g --backup, or --suffix=value.
    func getdisplayValue (_ parameter:String) -> String {
        let splitstr:[String] = self.split(parameter)
        if splitstr.count > 1 {
            let argument = splitstr[0]
            let value = splitstr[1]
            if (argument != value && self.indexValue(argument) >= 0)  {
                return value
            } else {
                if self.indexValue(splitstr[0]) >= 0 {
                    return "\"" + argument + "\" " + "no arguments"
                } else {
                    if (argument != value) {
                        return argument + "=" + value
                    } else {
                        return value
                    }
                }
            }
        } else {
            return ""
        }
    }
    
    /// Function returns value of rsync argument to set the corrospending
    /// value in combobox when rsync parameters are presented
    /// - parameter parameter : Stringvalue of parameter
    /// - returns : index of parameter
    func getvalueCombobox (_ parameter:String) -> Int {
        let splitstr:[String] = self.split(parameter)
        if splitstr.count > 1 {
            let argument = splitstr[0]
            let value = splitstr[1]
            if (argument != value && self.indexValue(argument) >= 0)  {
                return self.indexValue(argument)
            } else {
                if self.indexValue(splitstr[0]) >= 0 {
                    return self.indexValue(argument)
                } else {
                    return 0
                }
            }
        }
        return 0
    }
    
    
    /// Function calculates all userparameters (param8 - param14)
    /// - parameter index: index of selected row
    /// - returns: array of values with keys "indexComboBox" and "rsyncParameter", array always holding 7 records
    
    func setValuesViewDidLoad(index:Int) -> [NSMutableDictionary] {
        
        var configurations:[configuration] = SharingManagerConfiguration.sharedInstance.getConfigurations()
        var values = [NSMutableDictionary]()
    
        if (configurations[index].parameter8 != nil) {
            let dict = NSMutableDictionary()
            dict.setObject(self.getvalueCombobox(configurations[index].parameter8!), forKey: "indexComboBox" as NSCopying)
            dict.setObject(self.getdisplayValue(configurations[index].parameter8!), forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        } else {
            let dict = NSMutableDictionary()
            dict.setObject(0, forKey: "indexComboBox" as NSCopying)
            dict.setObject("", forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        }
        if (configurations[index].parameter9 != nil) {
            let dict = NSMutableDictionary()
            dict.setObject(self.getvalueCombobox(configurations[index].parameter9!), forKey: "indexComboBox" as NSCopying)
            dict.setObject(self.getdisplayValue(configurations[index].parameter9!), forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        } else {
            let dict = NSMutableDictionary()
            dict.setObject(0, forKey: "indexComboBox" as NSCopying)
            dict.setObject("", forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        }
        if (configurations[index].parameter10 != nil) {
            let dict = NSMutableDictionary()
            dict.setObject(self.getvalueCombobox(configurations[index].parameter10!), forKey: "indexComboBox" as NSCopying)
            dict.setObject(self.getdisplayValue(configurations[index].parameter10!), forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        } else {
            let dict = NSMutableDictionary()
            dict.setObject(0, forKey: "indexComboBox" as NSCopying)
            dict.setObject("", forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        }
        if (configurations[index].parameter11 != nil) {
            let dict = NSMutableDictionary()
            dict.setObject(self.getvalueCombobox(configurations[index].parameter11!), forKey: "indexComboBox" as NSCopying)
            dict.setObject(self.getdisplayValue(configurations[index].parameter11!), forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        } else {
            let dict = NSMutableDictionary()
            dict.setObject(0, forKey: "indexComboBox" as NSCopying)
            dict.setObject("", forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        }
        if (configurations[index].parameter12 != nil) {
            let dict = NSMutableDictionary()
            dict.setObject(self.getvalueCombobox(configurations[index].parameter12!), forKey: "indexComboBox" as NSCopying)
            dict.setObject(self.getdisplayValue(configurations[index].parameter12!), forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        } else {
            let dict = NSMutableDictionary()
            dict.setObject(0, forKey: "indexComboBox" as NSCopying)
            dict.setObject("", forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        }
        if (configurations[index].parameter13 != nil) {
            let dict = NSMutableDictionary()
            dict.setObject(self.getvalueCombobox(configurations[index].parameter13!), forKey: "indexComboBox" as NSCopying)
            dict.setObject(self.getdisplayValue(configurations[index].parameter13!), forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        } else {
            let dict = NSMutableDictionary()
            dict.setObject(0, forKey: "indexComboBox" as NSCopying)
            dict.setObject("", forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        }
        if (configurations[index].parameter14 != nil) {
            let dict = NSMutableDictionary()
            dict.setObject(self.getvalueCombobox(configurations[index].parameter14!), forKey: "indexComboBox" as NSCopying)
            dict.setObject(self.getdisplayValue(configurations[index].parameter14!), forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        } else {
            let dict = NSMutableDictionary()
            dict.setObject(0, forKey: "indexComboBox" as NSCopying)
            dict.setObject("", forKey: "rsyncParameter" as NSCopying)
            values.append(dict)
        }
        // Return values
        return values
    }

}
