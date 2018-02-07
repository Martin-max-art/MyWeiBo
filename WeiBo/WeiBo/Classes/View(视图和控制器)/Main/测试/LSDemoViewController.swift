//
//  WBDemoViewController.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/9.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

class LSDemoViewController: LSBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     title = "第\(navigationController?.childViewControllers.count ?? 0)个"
        
    }
    func showNext() {
        let vc = LSDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension LSDemoViewController{
    override func setUpTableView() {
    
        super.setUpTableView()
         navItem.rightBarButtonItem = UIBarButtonItem(title: "下一个", target: self, action: #selector(showNext))
    }
}
