//
//  ViewControllertabSchedule.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

protocol SetProfileinfo: AnyObject {
    func setprofile(profile: String, color: NSColor)
}

class ViewControllerSchedule: NSViewController, SetConfigurations, SetSchedules, VcMain, Checkforrsync, Setcolor, Help {
    var index: Int?
    // var schedulessorted: ScheduleSortedAndExpand?
    var schedule: Scheduletype?
    // Scheduleetails
    var scheduledetails: [NSMutableDictionary]?
    // Send messages to the sidebar
    weak var sidebaractionsDelegate: Sidebaractions?
    var addschduleisallowed = false

    // Main tableview
    @IBOutlet var scheduletable: NSTableView!
    @IBOutlet var profilInfo: NSTextField!
    @IBOutlet var info: NSTextField!
    @IBOutlet var scheduletabledetails: NSTableView!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    @IBAction func quickbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_: NSButton) {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    // All ouput
    @IBAction func alloutput(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAllOutput!)
    }

    // Sidebar Once
    func once() {
        guard self.addschduleisallowed else { return }
        self.schedule = .once
        self.addschedule()
    }

    // Sidebar Daily
    func daily() {
        guard self.addschduleisallowed else { return }
        self.schedule = .daily
        self.addschedule()
    }

    // Sidebar Weekly
    func weekly() {
        guard self.addschduleisallowed else { return }
        self.schedule = .weekly
        self.addschedule()
    }

    // Sidebar update
    func update() {
        self.schedules?.deleteandstopschedules(data: scheduledetails)
    }

    @IBAction func selectdate(_: NSDatePicker) {
        self.schedulebuttonsonoff()
    }

    @IBAction func selecttime(_: NSDatePicker) {
        self.schedulebuttonsonoff()
    }

    private func addschedule() {
        guard self.index != nil else { return }
        let question: String = NSLocalizedString("Add Schedule?", comment: "Add schedule")
        let text: String = NSLocalizedString("Cancel or Add", comment: "Add schedule")
        let dialog: String = NSLocalizedString("Add", comment: "Add schedule")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
        if answer {
            self.info.stringValue = Infoschedule().info(num: 2)
            let seconds: TimeInterval = self.starttime.dateValue.timeIntervalSinceNow
            let startdate: Date = self.startdate.dateValue.addingTimeInterval(seconds)
            if let index = self.index {
                if let hiddenID = self.configurations?.gethiddenID(index: index) {
                    guard hiddenID != -1 else { return }
                    self.schedules?.addschedule(hiddenID: hiddenID, schedule: self.schedule ?? .once, start: startdate)
                }
            }
        }
    }

    private func schedulebuttonsonoff() {
        let seconds: TimeInterval = self.starttime.dateValue.timeIntervalSinceNow
        // Date and time for stop
        let startime: Date = self.startdate.dateValue.addingTimeInterval(seconds)
        let secondstostart = startime.timeIntervalSinceNow
        if secondstostart < 60 {
            self.selectedstart.isHidden = true
            self.addschduleisallowed = false
            // self.weeklybutton.isEnabled = false
            // self.dailybutton.isEnabled = false
            // self.oncebutton.isEnabled = false
        }
        if secondstostart > 60 {
            self.addschduleisallowed = true
            self.selectedstart.isHidden = false
            self.selectedstart.stringValue = startime.localized_string_from_date() + " (" + Dateandtime().timestring(seconds: secondstostart) + ")"
            self.selectedstart.textColor = self.setcolor(nsviewcontroller: self, color: .green)
            // self.weeklybutton.isEnabled = true
            // self.dailybutton.isEnabled = true
            // self.oncebutton.isEnabled = true
        }
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        }
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    @IBOutlet var startdate: NSDatePicker!
    @IBOutlet var starttime: NSDatePicker!
    @IBOutlet var selectedstart: NSTextField!

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scheduletable.delegate = self
        self.scheduletable.dataSource = self
        self.scheduletabledetails.delegate = self
        self.scheduletabledetails.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabschedule, nsviewcontroller: self)
        self.initpopupbutton()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.sidebaractionsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        self.sidebaractionsDelegate?.sidebaractions(action: .scheduleviewbuttons)
        self.info.stringValue = Infoschedule().info(num: 0)
        self.selectedstart.isHidden = true
        self.startdate.dateValue = Date()
        self.starttime.dateValue = Date()
        self.reloadtabledata()
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == self.scheduletable {
            self.info.stringValue = Infoschedule().info(num: 0)
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                self.index = index
                let hiddendID = self.configurations?.gethiddenID(index: self.index ?? -1)
                self.scheduledetails = self.schedules?.readscheduleonetask(hiddenID: hiddendID)
            } else {
                self.index = nil
                self.scheduledetails = nil
            }
            globalMainQueue.async { () -> Void in
                self.scheduletabledetails.reloadData()
                self.scheduletable.reloadData()
            }
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

extension ViewControllerSchedule: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        self.reloadtabledata()
    }
}

extension ViewControllerSchedule: Reloadandrefresh {
    func reloadtabledata() {
        if let index = self.index {
            if let hiddendID = self.configurations?.gethiddenID(index: index) {
                self.scheduledetails = self.schedules?.readscheduleonetask(hiddenID: hiddendID)
            }
        }
        globalMainQueue.async { () -> Void in
            self.scheduletable.reloadData()
            self.scheduletabledetails.reloadData()
        }
    }
}

// Deselect a row
extension ViewControllerSchedule: DeselectRowTable {
    // deselect a row after row is deleted
    func deselect() {
        guard self.index != nil else { return }
        self.scheduletable.deselectRow(self.index!)
    }
}

extension ViewControllerSchedule: SetProfileinfo {
    func setprofile(profile: String, color: NSColor) {
        globalMainQueue.async { () -> Void in
            self.profilInfo.stringValue = profile
            self.profilInfo.textColor = color
        }
    }
}

extension ViewControllerSchedule: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerSchedule: Sidebarbuttonactions {
    func sidebarbuttonactions(action: Sidebaractionsmessages) {
        switch action {
        case .Once:
            self.once()
        case .Daily:
            self.daily()
        case .Weekly:
            self.weekly()
        case .Update:
            self.update()
        default:
            return
        }
    }
}
