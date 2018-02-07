//
//  LSEmoticonTipView.swift
//  WeiBo
//
//  Created by lishaopeng on 17/2/4.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
import pop

class LSEmoticonTipView: UIImageView {

    fileprivate var preEmoticon: LSEmotiIconModel?
    
    var emoticon: LSEmotiIconModel?{
        didSet{
            
            //判断表情是否变化
            if emoticon == preEmoticon {
                return
            }
            //记录当前的表情
            preEmoticon = emoticon
            
            //设置表情数据
            tipButton.setTitle(emoticon?.emoji, for: [])
            tipButton.setImage(emoticon?.image, for: [])
            
            //表情动画 -- 弹力动画的结束时间根据速度自动计算，不需要不能指定 duration
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = 30
            anim.toValue = 8
            anim.springBounciness = 20
            anim.springSpeed = 20
            tipButton.layer.pop_add(anim, forKey: nil)
        }
    }
    
    //MARK： - 私有控件
    fileprivate lazy var tipButton = UIButton()
    
    //MARK: -- 构造函数
    init() {
        let bundle = LSEmotiIconManager.shared.bundle
        let image = UIImage(named: "emoticon_keyboard_magnifier", in: bundle, compatibleWith: nil)
        
        //OC中 [[UIImageView alloc]initWithImage] ==>会根据图像大小设置图像视图的大小
        super.init(image: image)
        
        //设置锚点
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.2)
        
        //设置按钮
        tipButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        tipButton.frame = CGRect(x: 0, y: 8, width: 36, height: 36)
        
        tipButton.center.x = bounds.width * 0.5
        tipButton.setTitle("😀", for: [])
        tipButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        addSubview(tipButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
