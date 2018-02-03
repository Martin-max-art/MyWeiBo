//
//  LSWelcomeView.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/26.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
import SDWebImage
//欢迎页
class LSWelcomeView: UIView {

    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var iconViewToBottom: NSLayoutConstraint!
    class func welcomeView() -> LSWelcomeView {
        let nib = UINib(nibName: "LSWelcomeView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! LSWelcomeView
        
        v.frame = UIScreen.main.bounds
        
        return v
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //提示:initWithCoder只是刚刚从 XIB的二进制文件将试图数据加载完成
        //还没有和代码连线建立起连线
        print("initWithCoder\(iconView)")
        
    }
    
    override func awakeFromNib() {
        guard let urlString = LSNetworkManager.shared.userAccount.avatar_large,
        let url = URL(string: urlString) else {
            return
        }
        iconView.sd_setImage(with: url, placeholderImage: UIImage(named: "avatar_default_big"))
       
    }
    
    //视图被添加到 window 上，表示视图已经显示
    override func didMoveToWindow() {
        super.didMoveToWindow()
        //视图使用自动布局来设置的，只是设置了约束
        //-当视图被添加到窗口上时，根据父视图的大小，计算约束值，更新控件位置
        //-self.layoutIfNeeded() 会直接按照当前的约束直接更新控件位置
        //-执行之后，控件所在位置就是xib中布局位置
        self.layoutIfNeeded()
        iconViewToBottom.constant = bounds.size.height - 200
        
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.7,initialSpringVelocity: 0,
                       options: [], animations: {
                        //更新约束
                        self.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 1.0, animations: {
                self.tipLabel.alpha = 1.0
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        }
        
    }
}
