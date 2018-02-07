//
//  LSComposeTypeButton.swift
//  WeiBo
//
//  Created by lishaopeng on 17/1/5.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit

class LSComposeTypeButton: UIControl {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    //点击按钮要展现控制器的类名
    var clsName: String?
    
    /// 使用图像名称 标题创建按钮，布局从Xib加载
    ///
    /// - Parameters:
    ///   - imageName: 图像
    ///   - title: 标题
    /// - Returns: 一个按钮
    class func composeTypeButton(imageName: String,title: String) -> LSComposeTypeButton{
        
        let nib = UINib(nibName: "LSComposeTypeButton", bundle: nil)
        let btn = nib.instantiate(withOwner: nil, options: nil)[0] as! LSComposeTypeButton
        btn.imageView.image = UIImage(named: imageName)
        btn.titleLabel.text = title
        
        return btn
    }
}
