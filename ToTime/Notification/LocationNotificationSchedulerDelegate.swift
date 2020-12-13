//
//  LocationNotificationSchedulerDelegate.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/12.
//

import UserNotifications

protocol LocationNotificationSchedulerDelegate: UNUserNotificationCenterDelegate {
    
    func notificationPermissionDenied()
    
    func locationPermissionDenied()

    func notificationScheduled(error: Error?)
}
