//
//  Notifications.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 21.02.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

import Foundation

class Notifications {
    func showNotification(message: String) {
        let notification = NSUserNotification()
        notification.title = "A scheduled backup is completed"
        notification.subtitle = message
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.delegate = self as? NSUserNotificationCenterDelegate
        NSUserNotificationCenter.default.deliver(notification)
    }
}
