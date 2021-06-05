//
//  RsyncParameters.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

struct SetrsyncParameter {
    // Tuple for rsync argument and value
    typealias Argument = (String, Int)
    var rsyncparameters: [Argument]?

    // Computes the raw argument for rsync to save in configuration
    // Function for computing the raw argument for rsync to save in configuration
    // - parameter indexComboBox: index of selected ComboBox
    // - parameter value: the value of rsync parameter
    // - return: array of String
    func setrsyncparameter(indexComboBox: Int, value: String?) -> String {
        guard indexComboBox < rsyncparameters?.count ?? -1, indexComboBox > -1 else { return "" }
        switch rsyncparameters![indexComboBox].1 {
        case 0:
            // Predefined rsync argument from combobox
            // Must check if DELETE is selected
            if rsyncparameters![indexComboBox].0 == rsyncparameters![1].0 {
                return ""
            } else {
                return rsyncparameters![indexComboBox].0
            }
        case 1:
            // If value == nil value is deleted and return empty string
            guard value != nil else { return "" }
            if rsyncparameters![indexComboBox].0 != rsyncparameters![0].0 {
                return rsyncparameters![indexComboBox].0 + "=" + (value ?? "")
            } else {
                // Userselected argument and value
                return value ?? ""
            }
        default:
            return ""
        }
    }

    init() {
        rsyncparameters = SuffixstringsRsyncParameters().rsyncArguments
    }
}
