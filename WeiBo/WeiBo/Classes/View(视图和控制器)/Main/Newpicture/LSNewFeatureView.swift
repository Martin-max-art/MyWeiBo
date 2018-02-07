//
//  LSNewFeatureView.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/26.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

class LSNewFeatureView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
 
    
    @IBAction func endButtonClick(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    class func newFeatureView() -> LSNewFeatureView {
        let nib = UINib(nibName: "LSNewFeatureView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! LSNewFeatureView
        v.frame = UIScreen.main.bounds
        return v
    }
    
    override func awakeFromNib() {
        let count = 4
        let rect = UIScreen.main.bounds
        for i in 0..<count {
            let imageName = "new_feature_\(i + 1)"
            let iv = UIImageView(image: UIImage(named:imageName))
            
            //设置大小
            iv.frame = rect.offsetBy(dx: CGFloat(i) * rect.width, dy: 0)
            scrollView.addSubview(iv)
            
        }
        //指定 scrollView的属性
        scrollView.contentSize = CGSize(width: CGFloat(count + 1)*rect.width, height: rect.height)
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        //隐藏按钮
        endButton.isHidden = true
    }
}
extension LSNewFeatureView:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //1.滚动到最后一页，让视图移除
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
        //2.
        if page == scrollView.subviews.count {
            print("欢迎您")
            removeFromSuperview()
        }
        endButton.isHidden = (page != scrollView.subviews.count - 1)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //0 一旦滚动隐藏按钮
        endButton.isHidden = true
        
        //1.计算当前的偏移量
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
       // print("page = \(page)")
        //2.设置分页控件
        pageControl.currentPage = page
        
        //3.分页控件的隐藏
        pageControl.isHidden = (page == scrollView.subviews.count)
    }
}
