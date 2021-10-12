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

class ViewControllerSchedule: NSViewController, SetConfigurations, VcMain, Checkforrsync, Setcolor, Help {
    // TODO: fix new name
    var schedules: Schedules?
    var sortedandexpanded: ScheduleSortedAndExpand?
    // TODO: fix new name
    var index: Int?
    // var schedulessorted: ScheduleSortedAndExpand?
    var schedule: Scheduletype?
    // Scheduleetails
    var scheduledetails: [NSMutableDictionary]?
    // Send messages to the sidebar
    weak var sidebaractionsDelegate: Sidebaractions?
    var addschduleisallowed = false
    var configurations: Estimatedlistforsynchronization?

    // Main tableview
    @IBOutlet var scheduletable: NSTableView!
    @IBOutlet var info: NSTextField!
    @IBOutlet var scheduletabledetails: NSTableView!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

    @IBAction func showHelp(_: AnyObject?) {
        help()
    }

    // Sidebar Once
    func once() {
        guard addschduleisallowed else { return }
        schedule = .once
        addschedule()
    }

    // Sidebar Daily
    func daily() {
        guard addschduleisallowed else { return }
        schedule = .daily
        addschedule()
    }

    // Sidebar Weekly
    func weekly() {
        guard addschduleisallowed else { return }
        schedule = .weekly
        addschedule()
    }

    // Sidebar update
    func update() {
        schedules?.deleteandstopschedules(data: scheduledetails)
    }

    @IBAction func selectdate(_: NSDatePicker) {
        schedulebuttonsonoff()
    }

    @IBAction func selecttime(_: NSDatePicker) {
        schedulebuttonsonoff()
    }

    private func addschedule() {
        guard index != nil else { return }
        let question: String = NSLocalizedString("Add Schedule?", comment: "Add schedule")
        let text: String = NSLocalizedString("Cancel or Add", comment: "Add schedule")
        let dialog: String = NSLocalizedString("Add", comment: "Add schedule")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
        if answer {
            info.stringValue = Infoschedule().info(num: 2)
            let seconds: TimeInterval = starttime.dateValue.timeIntervalSinceNow
            let startdate: Date = self.startdate.dateValue.addingTimeInterval(seconds)
            if let index = index {
                if let hiddenID = configurations?.gethiddenID(index: index),
                   let schedule = schedule
                {
                    guard hiddenID != -1 else { return }
                    schedules?.addschedule(hiddenID, schedule, startdate)
                }
            }
        }
    }

    private func schedulebuttonsonoff() {
        let seconds: TimeInterval = starttime.dateValue.timeIntervalSinceNow
        // Date and time for stop
        let startime: Date = startdate.dateValue.addingTimeInterval(seconds)
        let secondstostart = startime.timeIntervalSinceNow
        if secondstostart < 60 {
            selectedstart.isHidden = true
            addschduleisallowed = false
        }
        if secondstostart > 60 {
            addschduleisallowed = true
            selectedstart.isHidden = false
            selectedstart.stringValue = startime.localized_string_from_date() + " (" + Dateandtime().timestring(seconds: secondstostart) + ")"
            selectedstart.textColor = setcolor(nsviewcontroller: self, color: .green)
        }
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        }
    }

    @IBOutlet var startdate: NSDatePicker!
    @IBOutlet var starttime: NSDatePicker!
    @IBOutlet var selectedstart: NSTextField!

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        configurations = Estimatedlistforsynchronization()
        scheduletable.delegate = self
        scheduletable.dataSource = self
        scheduletabledetails.delegate = self
        scheduletabledetails.dataSource = self
        SharedReference.shared.setvcref(viewcontroller: .vctabschedule, nsviewcontroller: self)
        initpopupbutton()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        sidebaractionsDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
        sidebaractionsDelegate?.sidebaractions(action: .scheduleviewbuttons)
        info.stringValue = Infoschedule().info(num: 0)
        selectedstart.isHidden = true
        startdate.dateValue = Date()
        starttime.dateValue = Date()
        reloadtabledata()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        schedules = nil
        sortedandexpanded = nil
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == scheduletable {
            info.stringValue = Infoschedule().info(num: 0)
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                self.index = index
                let hiddendID = configurations?.gethiddenID(index: self.index ?? -1)
                scheduledetails = schedules?.readscheduleonetask(hiddenID: hiddendID)
            } else {
                index = nil
                scheduledetails = nil
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
        // TODO:
        _ = Selectprofile(profile: profile, selectedindex: selectedindex)
        reloadtabledata()
    }
}

extension ViewControllerSchedule: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        dismiss(viewcontroller)
        reloadtabledata()
    }
}

extension ViewControllerSchedule: Reloadandrefresh {
    func reloadtabledata() {
        schedules = nil
        sortedandexpanded = nil

        schedules = Schedules()
        sortedandexpanded = ScheduleSortedAndExpand()

        if let index = index {
            if let hiddendID = configurations?.gethiddenID(index: index) {
                scheduledetails = schedules?.readscheduleonetask(hiddenID: hiddendID)
            }
        }
        globalMainQueue.async { () -> Void in
            self.scheduletable.reloadData()
            self.scheduletabledetails.reloadData()
        }
    }
}

extension ViewControllerSchedule: NewProfile {
    func newprofile(selectedindex _: Int?) {}

    func reloadprofilepopupbutton() {}
}

// Deselect a row
extension ViewControllerSchedule: DeselectRowTable {
    // deselect a row after row is deleted
    func deselect() {
        guard index != nil else { return }
        scheduletable.deselectRow(index!)
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
            once()
        case .Daily:
            daily()
        case .Weekly:
            weekly()
        case .Update:
            update()
        default:
            return
        }
    }
}
