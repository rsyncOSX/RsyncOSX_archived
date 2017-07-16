//
//  RsyncParameters.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//swiftlint:disable syntactic_sugar cyclomatic_complexity

import Foundation

final class RsyncParameters {

    // Tuple for rsync argument and value
    typealias Argument = (String, Int)
    // Static initial arguments, DO NOT change order
    private let rsyncArguments: Array<Argument> = [
        ("user", 1),
        ("delete", 0),
        ("--stats", 0),
        ("--backup", 0),
        ("--backup-dir", 1),
        ("--exclude-from", 1),
        ("--include-from", 1),
        ("--files-from", 1),
        ("--max-size", 1),
        ("--suffix", 1)]

    // Array storing combobox values
    private var comboBoxValues: Array<String>?

    // Preselected parameters for storing a backup of deleted or changed files before
    // rsync synchronises the directories
    private let backupString = ["--backup", "--backup-dir=../backup"]
    private let suffixString = ["--suffix=_`date +'%Y-%m-%d.%H.%M'`"]
    private let suffixString2 = ["--suffix=_$(date +%Y-%m-%d.%H.%M)"]

    // Reference to config
    private var config: Configuration?

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
        guard self.comboBoxValues != nil else {
            return [""]
        }
        return self.comboBoxValues!
    }

    // Computes the raw argument for rsync to save in configuration
    /// Function for computing the raw argument for rsync to save in configuration
    /// - parameter indexComboBox: index of selected ComboBox
    /// - parameter value: the value of rsync parameter
    /// - return: array of String
    func getRsyncParameter (indexComboBox: Int, value: String?) -> String {
        guard  indexComboBox < self.rsyncArguments.count && indexComboBox > -1 else {
            return ""
        }
        switch self.rsyncArguments[indexComboBox].1 {
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
    private func indexValue (_ argument: String) -> Int {
        var index: Int = -1
        loop : for i in 0 ..< self.rsyncArguments.count {
            if argument == self.rsyncArguments[i].0 {
                index = i
                break loop
            }
        }
        return index
    }

    // Split an Rsync argument into argument and value
    private func split (_ str: String) -> Array<String> {
        let argument: String?
        let value: String?
        var split = str.components(separatedBy: "=")
        argument = String(split[0])
        if split.count > 1 {
            value = String(split[1])
        } else {
            value = argument
        }
        return [argument!, value!]
    }

    // Get the rsync parameter to store in the configuration.
    // Function computes which parameters are arguments only 
    // e.g --backup, or --suffix=value.
    func getdisplayValue (_ parameter: String) -> String {
        let splitstr: Array<String> = self.split(parameter)
        guard splitstr.count > 1 else {
            return ""
        }
        let argument = splitstr[0]
        let value = splitstr[1]
        if argument != value && self.indexValue(argument) >= 0 {
            return value
        } else {
            if self.indexValue(splitstr[0]) >= 0 {
                return "\"" + argument + "\" " + "no arguments"
            } else {
                guard argument != value else {
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
    func getvalueCombobox (_ parameter: String) -> Int {
        let splitstr: Array<String> = self.split(parameter)
        guard splitstr.count > 1 else {
            return 0
        }
        let argument = splitstr[0]
        let value = splitstr[1]
        if argument != value && self.indexValue(argument) >= 0 {
            return self.indexValue(argument)
        } else {
            guard self.indexValue(splitstr[0]) >= 0 else {
                return 0
            }
            return self.indexValue(argument)
        }
    }

    /// Function returns value of rsync a touple to set the corrosponding
    /// value in combobox and the corrosponding rsync value when rsync parameters are presented
    /// - parameter rsyncparameternumber : which stored rsync parameter, integer 8 - 14
    /// - returns : touple with index to for combobox and corresponding rsync value
    func getParameter (rsyncparameternumber: Int) -> (Int, String) {

        guard self.config != nil else {
            return (0, "")
        }

        switch rsyncparameternumber {
        case 8:
            guard self.config!.parameter8 != nil else {
                return (0, "")
            }
            return (self.getvalueCombobox(self.config!.parameter8!), self.getdisplayValue(self.config!.parameter8!))
        case 9:
            guard self.config!.parameter9 != nil else {
                return (0, "")
            }
            return (self.getvalueCombobox(self.config!.parameter9!), self.getdisplayValue(self.config!.parameter9!))
        case 10:
            guard self.config!.parameter10 != nil else {
                return (0, "")
            }
            return (self.getvalueCombobox(self.config!.parameter10!), self.getdisplayValue(self.config!.parameter10!))
        case 11:
            guard self.config!.parameter11 != nil else {
                return (0, "")
            }
            return (self.getvalueCombobox(self.config!.parameter11!), self.getdisplayValue(self.config!.parameter11!))
        case 12:
            guard self.config!.parameter12 != nil else {
                return (0, "")
            }
            return (self.getvalueCombobox(self.config!.parameter12!), self.getdisplayValue(self.config!.parameter12!))
        case 13:
            guard self.config!.parameter13 != nil else {
                return (0, "")
            }
            return (self.getvalueCombobox(self.config!.parameter13!), self.getdisplayValue(self.config!.parameter13!))
        case 14:
            guard self.config!.parameter14 != nil else {
                return (0, "")
            }
            return (self.getvalueCombobox(self.config!.parameter14!), self.getdisplayValue(self.config!.parameter14!))
        default:
            return (0, "")
        }
    }

    init(config: Configuration) {
        self.config = config
        // Set string array for Comboboxes
        self.comboBoxValues = nil
        self.comboBoxValues = Array<String>()
        for i in 0 ..< self.rsyncArguments.count {
            self.comboBoxValues!.append(self.rsyncArguments[i].0)
        }
    }
}
