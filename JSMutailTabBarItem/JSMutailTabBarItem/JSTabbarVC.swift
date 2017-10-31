//
//  JSTabbarVC.swift
//  JSMutailTabBarItem
//
//  Created by zhen qi wang on 2017/10/20.
//  Copyright © 2017年 xujinkeji. All rights reserved.
//

import UIKit

class JSTabbarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1: UIViewController = ViewController()
        vc1.title = "VC1"
        self.addChildViewController(vc1)
        
        
        let vc2: UIViewController = ViewController()
        vc2.title = "vc2"
        self.addChildViewController(vc2)
        
        let vc3: UIViewController = ViewController()
        vc3.title = "vc3"
        self.addChildViewController(vc3)
        
    }
}
