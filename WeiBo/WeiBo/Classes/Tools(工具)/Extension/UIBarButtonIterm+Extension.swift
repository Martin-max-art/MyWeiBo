//
//  UIBarButtonIterm+Extension.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/9.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import Foundation

extension UIBarButtonItem{
    
    /// 创建UIBarButtonIterm
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - fontSize: 字体大小 默认16
    ///   - target: 对象
    ///   - action: 点击方法
    convenience init(title: String,fontSize: CGFloat = 16,target: AnyObject?, action: Selector,isBack: Bool = false) {
        let btn: UIButton  = UIButton.cz_textButton(title, fontSize: fontSize, normalColor: UIColor.darkGray, highlightedColor: UIColor.orange)
        btn.addTarget(target, action:action, for: .touchUpInside)
        if isBack {
            let imageName = "navigationbar_back_withtext"
            btn.setImage(UIImage(named:imageName), for: .normal)
            btn.setImage(UIImage(named:imageName + "_highlighted"), for: .highlighted)
            btn.sizeToFit()
        }
        
        //实例化 
        self.init(customView: btn)
    
    }
}
