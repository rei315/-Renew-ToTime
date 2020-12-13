//
//  LocationNotificationScheduler.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/12.
//

import CoreLocation
import UserNotifications

class LocationNotificationScheduler: NSObject {
    
    // MARK: - Public Properties
    
    weak var delegate: LocationNotificationSchedulerDelegate?    
    
    // MARK: - Public Functions
    
    /// Request a geo location notification with optional data.
    ///
    /// - Parameter data: Data that will be sent with the notification.
    func request(with notificationInfo: LocationNotificationInfo) {
        askForNotificationPermissions(notificationInfo: notificationInfo)
    }
}

// MARK: - Private Functions
private extension LocationNotificationScheduler {
    
    func askForNotificationPermissions(notificationInfo: LocationNotificationInfo) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound],
            completionHandler: { [weak self] granted, _ in
                guard granted else {
                    DispatchQueue.main.async {
                        self?.delegate?.notificationPermissionDenied()
                    }
                    return
                }
                self?.requestNotification(notificationInfo: notificationInfo)
        })
    }
    
    func requestNotification(notificationInfo: LocationNotificationInfo) {
        let notification = notificationContent(notificationInfo: notificationInfo)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: notificationInfo.notificationId,
                                            content: notification,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { [weak self] (error) in
            DispatchQueue.main.async {
                self?.delegate?.notificationScheduled(error: error)
            }
        }
    }
    
    func notificationContent(notificationInfo: LocationNotificationInfo) -> UNMutableNotificationContent {
        let notification = UNMutableNotificationContent()
        notification.title = notificationInfo.title
        notification.body = notificationInfo.body
        notification.sound = UNNotificationSound.default
        notification.badge = 1
        
        if let data = notificationInfo.data {
            notification.userInfo = data
        }
        return notification
    }
}
