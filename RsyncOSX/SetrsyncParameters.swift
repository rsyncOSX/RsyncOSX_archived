//
//  RsyncParameters.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

struct SetrsyncParameters {

    // Tuple for rsync argument and value
    typealias Argument = (String, Int)
    var rsyncArguments: [Argument]?

    // Computes the raw argument for rsync to save in configuration
    // Function for computing the raw argument for rsync to save in configuration
    // - parameter indexComboBox: index of selected ComboBox
    // - parameter value: the value of rsync parameter
    // - return: array of String
    func getRsyncParameter (indexComboBox: Int, value: String?) -> String {
        guard  indexComboBox < self.rsyncArguments!.count && indexComboBox > -1 else { return "" }
        switch self.rsyncArguments![indexComboBox].1 {
        case 0:
            // Predefined rsync argument from combobox
            // Must check if DELETE is selected
            if self.rsyncArguments![indexComboBox].0 == self.rsyncArguments![1].0 {
                return ""
            } else {
                return  self.rsyncArguments![indexComboBox].0
            }
        case 1:
            // If value == nil value is deleted and return empty string
            guard value != nil else { return "" }
            if self.rsyncArguments![indexComboBox].0 != self.rsyncArguments![0].0 {
                return self.rsyncArguments![indexComboBox].0 + "=" + value!
            } else {
                // Userselected argument and value
                return value!
            }
        default:
            return  ""
        }
    }

    init() {
        self.rsyncArguments = SuffixstringsRsyncParameters().rsyncArguments
    }
}
