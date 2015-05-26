//
//  AppDelegate.swift
//  iba
//
//  Created by Raymond Kennedy on 3/7/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let CAR_DINGED: String = "CAR_DINGED";
    
    var window: UIWindow?
    let googleMapsApiKey = "AIzaSyDLqY2Bq_dD1dei_t-DorEzGAe2Azx1h9c"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        
        // Setup google maps
        GMSServices.provideAPIKey(googleMapsApiKey)
        
        // Setup parse
        Parse.enableLocalDatastore()
        Parse.setApplicationId("D7gVBFc0P2dkb4XoronMmAbDGybOfKJQZKhg6akQ", clientKey: "AniURE10twa3H0g0tVnBN6vL0PO5mAZxtAtPJiqV")
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        // Setup view contro
        setupView()
        
        // Enable push notifications
        askForPush(application);
        
        return true
    }
    
    func askForPush(application: UIApplication) {
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: (.Sound | .Alert | .Badge), categories: nil))
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        let pushDict: NSDictionary = userInfo as NSDictionary
        let type: String = pushDict.valueForKey("custom") as! String
        
        if (type == CAR_DINGED) {
            // do car ding stuff
            println("Your car has been dinged");
        }
        
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    func setupView() {
        let navigationController = UINavigationController()
        let homeViewController = HomeViewController()
        navigationController.viewControllers = [homeViewController]
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = navigationController
        self.window!.makeKeyAndVisible()
        self.window!.backgroundColor = UIColor.whiteColor()
        
    }
    
    // MARK: Push Notification Delegate Methods
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Did fail to register for remote notifications")
        println("\(error), \(error.localizedDescription)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("Did register with device token: \(deviceToken)")
        
        var currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = [("global" as NSString)]
        currentInstallation.saveInBackgroundWithBlock(nil)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

