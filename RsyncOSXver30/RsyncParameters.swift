//
//  RsyncParameters.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class RsyncParameters {
    
    // NSDictionaru holding whic rsync arguments requiere and value
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
    
    // --backup-dir=../backup
    // --suffix=_$(date +%Y-%m-%d.%H.%M)

    func getArguments() -> [String] {
        return self.rsyncArguments
    }
    
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
    
    init() {
        self.fillargumentsDictionary()
    }
}
