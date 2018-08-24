//
//  Dateandtime.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class Dateandtime {

    // Calculate seconds from now to startdate
    private func seconds (_ startdate: Date, enddate: Date?) -> Double {
        if enddate == nil {
            return startdate.timeIntervalSinceNow
        } else {
            return enddate!.timeIntervalSince(startdate)
        }
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    // Returns time in minutes
    func timeDoubleMinutes (_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (_, minf) = modf (seconds / 3600)
        let (min, _) = modf (60 * minf)
        return min
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    // Returns time in seconds
    func timeDoubleSeconds (_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        return seconds
    }

    // Returns number of hours between start and stop date
    func timehourInt(_ startdate: Date, enddate: Date?) -> Int {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (hr, _) = modf (seconds / 3600)
        return Int(hr)
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    func timeString (_ startdate: Date, enddate: Date?) -> String {
        var result: String?
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (hr, minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        // hr, min, 60 * secf
        if hr == 0 && min == 0 {
            result = String(format: "%.0f", 60 * secf) + " secs"
        } else if hr == 0 && min < 60 {
            result = String(format: "%.0f", min) + " mins " + String(format: "%.0f", 60 * secf) + " secs"
        } else if hr < 25 {
            result = String(format: "%.0f", hr) + " hours " + String(format: "%.0f", min) + " mins"
        } else {
            result = String(format: "%.0f", hr/24) + " days"
        }
        if secf <= 0 {
            result = " ... working ... "
        }
        return result!
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    func timeString (_ seconds: Double) -> String {
        var result: String?
        let (hr, minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        // hr, min, 60 * secf
        if hr == 0 && min == 0 {
            result = String(format: "%.0f", 60 * secf) + "s"
        } else if hr == 0 && min < 60 {
            result = String(format: "%.0f", min) + "m " + String(format: "%.0f", 60 * secf) + "s"
        } else if hr < 25 {
            result = String(format: "%.0f", hr) + "h " + String(format: "%.0f", min) + "m"
        } else {
            result = String(format: "%.0f", hr/24) + "d"
        }
        return result ?? ""
    }

    // Setting date format
    func setDateformat() -> DateFormatter {
        let dateformatter = DateFormatter()
        // We are forcing en_US format of date strings
        dateformatter.locale = Locale(identifier: "en_US")
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        dateformatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateformatter
    }

}
