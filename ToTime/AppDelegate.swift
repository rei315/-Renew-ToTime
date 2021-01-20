//
//  AppDelegate.swift
//  ToTime
//
//  Created by 김민국 on 2020/12/06.
//

import UIKit
import GoogleMaps


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        GMSServices.provideAPIKey(GoogleKey)            
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController(rootViewController: HomeController())
        window?.rootViewController = nav
        window?.makeKeyAndVisible()        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

