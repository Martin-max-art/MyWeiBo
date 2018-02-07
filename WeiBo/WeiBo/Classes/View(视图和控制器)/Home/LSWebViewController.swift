//
//  LSWebViewController.swift
//  WeiBo
//
//  Created by lishaopeng on 17/1/12.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
//网页控制器
class LSWebViewController: LSBaseViewController {

    fileprivate lazy var webView = UIWebView(frame: UIScreen.main.bounds)
    
    //要加载的URL字符串
    var urlString: String?{
        didSet{
            guard let urlString = urlString,
                  let url = URL(string: urlString) else {
                   return
            }
            webView.loadRequest(URLRequest(url: url))
        }
    }
}
extension LSWebViewController{
    override func setUpTableView() {
        //设置标题
        navItem.title = "网页"
        //设置webView
        view.insertSubview(webView, belowSubview: navigationBar)
        //设置 contenInset
        webView.scrollView.contentInset.top = navigationBar.bounds.height
    }
}
