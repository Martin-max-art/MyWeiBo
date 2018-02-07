//
//  LSMeituanRefreshView.swift
//  刷新控件
//
//  Created by lishaopeng on 17/1/5.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit

class LSMeituanRefreshView: LSRefreshView {

    @IBOutlet weak var buildingIconView: UIImageView!
 
    @IBOutlet weak var kangarooIconView: UIImageView!

    @IBOutlet weak var earthIconView: UIImageView!
    
   override var parentViewHeight: CGFloat{
        didSet{
            //print("父视图高度\(parentViewHeight)")
            if parentViewHeight < 45 {
                return
            }
            //高度差 / 最大高度差
            //45 == 1-->0.2
            //117 == 0-->1
            var scale: CGFloat
            if parentViewHeight > 117 {
                scale = 1
            }else{
                scale = 1 - ((117 - parentViewHeight) / (117 - 45))
            }
            kangarooIconView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    override func awakeFromNib() {
        //1.房子
        let buidImage1 = #imageLiteral(resourceName: "icon_building_loading_1")
        let buidImage2 = #imageLiteral(resourceName: "icon_building_loading_2")
        buildingIconView.image = UIImage.animatedImage(with: [buidImage1,buidImage2], duration: 0.5)
        
        //2.地球
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = -2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 1.5
        anim.isRemovedOnCompletion = false
        earthIconView.layer.add(anim, forKey: nil)
        
        //3.袋鼠
        //(0)设置动画
        let kImage1 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_1")
        let kImage2 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_2")
        kangarooIconView.image = UIImage.animatedImage(with: [kImage1,kImage2], duration: 0.5)
        //(1)设置锚点
        kangarooIconView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        //(2)设置center
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - 45
        kangarooIconView.center = CGPoint(x: x, y: y)
        kangarooIconView.transform = CGAffineTransform(scaleX: 0.2 , y: 0.2)
       
    }
    

}
