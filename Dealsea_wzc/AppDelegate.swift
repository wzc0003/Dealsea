//
//  AppDelegate.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge,.Sound,.Alert], categories: nil))
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let tabbar = UITabBarController()
        tabbar.tabBar.tintColor = UIColor(red: 9/255, green: 187/255, blue: 7/255, alpha: 1)
        
        let navi1 = UINavigationController(rootViewController: MainViewController())
//        let navi2 = UINavigationController(rootViewController: CouponsViewController())
        let navi3 = UINavigationController(rootViewController: AlertViewController())
        let navi4 = UINavigationController(rootViewController: MineViewController())
        tabbar.addChildViewController(navi1)
        navi1.tabBarItem.title = "Deals"
        navi1.tabBarItem.image = UIImage(named: "home")
        navi1.tabBarItem.selectedImage = UIImage(named: "home_select")
        navi1.tabBarItem.setTitleTextAttributes([NSFontAttributeName:
            UIFont.systemFontOfSize(10)], forState: UIControlState.Normal)
        navi1.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -1)
        
//        tabbar.addChildViewController(navi2)
//        navi2.tabBarItem.setTitleTextAttributes([NSFontAttributeName:
//            UIFont.systemFontOfSize(10)], forState: UIControlState.Normal)
//        navi2.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -1)
//        navi2.tabBarItem.title = "Coupons"
//        navi2.tabBarItem.image = UIImage(named: "coupons")
//        navi2.tabBarItem.selectedImage = UIImage(named: "home_select")

        
        tabbar.addChildViewController(navi3)
        navi3.tabBarItem.setTitleTextAttributes([NSFontAttributeName:
            UIFont.systemFontOfSize(10)], forState: UIControlState.Normal)
        navi3.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -1)
        navi3.tabBarItem.title = "Alert"
        navi3.tabBarItem.image = UIImage(named: "alert")
        navi3.tabBarItem.selectedImage = UIImage(named: "alert_select")
        
        tabbar.addChildViewController(navi4)
        navi4.tabBarItem.setTitleTextAttributes([NSFontAttributeName:
            UIFont.systemFontOfSize(10)], forState: UIControlState.Normal)
        navi4.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -1)
        navi4.tabBarItem.title = "Me"
        navi4.tabBarItem.image = UIImage(named: "mine")
        navi4.tabBarItem.selectedImage = UIImage(named: "mine_select")
        
        self.window?.rootViewController = tabbar
        self.window?.makeKeyAndVisible()
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        let receiveNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
        if (receiveNotification != nil) {
            //接受到推送
            print(receiveNotification)
            let tabbar:UITabBarController = self.window?.rootViewController as! UITabBarController
            let item:UITabBarItem = tabbar.tabBar.items![1]
            item.badgeValue = "1"
            let defaults = NSUserDefaults.standardUserDefaults()
            var CurrentDeaData:NSMutableArray = NSMutableArray()
            if(defaults.objectForKey("CurrentDeaData") != nil){
                CurrentDeaData = defaults.objectForKey("CurrentDeaData") as! NSMutableArray
            }
            if(CurrentDeaData.count == 10){
                CurrentDeaData.removeObjectAtIndex(0)
            }
            let CurrentDea:[String:AnyObject] = (receiveNotification!["data"] as! [String:AnyObject])["msg"] as! [String:AnyObject]
            CurrentDeaData.addObject(CurrentDea)
            defaults.setObject(CurrentDeaData, forKey: "CurrentDeaData")
            defaults.synchronize()
        }
    
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print(deviceToken)
        let defaults = NSUserDefaults.standardUserDefaults()
        let tokenString:String = deviceToken.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        defaults.setObject(tokenString, forKey: "deviceToken")
        defaults.synchronize()
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
         var dict:Dictionary<String,AnyObject> = Dictionary()
        dict["devicetoken"] = deviceToken
        print("deviceToken:::::\(deviceToken)")
        if(defaults.objectForKey("username") != nil){
            dict["userid"] = defaults.objectForKey("userid") as! String
            dict["login"] = "1"
        }
        if UIApplication.sharedApplication().currentUserNotificationSettings()?.types == UIUserNotificationType.None{
            dict["devicestatus"] = 0
        }else{
            dict["devicestatus"] = 1
        }
        dict["devicetype"] = 1
        manager.POST("https://dealsea.com/profile/login?app="+appVersion, parameters: dict, progress: { (progress) in
            
            }, success: { (task, success) in
                print(success)
            }) { (task, error) in
                print(error.description)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
     //接收到推送
        let tabbar:UITabBarController = self.window?.rootViewController as! UITabBarController
        let item:UITabBarItem = tabbar.tabBar.items![1] 
        item.badgeValue = "1"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var CurrentDeaData:NSMutableArray = NSMutableArray()
        if(defaults.objectForKey("CurrentDeaData") != nil){
            CurrentDeaData = defaults.objectForKey("CurrentDeaData") as! NSMutableArray
        }
        if(CurrentDeaData.count == 10){
            CurrentDeaData.removeObjectAtIndex(0)
        }
        let CurrentDea:[String:AnyObject] = (userInfo["data"] as! [String:AnyObject])["msg"] as! [String:AnyObject]
        CurrentDeaData.addObject(CurrentDea)
        defaults.setObject(CurrentDeaData, forKey: "CurrentDeaData")
        defaults.synchronize()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error.description)
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

