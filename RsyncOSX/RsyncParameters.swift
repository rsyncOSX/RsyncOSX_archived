//
//  RsyncParameters.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

final class RsyncParameters {

    // Tuple for rsync argument and value
    typealias Argument = (String, Int)
    // Static initial arguments, DO NOT change order
    private let rsyncArguments: Array<Argument> = [
        ("user", 1),
        ("delete", 0),
        ("--backup", 0),
        ("--backup-dir", 1),
        ("--exclude-from", 1),
        ("--include-from", 1),
        ("--files-from", 1),
        ("--max-size", 1),
        ("--suffix", 1),
        ("--max-delete", 1)]

    // Array storing combobox values
    private var comboBoxValues: Array<String>?

    // Preselected parameters for storing a backup of deleted or changed files before
    // rsync synchronises the directories
    private let backupString = ["--backup", "--backup-dir=../backup"]
    private let suffixString = ["--suffix=_`date +'%Y-%m-%d.%H.%M'`"]
    private let suffixString2 = ["--suffix=_$(date +%Y-%m-%d.%H.%M)"]
    private let donotdeletefiles = ["--max-delete=-1"]

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

    func getdonotdeletefilesString() -> Array<String> {
        return self.donotdeletefiles
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
    private func indexofrsyncparameter (_ argument: String) -> Int {
        var index: Int = -1
        loop : for i in 0 ..< self.rsyncArguments.count where argument == self.rsyncArguments[i].0 {
            index = i
            break loop
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

    /// Function returns index and value of rsync argument to set the corrospending
    /// value in combobox when rsync parameters are presented and stored in configuration
    func indexandvaluersyncparameter(_ parameter: String?) -> (Int, String) {
        guard parameter != nil else {
            return (0, "")
        }
        let splitstr: Array<String> = self.split(parameter!)
        guard splitstr.count > 1 else {
            return (0, "")
        }
        let argument = splitstr[0]
        let value = splitstr[1]
        var returnvalue: String?
        var returnindex: Int?

        if argument != value && self.indexofrsyncparameter(argument) >= 0 {
            returnvalue = value
            returnindex =  self.indexofrsyncparameter(argument)
        } else {
            if self.indexofrsyncparameter(splitstr[0]) >= 0 {
                returnvalue = "\"" + argument + "\" " + "no arguments"
            } else {
                if argument == value {
                    returnvalue = value
                } else {
                    returnvalue = argument + "=" + value
                }
            }
            if argument != value && self.indexofrsyncparameter(argument) >= 0 {
                returnindex =  self.indexofrsyncparameter(argument)
            } else {
                if self.indexofrsyncparameter(splitstr[0]) >= 0 {
                    returnindex = self.indexofrsyncparameter(argument)
                } else {
                    returnindex = 0
                }
            }
        }
        return (returnindex!, returnvalue!)
    }

    /// Function returns value of rsync a touple to set the corrosponding
    /// value in combobox and the corrosponding rsync value when rsync parameters are presented
    /// - parameter rsyncparameternumber : which stored rsync parameter, integer 8 - 14
    /// - returns : touple with index for combobox and corresponding rsync value
    func getParameter (rsyncparameternumber: Int) -> (Int, String) {
        var indexandvalue: (Int, String)?
        guard self.config != nil else {
            return (0, "")
        }
        switch rsyncparameternumber {
        case 8:
           indexandvalue = self.indexandvaluersyncparameter(self.config!.parameter8)
        case 9:
            indexandvalue = self.indexandvaluersyncparameter(self.config!.parameter9)
        case 10:
            indexandvalue = self.indexandvaluersyncparameter(self.config!.parameter10)
        case 11:
            indexandvalue = self.indexandvaluersyncparameter(self.config!.parameter11)
        case 12:
            indexandvalue = self.indexandvaluersyncparameter(self.config!.parameter12)
        case 13:
            indexandvalue = self.indexandvaluersyncparameter(self.config!.parameter13)
        case 14:
            indexandvalue = self.indexandvaluersyncparameter(self.config!.parameter14)
        default:
            return (0, "")
        }
        return indexandvalue!
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
