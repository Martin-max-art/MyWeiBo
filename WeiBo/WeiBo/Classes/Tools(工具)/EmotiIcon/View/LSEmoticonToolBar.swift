//
//  LSEmoticonToolBar.swift
//  表情键盘
//
//  Created by lishaopeng on 17/1/13.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit

@objc protocol LSEmoticonToolBarDelegate: NSObjectProtocol{
    //表情工具栏选中分组项索引
    func emoticonToolBarDidSelectedItermIndex(toolbar: LSEmoticonToolBar,index: Int)
}

///表情键盘底部工具栏
class LSEmoticonToolBar: UIView {

    weak var delegate: LSEmoticonToolBarDelegate?
    
    var selectedIdex: Int = 0 {
        didSet{
            //1.取消所有的选中状态
            for btn in subviews as! [UIButton] {
                btn.isSelected = false
            }
            
            //设置 index 对应的选中状态
            (subviews[selectedIdex] as! UIButton).isSelected = true
        }
    }
    
    override func awakeFromNib() {
        setupUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //布局所有按钮
        let count = subviews.count
        let w = bounds.width / CGFloat(count)
        let rect = CGRect(x: 0, y: 0, width: w, height: bounds.height)
        
        for (i, btn) in subviews.enumerated() {
            btn.frame = rect.offsetBy(dx: CGFloat(i) * w, dy: 0)
        }
        
    }
    
    //MARK: -- 监听方法点击分组项按钮
    @objc fileprivate func clickIterm(button: UIButton){
        //通知代理执行协议方法
        delegate?.emoticonToolBarDidSelectedItermIndex(toolbar: self, index: button.tag)
    }
}
fileprivate extension LSEmoticonToolBar{
    
    func setupUI(){
        
        //0.获取表情包管理器单例
        let manager = LSEmotiIconManager.shared
        
        //从表情包的分组名称 -> 设置按钮
        for (i, p) in manager.packagesArray.enumerated() {
            //1>实例化按钮
            let btn = UIButton()
            //2>设置按钮
            btn.setTitle(p.groupName, for: [])
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.setTitleColor(UIColor.white, for: [])
            btn.setTitleColor(UIColor.darkGray, for: .highlighted)
            btn.setTitleColor(UIColor.darkGray, for: .selected)
           
            //设置按钮图片
            let imageName = "compose_emotion_table_\(p.bgImageName ?? "")_normal"
            let imageNameHL = "compose_emotion_table_\(p.bgImageName ?? "")_selected"
            
            var image = UIImage(named: imageName, in: manager.bundle, compatibleWith: nil)
           
            var imageHL = UIImage(named: imageNameHL, in: manager.bundle, compatibleWith: nil)
            let size = image?.size ?? CGSize()
            let inset = UIEdgeInsetsMake(size.height * 0.5,
                                         size.width * 0.5,
                                         size.height * 0.5,
                                         size.width * 0.5)
            image = image?.resizableImage(withCapInsets: inset)
            imageHL = imageHL?.resizableImage(withCapInsets: inset)
            
            btn.setBackgroundImage(image, for: [])
            btn.setBackgroundImage(imageHL, for: .highlighted)
            btn.setBackgroundImage(imageHL, for: .selected)
            
            btn.sizeToFit()
            //3>添加按钮
            addSubview(btn)
            
            //4.设置按钮的tag
            btn.tag = i
            
            //5.添加按钮的监听方法
            btn.addTarget(self, action: #selector(clickIterm(button:)), for: .touchUpInside)
        }
        
        //默认选中第0个按钮
        (subviews[0] as! UIButton).isSelected = true

    }
    
}
