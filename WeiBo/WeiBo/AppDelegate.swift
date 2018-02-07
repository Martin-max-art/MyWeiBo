//
//  AppDelegate.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/13.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
import UserNotifications
import SVProgressHUD
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupAdditions()
        
        print(NSHomeDirectory())
      
        window = UIWindow()
        window?.backgroundColor = UIColor.white
        window?.rootViewController = LSMainViewController()
        window?.makeKeyAndVisible()
        loadAppInfo()
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
//MARK: - 设置应用程序额外信息
extension AppDelegate{
    
   @objc fileprivate func setupAdditions() {
        //1.设置SVPProgressHUD 最小的时间
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        //2.设置网络加载指示器
         AFNetworkActivityIndicatorManager.shared().isEnabled = true
        //3.取得用户授权显示通知
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: ([.alert,.badge,.carPlay,.sound])) { (success, error) in
                print("success=\(success) error = \(error)")
            }
        } else {
            // Fallback on earlier versions
            let notifi = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notifi)
        }
    
    }
}


//MARK: -从服务器加载应用程序信息
extension AppDelegate{
    func loadAppInfo() {
        //url 
        let url = Bundle.main.url(forResource: "demo.json", withExtension: nil)
        
        //data
        let data = NSData(contentsOf: url!)
        
        //写入磁盘
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let jsonPath = (docDir as NSString).appendingPathComponent("demo.json")
        data?.write(toFile: jsonPath, atomically: true)
        
        print(jsonPath)
    }
}
