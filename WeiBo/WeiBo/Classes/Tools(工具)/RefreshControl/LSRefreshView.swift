//
//  LSRefreshView.swift
//  刷新控件
//
//  Created by lishaopeng on 17/1/4.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
//刷新视图--负责刷新的相关UI显示和
class LSRefreshView: UIView {

    //刷新状态
    /**
     iOS系统中 UIView封装的旋转动画
     -默认顺时针旋转
     -就近原则
     -要想实现同方向旋转，需要调整一个非常小的数字
     -如果实现360旋转，需要核心动画CABaseAnimation
     */
    var refreshState: LSrefreshState = .Normal{
        didSet{
            switch refreshState {
            case .Normal:
                tipIcon?.isHidden = false
                indicator?.stopAnimating()
                tipLabel?.text = "继续使劲拉..."
//                UIView.animate(withDuration: 0.25, animations: {
//                    self.tipLabel.transform = CGAffineTransform.identity
//                })
                UIView.animate(withDuration: 0.25){
                    self.tipIcon?.transform = CGAffineTransform.identity
                }
            case .Pulling:
                tipLabel?.text = "放手刷新..."
                UIView.animate(withDuration: 0.25){
                    self.tipIcon?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI - 0.001))
                }
                
                
            case .WillRefresh:
                tipLabel?.text = "正在刷新中..."
                //隐藏提示图标
                tipIcon?.isHidden = true
                //显示菊花
                indicator?.startAnimating()
            }
        }
    }
    
    //-----接收父视图的高度---为了刷新控件不需要关心当前具体刷新视图是谁
    var parentViewHeight: CGFloat = 0
    
    @IBOutlet weak var tipIcon: UIImageView?
   
    @IBOutlet weak var tipLabel: UILabel?

    @IBOutlet weak var indicator: UIActivityIndicatorView?
    
    class func refreshView() -> LSRefreshView{
        
        let nib = UINib(nibName: "LSHumanRefresh", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! LSRefreshView
    }
}
