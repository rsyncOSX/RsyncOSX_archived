//
//  ViewControllerRsyncParameters.swift
//  Rsync
//  The ViewController for rsync parameters.
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length function_body_length type_body_length cyclomatic_complexity

import Cocoa
import Foundation

// protocol for returning if userparams is updated or not
protocol RsyncUserParams: AnyObject {
    func rsyncuserparamsupdated()
}

// Protocol for sending selected index in tableView
// The protocol is implemented in ViewControllertabMain
protocol GetSelecetedIndex: AnyObject {
    func getindex() -> Int?
}

class ViewControllerRsyncParameters: NSViewController, SetConfigurations, Index {
    var comboBoxValues = [String]()
    var diddissappear: Bool = false

    @IBOutlet var param1: NSTextField!
    @IBOutlet var param2: NSTextField!
    @IBOutlet var param3: NSTextField!
    @IBOutlet var param4: NSTextField!
    @IBOutlet var param5: NSTextField!

    @IBOutlet var param8: NSTextField!
    @IBOutlet var param9: NSTextField!
    @IBOutlet var param10: NSTextField!
    @IBOutlet var param11: NSTextField!
    @IBOutlet var param12: NSTextField!
    @IBOutlet var param13: NSTextField!
    @IBOutlet var param14: NSTextField!
    @IBOutlet var rsyncdaemon: NSButton!
    @IBOutlet var sshport: NSTextField!
    @IBOutlet var compressparameter: NSButton!
    @IBOutlet var esshparameter: NSButton!
    @IBOutlet var deleteparamater: NSButton!
    @IBOutlet var sshkeypathandidentityfile: NSTextField!

    @IBOutlet var combo8: NSComboBox!
    @IBOutlet var combo9: NSComboBox!
    @IBOutlet var combo10: NSComboBox!
    @IBOutlet var combo11: NSComboBox!
    @IBOutlet var combo12: NSComboBox!
    @IBOutlet var combo13: NSComboBox!
    @IBOutlet var combo14: NSComboBox!

    @IBAction func close(_: NSButton) {
        view.window?.close()
    }

    @IBAction func closeview(_: NSButton) {
        view.window?.close()
    }

    @IBAction func togglersyncdaemon(_: NSButton) {
        if let index = index() {
            switch rsyncdaemon.state {
            case .on:
                configurations?.removeesshparameter(index: index, delete: true)
                param5.stringValue = configurations?.getConfigurations()?[index].parameter5 ?? ""
                esshparameter.state = .on
            case .off:
                configurations?.removeesshparameter(index: index, delete: false)
                param5.stringValue = (configurations?.getConfigurations()?[index].parameter5 ?? "") + " ssh"
                esshparameter.state = .off
            default:
                return
            }
        }
    }

    @IBAction func removecompressparameter(_: NSButton) {
        if let index = index() {
            switch compressparameter.state {
            case .on:
                configurations?.removecompressparameter(index: index, delete: true)
            case .off:
                configurations?.removecompressparameter(index: index, delete: false)
            default:
                break
            }
            param3.stringValue = configurations?.getConfigurations()?[index].parameter3 ?? ""
        }
    }

    @IBAction func removeesshparameter(_: NSButton) {
        if let index = index() {
            switch esshparameter.state {
            case .on:
                configurations?.removeesshparameter(index: index, delete: true)
                param5.stringValue = configurations?.getConfigurations()?[index].parameter5 ?? ""
            case .off:
                configurations?.removeesshparameter(index: index, delete: false)
                param5.stringValue = (configurations?.getConfigurations()?[index].parameter5 ?? "") + " ssh"
            default:
                break
            }
        }
    }

    @IBAction func removedeleteparameter(_: NSButton) {
        if let index = index() {
            switch deleteparamater.state {
            case .on:
                configurations?.removeedeleteparameter(index: index, delete: true)
            case .off:
                configurations?.removeedeleteparameter(index: index, delete: false)
            default:
                break
            }
            param4.stringValue = configurations?.getConfigurations()?[index].parameter4 ?? ""
        }
    }

    // Function for enabling backup of changed files in a backup catalog.
    // Parameters are appended to last two parameters (12 and 13).
    @IBAction func backup(_: NSButton) {
        if let index = index() {
            if let configurations: [Configuration] = configurations?.getConfigurations() {
                let param = ComboboxRsyncParameters(config: configurations[index])
                switch backupbutton.state {
                case .on:
                    initcombox(combobox: combo12, index: param.indexandvaluersyncparameter(SuffixstringsRsyncParameters().backupstrings[0]).0)
                    param12.stringValue = param.indexandvaluersyncparameter(SuffixstringsRsyncParameters().backupstrings[0]).1
                    let hiddenID = self.configurations?.gethiddenID(index: (self.index())!)
                    guard (hiddenID ?? -1) > -1 else { return }
                    let localcatalog = self.configurations?.getResourceConfiguration(hiddenID ?? -1, resource: .localCatalog)
                    let localcatalogParts = (localcatalog as AnyObject).components(separatedBy: "/")
                    initcombox(combobox: combo13, index: param.indexandvaluersyncparameter(SuffixstringsRsyncParameters().backupstrings[1]).0)
                    param13.stringValue = "../backup" + "_" + localcatalogParts[localcatalogParts.count - 2]
                case .off:
                    initcombox(combobox: combo12, index: 0)
                    param12.stringValue = ""
                    initcombox(combobox: combo13, index: 0)
                    param13.stringValue = ""
                    initcombox(combobox: combo14, index: 0)
                    param14.stringValue = ""
                default: break
                }
            }
        }
    }

    // Function for enabling suffix date + time changed files.
    // Parameters are appended to last parameter (14).
    @IBOutlet var suffixButton: NSButton!
    @IBAction func suffix(_: NSButton) {
        if let index = index() {
            suffixButton2.state = .off
            if let configurations: [Configuration] = configurations?.getConfigurations() {
                let param = ComboboxRsyncParameters(config: configurations[index])
                switch suffixButton.state {
                case .on:
                    let suffix = SuffixstringsRsyncParameters().suffixstringfreebsd
                    initcombox(combobox: combo14, index: param.indexandvaluersyncparameter(suffix).0)
                    param14.stringValue = param.indexandvaluersyncparameter(suffix).1
                case .off:
                    initcombox(combobox: combo14, index: 0)
                    param14.stringValue = ""
                default:
                    break
                }
            }
        }
    }

    @IBOutlet var suffixButton2: NSButton!
    @IBAction func suffix2(_: NSButton) {
        if let index = index() {
            if let configurations: [Configuration] = configurations?.getConfigurations() {
                let param = ComboboxRsyncParameters(config: configurations[index])
                suffixButton.state = .off
                switch suffixButton2.state {
                case .on:
                    let suffix = SuffixstringsRsyncParameters().suffixstringlinux
                    initcombox(combobox: combo14, index: param.indexandvaluersyncparameter(suffix).0)
                    param14.stringValue = param.indexandvaluersyncparameter(suffix).1
                case .off:
                    initcombox(combobox: combo14, index: 0)
                    param14.stringValue = ""
                default:
                    break
                }
            }
        }
    }

    @IBOutlet var backupbutton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Check if there is another view open, if yes close it..
        if let view = SharedReference.shared.getvcref(viewcontroller: .vcrsyncparameters) as? ViewControllerRsyncParameters {
            weak var closeview: ViewControllerRsyncParameters?
            closeview = view
            closeview?.closeview()
        }
        SharedReference.shared.setvcref(viewcontroller: .vcrsyncparameters, nsviewcontroller: self)
        guard diddissappear == false else { return }
        if let index = index() {
            if let configurations: [Configuration] = configurations?.getConfigurations() {
                let param = ComboboxRsyncParameters(config: configurations[index])
                comboBoxValues = param.getComboBoxValues()
                backupbutton.state = .off
                suffixButton.state = .off
                suffixButton2.state = .off
                param1.stringValue = configurations[index].parameter1
                param2.stringValue = configurations[index].parameter2
                param3.stringValue = configurations[index].parameter3
                param4.stringValue = configurations[index].parameter4
                if configurations[index].parameter5.isEmpty == false {
                    param5.stringValue = configurations[index].parameter5 + " " + configurations[index].parameter6
                }
                if configurations[index].parameter3.isEmpty == true {
                    compressparameter.state = .on
                } else {
                    compressparameter.state = .off
                }
                if configurations[index].parameter4.isEmpty == true {
                    deleteparamater.state = .on
                } else {
                    deleteparamater.state = .off
                }
                if configurations[index].parameter5.isEmpty == true {
                    esshparameter.state = .on
                } else {
                    esshparameter.state = .off
                }
                let value8 = param.getParameter(rsyncparameternumber: 8).0
                initcombox(combobox: combo8, index: value8)
                param8.stringValue = param.getParameter(rsyncparameternumber: 8).1
                let value9 = param.getParameter(rsyncparameternumber: 9).0
                initcombox(combobox: combo9, index: value9)
                param9.stringValue = param.getParameter(rsyncparameternumber: 9).1
                let value10 = param.getParameter(rsyncparameternumber: 10).0
                initcombox(combobox: combo10, index: value10)
                param10.stringValue = param.getParameter(rsyncparameternumber: 10).1
                let value11 = param.getParameter(rsyncparameternumber: 11).0
                initcombox(combobox: combo11, index: value11)
                param11.stringValue = param.getParameter(rsyncparameternumber: 11).1
                let value12 = param.getParameter(rsyncparameternumber: 12).0
                initcombox(combobox: combo12, index: value12)
                param12.stringValue = param.getParameter(rsyncparameternumber: 12).1
                let value13 = param.getParameter(rsyncparameternumber: 13).0
                initcombox(combobox: combo13, index: value13)
                param13.stringValue = param.getParameter(rsyncparameternumber: 13).1
                let value14 = param.getParameter(rsyncparameternumber: 14).0
                initcombox(combobox: combo14, index: value14)
                param14.stringValue = param.getParameter(rsyncparameternumber: 14).1
                if configurations[index].rsyncdaemon != nil {
                    rsyncdaemon.state = NSControl.StateValue(rawValue: configurations[index].rsyncdaemon!)
                } else {
                    rsyncdaemon.state = .off
                }
                if configurations[index].sshport != nil {
                    sshport.stringValue = String(configurations[index].sshport!)
                }
                if (configurations[index].sshkeypathandidentityfile ?? "").isEmpty == false {
                    sshkeypathandidentityfile.stringValue = configurations[index].sshkeypathandidentityfile!
                }
            }
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        diddissappear = true
        SharedReference.shared.setvcref(viewcontroller: .vcrsyncparameters, nsviewcontroller: nil)
    }

    // Function for saving changed or new parameters for one configuration.
    @IBAction func update(_: NSButton) {
        if var configurations: [Configuration] = configurations?.getConfigurations() {
            guard configurations.count > 0 else { return }
            // Get the index of selected configuration
            if let index = index() {
                let param = SetrsyncParameter()
                configurations[index].parameter8 = param.setrsyncparameter(indexComboBox:
                    combo8.indexOfSelectedItem, value: getValue(value: param8.stringValue))
                configurations[index].parameter9 = param.setrsyncparameter(indexComboBox:
                    combo9.indexOfSelectedItem, value: getValue(value: param9.stringValue))
                configurations[index].parameter10 = param.setrsyncparameter(indexComboBox:
                    combo10.indexOfSelectedItem, value: getValue(value: param10.stringValue))
                configurations[index].parameter11 = param.setrsyncparameter(indexComboBox:
                    combo11.indexOfSelectedItem, value: getValue(value: param11.stringValue))
                configurations[index].parameter12 = param.setrsyncparameter(indexComboBox:
                    combo12.indexOfSelectedItem, value: getValue(value: param12.stringValue))
                configurations[index].parameter13 = param.setrsyncparameter(indexComboBox:
                    combo13.indexOfSelectedItem, value: getValue(value: param13.stringValue))
                configurations[index].parameter14 = param.setrsyncparameter(indexComboBox:
                    combo14.indexOfSelectedItem, value: getValue(value: param14.stringValue))
                configurations[index].rsyncdaemon = rsyncdaemon.state.rawValue
                if let port = sshport {
                    configurations[index].sshport = Int(port.stringValue)
                }
                if let sshkeypathandidentityfile = sshkeypathandidentityfile {
                    if sshkeypathandidentityfile.stringValue.isEmpty == false {
                        configurations[index].sshkeypathandidentityfile = sshkeypathandidentityfile.stringValue
                    } else {
                        configurations[index].sshkeypathandidentityfile = nil
                    }
                }
                // Update configuration in memory before saving
                self.configurations?.updateConfigurations(configurations[index], index: index)
            }
        }
        view.window?.close()
    }

    // There are eight comboboxes, all eight are initalized during ViewDidLoad and the correct index is set.
    private func initcombox(combobox: NSComboBox, index: Int) {
        guard index > -1 else { return }
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: comboBoxValues)
        combobox.selectItem(at: index)
    }

    // Returns nil or value from stringvalue (rsync parameters)
    private func getValue(value: String) -> String? {
        guard value.isEmpty == false else { return nil }
        return value
    }
}

extension ViewControllerRsyncParameters: CloseEdit {
    func closeview() {
        view.window?.close()
    }
}
