//
//  ViewControllerAllProfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 07.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity

import Cocoa
import Foundation

protocol ReloadTableAllProfiles: AnyObject {
    func reloadtable()
}

class ViewControllerAllProfiles: NSViewController, Delay, Abort, Connected {
    // Main tableview
    @IBOutlet var mainTableView: NSTableView!
    @IBOutlet var search: NSSearchField!
    @IBOutlet var sortdirection: NSButton!
    @IBOutlet var numberOfprofiles: NSTextField!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

    var allconfigurations: AllConfigurations?
    var allschedules: Allschedules?
    var allschedulessortedandexpanded: ScheduleSortedAndExpand?
    var column: Int?
    var filterby: Sortandfilter?
    var sortascending: Bool = true
    var index: Int?
    var outputprocess: OutputfromProcess?

    var command: OtherProcess?

    @IBAction func closeview(_: NSButton) {
        view.window?.close()
    }

    @IBAction func sortdirection(_: NSButton) {
        if sortascending == true {
            sortascending = false
            sortdirection.image = #imageLiteral(resourceName: "down")
        } else {
            sortascending = true
            sortdirection.image = #imageLiteral(resourceName: "up")
        }
        sortbycolumn()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        search.delegate = self
        mainTableView.target = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        sortdirection.image = #imageLiteral(resourceName: "up")
        sortascending = true
        initpopupbutton()
        SharedReference.shared.setvcref(viewcontroller: .vcallprofiles, nsviewcontroller: self)
        allconfigurations = AllConfigurations()
        allschedules = Allschedules()
        allschedulessortedandexpanded = ScheduleSortedAndExpand(allschedules: allschedules)
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        SharedReference.shared.setvcref(viewcontroller: .vcallprofiles, nsviewcontroller: nil)
        allschedules = nil
        allconfigurations = nil
    }

    func initpopupbutton() {
        var profilestrings: [String]?
        profilestrings = CatalogProfile().getcatalogsasstringnames()
        profilestrings?.insert(NSLocalizedString("Default profile", comment: "default profile"), at: 0)
        profilepopupbutton.removeAllItems()
        profilepopupbutton.addItems(withTitles: profilestrings ?? [])
        profilepopupbutton.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        var profile = profilepopupbutton.titleOfSelectedItem
        let selectedindex = profilepopupbutton.indexOfSelectedItem
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            profile = nil
        }
        profilepopupbutton.selectItem(at: selectedindex)
        _ = Selectprofile(profile: profile, selectedindex: selectedindex)
        view.window?.close()
    }

    func sortbycolumn() {
        var comp: (String, String) -> Bool
        if sortascending == true {
            comp = (<)
        } else {
            comp = (>)
        }
        switch column {
        case 0:
            allconfigurations?.allconfigurations = allconfigurations?.allconfigurations?.sorted(by: \.profile!, using: comp)
        case 3:
            allconfigurations?.allconfigurations = allconfigurations?.allconfigurations?.sorted(by: \.task, using: comp)
        case 4:
            allconfigurations?.allconfigurations = allconfigurations?.allconfigurations?.sorted(by: \.localCatalog, using: comp)
        case 5:
            allconfigurations?.allconfigurations = allconfigurations?.allconfigurations?.sorted(by: \.offsiteCatalog, using: comp)
        case 6:
            allconfigurations?.allconfigurations = allconfigurations?.allconfigurations?.sorted(by: \.offsiteServer, using: comp)
        default:
            return
        }
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }
}

extension ViewControllerAllProfiles: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        numberOfprofiles.stringValue = NSLocalizedString("Number of configurations:", comment: "AllProfiles") + " " +
            String(allconfigurations?.allconfigurations?.count ?? 0)
        return allconfigurations?.allconfigurations?.count ?? 0
    }
}

extension ViewControllerAllProfiles: NSTableViewDelegate, Attributedestring {
    // TableView delegates
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let tableColumn = tableColumn {
            if row > (allconfigurations?.allconfigurations?.count ?? 0) - 1 { return nil }
            if let object = allconfigurations?.allconfigurations?[row] {
                let hiddenID = object.hiddenID
                let profile = object.profile ?? NSLocalizedString("Default profile", comment: "default profile")
                switch tableColumn.identifier.rawValue {
                case "intime":
                    let taskintime: String? = allschedulessortedandexpanded?.sortandcountscheduledonetask(hiddenID, profilename: profile, number: true)
                    return taskintime ?? ""
                case "schedule":
                    let schedule = allschedulessortedandexpanded?.sortandcountscheduledonetask(hiddenID, profilename: profile, number: false)
                    switch schedule {
                    case Scheduletype.once.rawValue:
                        return NSLocalizedString("once", comment: "main")
                    case Scheduletype.daily.rawValue:
                        return NSLocalizedString("daily", comment: "main")
                    case Scheduletype.weekly.rawValue:
                        return NSLocalizedString("weekly", comment: "main")
                    case Scheduletype.manuel.rawValue:
                        return NSLocalizedString("manuel", comment: "main")
                    default:
                        return ""
                    }
                case "profile":
                    return object.profile ?? ""
                case "localCatalog":
                    return object.localCatalog
                case "offsiteCatalog":
                    return object.offsiteCatalog
                case "offsiteServer":
                    return object.offsiteServer
                case "daysID":
                    return object.dayssincelastbackup
                case "task":
                    return object.task
                case "dateExecuted":
                    return object.dateRun ?? ""
                default:
                    return nil
                }
            }
        }
        return nil
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let column = myTableViewFromNotification.selectedColumn
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
        } else {
            index = nil
        }
        self.column = column
        sortbycolumn()
    }
}

extension ViewControllerAllProfiles: NSSearchFieldDelegate {
    func controlTextDidChange(_: Notification) {
        delayWithSeconds(0.25) {
            if self.search.stringValue.isEmpty {
                globalMainQueue.async { () -> Void in
                    self.allconfigurations?.allconfigurations = AllConfigurations().allconfigurations
                    self.mainTableView.reloadData()
                }
            } else {
                globalMainQueue.async { () -> Void in
                    self.allconfigurations?.filter(search: self.search.stringValue)
                    self.mainTableView.reloadData()
                }
            }
        }
    }

    func searchFieldDidEndSearching(_: NSSearchField) {
        globalMainQueue.async { () -> Void in
            self.allconfigurations?.allconfigurations = AllConfigurations().allconfigurations
            self.mainTableView.reloadData()
        }
    }
}
