//
//  RsyncParameters.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class rsyncParameters {
    
    // NSDictionary holding whic rsync arguments requiere and value
    // Filled during initializing of object
    private var rsyncArgumentsAndValue = [NSDictionary]()
    
    // Static initial arguments, DO NOT change order
    private let rsyncArguments:[String] = [
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
    
    private let backupString = ["--backup","--backup-dir=../backup","--suffix=_$(date +%Y-%m-%d.%H.%M)"]
    
    func getBackupString() -> [String] {
        return self.backupString
    }

    // Return static rsync arguments array
    func getArguments() -> [String] {
        return self.rsyncArguments
    }
    
    // Return rsync arguments as NSDictionary
    // NSDictionary holds info about rsync needs value or not
    func getArgumentsAndValues() -> [NSDictionary] {
        return self.rsyncArgumentsAndValue
    }
    
    // Predefined userselected paramaters are filled in a [NSMutableDictionary]
    private func fillargumentsDictionary() {
        var value:Bool = true
        for i in 0 ..< self.rsyncArguments.count {
            switch self.rsyncArguments[i] {
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
                "argument": self.rsyncArguments[i],
                "value":value,
                "index":i]
            self.rsyncArgumentsAndValue.append(dict)
        }
    }
    
    // Returns nil if new argument and value is entered
    private func argumentString (_ rsyncIndexargument: Int, value:String) -> String? {
        
        var str:String?
        var addValue:Bool?
        
        if rsyncIndexargument >= 0 {
            
            let rsyncarg = self.rsyncArguments[rsyncIndexargument]
            let result = self.rsyncArgumentsAndValue.filter({return ($0.value(forKey: "index") as? Int == rsyncIndexargument)})
            if result.count > 0 {
                addValue = (result[0].value(forKey: "value") as? Bool)!
            } else {
                addValue = false
            }
            
            if (addValue!) {
                if value.isEmpty {
                    str = nil
                } else {
                    if (rsyncarg != self.rsyncArguments[0]) {
                        str = rsyncarg + "=" + value
                    } else {
                        str = value
                    }
                }
            } else {
                if (rsyncarg == self.rsyncArguments[1]) {
                    str = "--stats"
                } else if (rsyncarg == self.rsyncArguments[2]) {
                    str = "--backup"
                } else if (rsyncarg == self.rsyncArguments[9]) {
                    str = ""
                } else {
                    str = value
                }
            }
        }
        return str
    }

    // Set correct rsyncparameter
    func getRsyncParameter (indexCombobox:Int, value:String?) -> String {
        if let str = self.argumentString(indexCombobox, value: value!) {
            return str
        } else {
            if (indexCombobox == 0 || indexCombobox == 9) {
                return  ""
            } else {
                return self.rsyncArguments[indexCombobox] + "=" + value!
            }
        }
    }
    
    
    // Returns Int value of argument
    private func indexValue (_ argument:String) -> Int {
        var index:Int = -1
        loop : for i in 0 ..< self.rsyncArguments.count {
            if argument == self.rsyncArguments[i] {
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

    
    init() {
        self.fillargumentsDictionary()
    }
}
