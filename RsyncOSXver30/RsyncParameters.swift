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
    private let rsyncArguments:Array<argument> = [
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
    // rsync synchronises the directories
    private let backupString = ["--backup","--backup-dir=../backup"]
    private let suffixString = ["--suffix=_`date +'%Y-%m-%d.%H.%M'`"]
    private let suffixString2 = ["--suffix=_$(date +%Y-%m-%d.%H.%M)"]

    /// Function for getting string for backup parameters
    /// - parameter none: none
    /// - return : array of String
    func getBackupString() -> Array<String> {
        return self.backupString
    }
    
    /// Function for getting string for suffix parameter
    /// - parameter none: none
    /// - return : array of String
    func getSuffixString() -> Array<String> {
        return self.suffixString
    }
    
    /// Function for getting string for alternative suffix parameter
    /// - parameter none: none
    /// - return : array of String
    func getSuffixString2() -> Array<String> {
        return self.suffixString2
    }

    /// Function for getting for rsync arguments to use in ComboBoxes in ViewControllerRsyncParameters
    /// - parameter none: none
    /// - return : array of String
    func getComboBoxValues() -> Array<String> {
        var values = Array<String>()
        for i in 0 ..< self.rsyncArguments.count {
            values.append(self.rsyncArguments[i].0)
        }
        return values
    }
    
    // Computes the raw argument for rsync to save in configuration
    /// Function for computing the raw argument for rsync to save in configuration
    /// - parameter indexComboBox: index of selected ComboBox
    /// - parameter value: the value of rsync parameter
    /// - return: array of String
    
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
    private func split (_ str:String) -> Array<String> {
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
        let splitstr:Array<String> = self.split(parameter)
        guard splitstr.count > 1 else {
            return ""
        }
        let argument = splitstr[0]
        let value = splitstr[1]
        if (argument != value && self.indexValue(argument) >= 0)  {
            return value
        } else {
            if self.indexValue(splitstr[0]) >= 0 {
                return "\"" + argument + "\" " + "no arguments"
            } else {
                guard (argument != value) else {
                    return value
                }
                return argument + "=" + value
            }
        }
    }
    
    /// Function returns value of rsync argument to set the corrospending
    /// value in combobox when rsync parameters are presented
    /// - parameter parameter : Stringvalue of parameter
    /// - returns : index of parameter
    func getvalueCombobox (_ parameter:String) -> Int {
        let splitstr:Array<String> = self.split(parameter)
        guard splitstr.count > 1 else {
            return 0
        }
        let argument = splitstr[0]
        let value = splitstr[1]
        if (argument != value && self.indexValue(argument) >= 0)  {
            return self.indexValue(argument)
        } else {
            guard self.indexValue(splitstr[0]) >= 0 else {
                return 0
            }
            return self.indexValue(argument)
        }
    }
    
    
    /// Function calculates all userparameters (param8 - param14)
    /// - parameter index: index of selected row
    /// - returns: array of values with keys "indexComboBox" and "rsyncParameter", array always holding 7 records
    func setValuesViewDidLoad(index:Int) -> Array<NSMutableDictionary>{
        var configurations:Array<configuration> = SharingManagerConfiguration.sharedInstance.getConfigurations()
        var values = Array<NSMutableDictionary>()
        values.append(self.getParamAsDictionary(config: configurations[index],parameter: 8))
        values.append(self.getParamAsDictionary(config: configurations[index],parameter: 9))
        values.append(self.getParamAsDictionary(config: configurations[index],parameter: 10))
        values.append(self.getParamAsDictionary(config: configurations[index],parameter: 11))
        values.append(self.getParamAsDictionary(config: configurations[index],parameter: 12))
        values.append(self.getParamAsDictionary(config: configurations[index],parameter: 13))
        values.append(self.getParamAsDictionary(config: configurations[index],parameter: 14))
        // Return values
        return values
    }

    // Function for creating NSMutableDictionary of stored rsync parameters
    private func getParamAsDictionary(config:configuration, parameter:Int) -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        var param:String?
        
        switch parameter {
        case 8:
            param = config.parameter8
        case 9:
            param = config.parameter9
        case 10:
            param = config.parameter10
        case 11:
            param = config.parameter11
        case 12:
            param = config.parameter12
        case 13:
            param = config.parameter13
        case 14:
            param = config.parameter14
        default:
            param = nil
        }
        if (param != nil) {
            dict.setObject(self.getvalueCombobox(param!), forKey: "indexComboBox" as NSCopying)
            dict.setObject(self.getdisplayValue(param!), forKey: "rsyncParameter" as NSCopying)
            return dict
        } else {
            dict.setObject(0, forKey: "indexComboBox" as NSCopying)
            dict.setObject("", forKey: "rsyncParameter" as NSCopying)
            return dict
        }
    }
}
