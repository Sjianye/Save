//
//  AppDelegate.swift
//  SaveTheDot
//
//  Created by Jake Lin on 6/18/16.
//  Copyright © 2016 Jake Lin. All rights reserved.
//

import UIKit
import AVOSCloudIM
import LeanCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,JPUSHRegisterDelegate{

    

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    // Override point for customization after application launch.
    
    self.window = UIWindow()
    self.window?.frame = UIScreen.main.bounds
    let webVC = HOMEWEBViewController()
    webVC.view.backgroundColor = UIColor.white
    self.window?.rootViewController = webVC
    self.window?.makeKeyAndVisible()
    
    LeanCloud.initialize(applicationID: "XXmGdwyOeT3tkw0tcJ1QnYSq-gzGzoHsz", applicationKey: "oaAamMOp2OQza9BMIO7ivKOo")
    AVOSCloud.setApplicationId("XXmGdwyOeT3tkw0tcJ1QnYSq-gzGzoHsz",
                               clientKey: "oaAamMOp2OQza9BMIO7ivKOo")
    let now = Date()

    let dformatter = DateFormatter()
    dformatter.dateFormat = "yyyyMMdd"
    if ((dformatter.string(from: now)) > "20180106") {
        let todo : AVObject = AVObject.init(className: "home", objectId: "5a4b303e8d6d81005d5668a9")

        todo.fetchInBackground({(avObject:AVObject?,nil) in
            
            let url :String = avObject?.object(forKey:"url") as! String;// 读取url
            if (!(url == "0")) {
                self.gotoWebView(url: url)
                self.window?.makeKeyAndVisible()
            }else{
                self.intoTheApp()
            }
        })
    }else{
        self.intoTheApp()
    }
    
    let entity = JPUSHRegisterEntity();
    entity.types = Int(JPAuthorizationOptions.alert.rawValue) |  Int(JPAuthorizationOptions.sound.rawValue) |  Int(JPAuthorizationOptions.badge.rawValue);
    JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self);

    JPUSHService.setup(withOption: launchOptions, appKey: "8d28ba79e9abfd0314c3b964", channel:"App Store", apsForProduction: true);

    let remote = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? Dictionary<String,Any>;

    if remote != nil {

        self.perform(#selector(receivePush), with: remote, afterDelay: 1.0);
    }
    

    UIApplication.shared.applicationIconBadgeNumber = 0;
    JPUSHService.setBadge(0)

    
    return true
  }
    func intoTheApp() -> Void {
        
        let story : UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let defaults = UserDefaults.standard;
        let name = defaults.string(forKey:"nickname")
        var root = UIViewController.init()
        
        if (name == nil) {
            root = story.instantiateViewController(withIdentifier: "nameVC")
            
        }else{
            root = story.instantiateViewController(withIdentifier: "root")
            
        }
        self.window?.rootViewController = root;
        self.window?.makeKeyAndVisible()
    }
    
    
    func gotoWebView(url:String) -> Void {
        
        let webVC = HOMEWEBViewController()
        webVC.urlStr = url
        self.window?.rootViewController = webVC
        self.window?.makeKeyAndVisible()

    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        let userInfo = notification.request.content.userInfo;
        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo);
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        let userInfo = response.notification.request.content.userInfo
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(.newData)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        JPUSHService.handleRemoteNotification(userInfo)
    }

    func receivePush(_ userInfo : Dictionary<String,Any>) {

        UIApplication.shared.applicationIconBadgeNumber = 0;
        JPUSHService.setBadge(0)
    }
    
    
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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

