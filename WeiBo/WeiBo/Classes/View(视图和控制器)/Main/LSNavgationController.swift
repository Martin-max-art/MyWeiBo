//
//  WBNavgationController.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/9.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

class LSNavgationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //隐藏默认的 NavigationBar
        navigationBar.isHidden = true
    }
    
    
    //重写 push方法 所有的push动作都会调用此方法
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
      
        //如果不是栈底的控制器才需要隐藏  根控制器不需要处理
        if childViewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            if let vc = viewController as? LSBaseViewController {
                var title = "返回"
                //判断控制器的级数，只有一个子控制器的时候，显示线底控制器的标题
                if childViewControllers.count == 1 {
                    title = childViewControllers.first?.title ?? "返回"
                }
                vc.navItem.leftBarButtonItem = UIBarButtonItem(title: title, target: self, action: #selector(popToParent),isBack:true)
            }

        }
        super.pushViewController(viewController, animated: true)
    }
    
    func popToParent() {
        popViewController(animated: true)
    }

}
