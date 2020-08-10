//
//  ComboboxRsyncParameters.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct ComboboxRsyncParameters {
    // Array storing combobox values
    private var comboBoxValues: [String]?
    private var config: Configuration?

    // Function for getting for rsync arguments to use in ComboBoxes in ViewControllerRsyncParameters
    // - parameter none: none
    // - return : array of String
    func getComboBoxValues() -> [String] {
        return self.comboBoxValues ?? [""]
    }

    // Returns Int value of argument
    func indexofrsyncparameter(_ argument: String) -> Int {
        return SuffixstringsRsyncParameters().rsyncArguments.firstIndex(where: { $0.0 == argument }) ?? -1
    }

    // Split an Rsync argument into argument and value
    private func split(_ str: String) -> [String] {
        let argument: String?
        let value: String?
        var split = str.components(separatedBy: "=")
        argument = String(split[0])
        if split.count > 1 {
            if split.count > 2 {
                split.remove(at: 0)
                value = split.joined(separator: "=")
            } else {
                value = String(split[1])
            }
        } else {
            value = argument
        }
        return [argument!, value!]
    }

    // Function returns index and value of rsync argument to set the corrospending
    // value in combobox when rsync parameters are presented and stored in configuration
    func indexandvaluersyncparameter(_ parameter: String?) -> (Int, String) {
        guard parameter != nil else { return (0, "") }
        let splitstr: [String] = self.split(parameter!)
        guard splitstr.count > 1 else { return (0, "") }
        let argument = splitstr[0]
        let value = splitstr[1]
        var returnvalue: String?
        var returnindex: Int?
        if argument != value, self.indexofrsyncparameter(argument) >= 0 {
            returnvalue = value
            returnindex = self.indexofrsyncparameter(argument)
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
            if argument != value, self.indexofrsyncparameter(argument) >= 0 {
                returnindex = self.indexofrsyncparameter(argument)
            } else {
                if self.indexofrsyncparameter(splitstr[0]) >= 0 {
                    returnindex = self.indexofrsyncparameter(argument)
                } else {
                    returnindex = 0
                }
            }
        }
        return (returnindex ?? 0, returnvalue ?? "")
    }

    // Function returns value of rsync a touple to set the corrosponding
    // value in combobox and the corrosponding rsync value when rsync parameters are presented
    // - parameter rsyncparameternumber : which stored rsync parameter, integer 8 - 14
    // - returns : touple with index for combobox and corresponding rsync value
    func getParameter(rsyncparameternumber: Int) -> (Int, String) {
        guard self.config != nil else { return (0, "") }
        switch rsyncparameternumber {
        case 8:
            return self.indexandvaluersyncparameter(self.config?.parameter8)
        case 9:
            return self.indexandvaluersyncparameter(self.config?.parameter9)
        case 10:
            return self.indexandvaluersyncparameter(self.config?.parameter10)
        case 11:
            return self.indexandvaluersyncparameter(self.config?.parameter11)
        case 12:
            return self.indexandvaluersyncparameter(self.config?.parameter12)
        case 13:
            return self.indexandvaluersyncparameter(self.config?.parameter13)
        case 14:
            return self.indexandvaluersyncparameter(self.config?.parameter14)
        default:
            return (0, "")
        }
    }

    init(config: Configuration?) {
        self.config = config
        self.comboBoxValues = [String]()
        for i in 0 ..< SuffixstringsRsyncParameters().rsyncArguments.count {
            self.comboBoxValues?.append(SuffixstringsRsyncParameters().rsyncArguments[i].0)
        }
    }
}
