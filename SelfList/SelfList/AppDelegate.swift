//
//  AppDelegate.swift
//  SelfList
//
//  Created by Charles Penunia on 10/31/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let dataManager = DataManager.sharedInstance
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Customize navigation appearance
        let navigationAppearance = UINavigationBar.appearance()
        navigationAppearance.barTintColor = defaultTintColor
        navigationAppearance.tintColor = navigationItemColor
        navigationAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: navigationItemColor]
        
        // Update dynamic priorities
        let fetchRequest = NSFetchRequest<TaskMO>(entityName: "Task")
        do {
            let objects = try dataManager.managedObjectContext.fetch(fetchRequest)
            for object in objects {
                object.updateDynamicPriority()
            }
            dataManager.saveContext()
        } catch {
            let nsError = error as NSError
            print("Unresolved error: \(String(describing: nsError)), \(nsError.userInfo)")
        }
        
        // Get permission for notifications
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        // Register notification categories
        let taskAlertCategory = UNNotificationCategory(identifier: "TASK", actions: [], intentIdentifiers: [], options: .init(rawValue: 0))
        center.setNotificationCategories([taskAlertCategory])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

