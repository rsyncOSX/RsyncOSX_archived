//
//  ViewControllerAllProfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 07.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

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
    var configurations: [Configuration]?
    var allschedules: Allschedules?
    var allschedulessortedandexpanded: ScheduleSortedAndExpand?
    var column: Int?
    var filterby: Sortandfilter?
    var sortascending: Bool = true
    var index: Int?
    var outputprocess: OutputProcess?

    var command: OtherProcessCmdClosure?

    @IBAction func abort(_: NSButton) {
        _ = InterruptProcess()
    }

    @IBAction func closeview(_: NSButton) {
        self.view.window?.close()
    }

    @IBAction func sortdirection(_: NSButton) {
        if self.sortascending == true {
            self.sortascending = false
            self.sortdirection.image = #imageLiteral(resourceName: "down")
        } else {
            self.sortascending = true
            self.sortdirection.image = #imageLiteral(resourceName: "up")
        }
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.search.delegate = self
        self.mainTableView.target = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.reloadallprofiles()
        self.initpopupbutton()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcallprofiles, nsviewcontroller: self)
        self.allconfigurations = AllConfigurations()
        self.configurations = self.allconfigurations?.allconfigurations
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcallprofiles, nsviewcontroller: nil)
    }

    func reloadallprofiles() {
        self.configurations = allconfigurations?.allconfigurations
        self.allschedules = Allschedules(includelog: false)
        self.allschedulessortedandexpanded = ScheduleSortedAndExpand(allschedules: self.allschedules)
        self.sortdirection.image = #imageLiteral(resourceName: "up")
        self.sortascending = true
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }

    func initpopupbutton() {
        var profilestrings: [String]?
        profilestrings = CatalogProfile().getcatalogsasstringnames()
        profilestrings?.insert(NSLocalizedString("Default profile", comment: "default profile"), at: 0)
        self.profilepopupbutton.removeAllItems()
        self.profilepopupbutton.addItems(withTitles: profilestrings ?? [])
        self.profilepopupbutton.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        var profile = self.profilepopupbutton.titleOfSelectedItem
        let selectedindex = self.profilepopupbutton.indexOfSelectedItem
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            profile = nil
        }
        self.profilepopupbutton.selectItem(at: selectedindex)
        _ = Selectprofile(profile: profile, selectedindex: selectedindex)
    }
}

extension ViewControllerAllProfiles: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        self.numberOfprofiles.stringValue = NSLocalizedString("Number of configurations:", comment: "AllProfiles") + " " +
            String(self.configurations?.count ?? 0)
        return self.configurations?.count ?? 0
    }
}

extension ViewControllerAllProfiles: NSTableViewDelegate, Attributedestring {
    // TableView delegates
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let tableColumn = tableColumn {
            if row > (self.configurations?.count ?? 0) - 1 { return nil }
            if let object = self.configurations?[row] {
                let hiddenID = object.hiddenID
                let profile = object.profile ?? NSLocalizedString("Default profile", comment: "default profile")
                switch tableColumn.identifier.rawValue {
                case "intime":
                    let taskintime: String? = self.allschedulessortedandexpanded?.sortandcountscheduledonetask(hiddenID, profilename: profile, number: true)
                    return taskintime ?? ""
                case "schedule":
                    let schedule = self.allschedulessortedandexpanded?.sortandcountscheduledonetask(hiddenID, profilename: profile, number: false)
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
        var comp: (String, String) -> Bool
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let column = myTableViewFromNotification.selectedColumn
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
        } else {
            self.index = nil
        }
        if self.sortascending == true {
            comp = (<)
        } else {
            comp = (>)
        }
        self.column = column
        switch column {
        case 0:
            self.configurations = allconfigurations?.allconfigurations?.sorted(by: \.profile!, using: comp)
        case 3:
            self.configurations = allconfigurations?.allconfigurations?.sorted(by: \.task, using: comp)
        case 4:
            self.configurations = allconfigurations?.allconfigurations?.sorted(by: \.localCatalog, using: comp)
        case 5:
            self.configurations = allconfigurations?.allconfigurations?.sorted(by: \.offsiteCatalog, using: comp)
        case 6:
            self.configurations = allconfigurations?.allconfigurations?.sorted(by: \.offsiteServer, using: comp)
        case 7, 8:
            self.configurations = allconfigurations?.allconfigurations?.sorted(by: \.dateRun!, using: comp)
        default:
            return
        }
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }
}

extension ViewControllerAllProfiles: NSSearchFieldDelegate {
    func controlTextDidChange(_: Notification) {
        self.delayWithSeconds(0.25) {
            guard self.column != nil else { return }
            let filterstring = self.search.stringValue
            if filterstring.isEmpty {
                globalMainQueue.async { () -> Void in
                    self.configurations = AllConfigurations().allconfigurations
                    self.mainTableView.reloadData()
                }
            } else {
                /*
                 globalMainQueue.async { () -> Void in
                     self.allprofiles?.filter(search: filterstring, filterby: self.filterby)
                     self.mainTableView.reloadData()
                 }
                 */
            }
        }
    }

    func searchFieldDidEndSearching(_: NSSearchField) {
        globalMainQueue.async { () -> Void in
            self.configurations = AllConfigurations().allconfigurations
            self.mainTableView.reloadData()
        }
    }
}

extension ViewControllerAllProfiles: ReloadTableAllProfiles {
    func reloadtable() {
        self.reloadallprofiles()
    }
}
