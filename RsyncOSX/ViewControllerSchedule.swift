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

class ViewControllerSchedule: NSViewController, SetConfigurations, Checkforrsync, Setcolor, Help {
    var schedulesobject: Schedules?
    var sortedandexpanded: ScheduleSortedAndExpand?

    var index: Int?
    // var schedulessorted: ScheduleSortedAndExpand?
    var schedule: Scheduletype?
    // Scheduleetails
    var scheduledetails: [NSMutableDictionary]?
    var addschduleisallowed = false
    var configurations: Estimatedlistforsynchronization?

    // Main tableview
    @IBOutlet var scheduletable: NSTableView!
    @IBOutlet var info: NSTextField!
    @IBOutlet var scheduletabledetails: NSTableView!

    // Sidebar Once
    @IBAction func once(_: NSButton) {
        guard addschduleisallowed else { return }
        schedule = .once
        addschedule()
    }

    // Sidebar Daily
    @IBAction func daily(_: NSButton) {
        guard addschduleisallowed else { return }
        schedule = .daily
        addschedule()
    }

    // Sidebar Weekly
    @IBAction func weekly(_: NSButton) {
        guard addschduleisallowed else { return }
        schedule = .weekly
        addschedule()
    }

    // Sidebar update
    @IBAction func update(_: NSButton) {
        schedulesobject?.deleteandstopschedules(data: scheduledetails)
        reloadtabledata()
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
                    schedulesobject?.addschedule(hiddenID, schedule, startdate)
                    reloadtabledata()
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
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        info.stringValue = Infoschedule().info(num: 0)
        selectedstart.isHidden = true
        startdate.dateValue = Date()
        starttime.dateValue = Date()
        reloadtabledata()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        schedulesobject = nil
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
                scheduledetails = schedulesobject?.readscheduleonetask(hiddenID: hiddendID)
            } else {
                index = nil
                scheduledetails = nil
            }
            globalMainQueue.async { () in
                self.scheduletabledetails.reloadData()
                self.scheduletable.reloadData()
            }
        }
    }

    func reloadtabledata() {
        schedulesobject = nil
        sortedandexpanded = nil

        schedulesobject = Schedules()
        sortedandexpanded = ScheduleSortedAndExpand()

        if let index = index {
            if let hiddendID = configurations?.gethiddenID(index: index) {
                scheduledetails = schedulesobject?.readscheduleonetask(hiddenID: hiddendID)
            }
        }
        globalMainQueue.async { () in
            self.scheduletable.reloadData()
            self.scheduletabledetails.reloadData()
        }
    }
}

extension ViewControllerSchedule: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        dismiss(viewcontroller)
        reloadtabledata()
    }
}

// Deselect a row
extension ViewControllerSchedule: DeselectRowTable {
    // deselect a row after row is deleted
    func deselect() {
        guard index != nil else { return }
        scheduletable.deselectRow(index!)
    }
}
