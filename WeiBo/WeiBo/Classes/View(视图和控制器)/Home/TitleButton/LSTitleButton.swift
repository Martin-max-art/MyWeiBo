//
//  LSTitleButton.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/24.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

class LSTitleButton: UIButton {

    //如果title是nil，就显示首页
    //如果不为nil就显示title和箭头图像
    init(title: String?) {
        super.init(frame: CGRect())
        if title == nil{
            setTitle("首页", for: [])
        }else{
            setTitle(title! + " ", for: [])
           setImage(UIImage(named:"navigationbar_arrow_down"), for: .normal)
           setImage(UIImage(named:"navigationbar_arrow_up"), for: .selected)
        }
        
        //设置字体颜色
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitleColor(UIColor.darkGray, for: [])
        
        //设置大小
        sizeToFit()
        
    
    }
    //重新布局子视图
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let titleLabel = titleLabel,
              let imageView = imageView else {
            return
        }
        print("调整按钮布局")
        //将titleLabel的x向右移动 imageView的宽度
        titleLabel.frame.origin.x = 0
        imageView.frame.origin.x = titleLabel.bounds.width
//        titleLabel.frame = titleLabel.frame.offsetBy(dx: -imageView.bounds.width, dy: 0)
//        //将imageView的x向左移动titleLabel的宽度
//        imageView.frame = imageView.frame.offsetBy(dx: titleLabel.bounds.width, dy: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
