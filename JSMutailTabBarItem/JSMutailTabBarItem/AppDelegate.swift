//
//  AppDelegate.swift
//  JSMutailTabBarItem
//
//  Created by zhen qi wang on 2017/10/20.
//  Copyright © 2017年 xujinkeji. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        window?.rootViewController = JSTabbarVC()
        
        window?.makeKeyAndVisible()
        
        return true
    }
}
