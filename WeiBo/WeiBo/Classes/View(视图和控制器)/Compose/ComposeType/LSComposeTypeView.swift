//
//  LSComposeTypeView.swift
//  WeiBo
//
//  Created by lishaopeng on 17/1/5.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
import pop

///撰写微博视图
class LSComposeTypeView: UIView {
   @IBOutlet weak var scrollView: UIScrollView!
    //返回前一页按钮的约束
    @IBOutlet weak var returnButtonCenterX: NSLayoutConstraint!
    //关闭按钮
    @IBOutlet weak var closeButtonCenterX: NSLayoutConstraint!
    //返回按钮
    @IBOutlet weak var returnButton: UIButton!
    
    fileprivate var completionBlock:((_ clsName: String?)->())?
    
    //按钮数组
    fileprivate let buttonsInfo = [["imageName": "tabbar_compose_idea", "title": "文字", "clsName": "LSComposeViewController"],
                               ["imageName": "tabbar_compose_photo", "title": "照片/视频"],
                               ["imageName": "tabbar_compose_weibo", "title": "长微博"],
                               ["imageName": "tabbar_compose_lbs", "title": "签到"],
                               ["imageName": "tabbar_compose_review", "title": "点评"],
                               ["imageName": "tabbar_compose_more", "title": "更多", "actionName": "clickMore"],
                               ["imageName": "tabbar_compose_friend", "title": "好友圈"],
                               ["imageName": "tabbar_compose_wbcamera", "title": "微博相机"],
                               ["imageName": "tabbar_compose_music", "title": "音乐"],
                               ["imageName": "tabbar_compose_shooting", "title": "拍摄"]]
    
    class func composeView() -> LSComposeTypeView{
        
        let nib = UINib(nibName: "LSComposeTypeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! LSComposeTypeView
        //XIB加载默认600*600
        v.frame = UIScreen.main.bounds
        v.setupUI()
        return v
    }
    
    
    //显示当前视图
    //OC中的block如果当前方法不能执行，通常使用属性记录，在需要的时候执行
    func show(completion: @escaping (_ clsName: String?)->()){
        
        //0>记录闭包
        completionBlock = completion
        
        //1.将当前视图添加到
        guard let mainVC = UIApplication.shared.keyWindow?.rootViewController else{
            return
        }
        //2.加到根视图控制器
        mainVC.view.addSubview(self)
        
        //3.开始动画
        showCurrentView()
    }
   
    @objc fileprivate func clickButton(selectedButton: LSComposeTypeButton){
        print("点我了\(selectedButton)")
        //1.判断当前显示的视图
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let v = scrollView.subviews[page]
        
        //2.遍历当前视图
        //-选中的按钮放大
        //-为选中的按钮缩小
        for (i, btn)  in v.subviews.enumerated() {
            
            //1>放大缩小
            let scaleAnim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            //x,y在系统中使用CGPoint 表示，如果要转换成id,需要使用 ‘NSValue’包装
            let scale = (selectedButton == btn) ? 2 : 0.2
            scaleAnim.toValue = NSValue(cgPoint: CGPoint(x: scale, y: scale))
            scaleAnim.duration = 0.5
            btn.pop_add(scaleAnim, forKey: nil)
            
            
            //2>渐变动画 - 动画组
            let alphaAnim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            alphaAnim.toValue = 0.2
            alphaAnim.duration =  0.5
            btn.pop_add(alphaAnim, forKey: nil)
            //3>监听最后一个
            if i==0 {
                alphaAnim.completionBlock = {_,_ in
                    //需要执行回调
                    print("完成回调展现控制器")
                    self.completionBlock?(selectedButton.clsName)
                }
            }
        }
    }
    //MARK:点击更多按钮
    @objc fileprivate func clickMore(){
        print("点击更多")
        //1.将scrollView滚动到第二页
        let offset = CGPoint(x: scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
        
        //2.处理底部按钮，让两个按钮分开
        returnButton.isHidden = false
        let margin = scrollView.bounds.width / 6
        closeButtonCenterX.constant += margin
        returnButtonCenterX.constant -= margin
        UIView.animate(withDuration: 0.5){
            self.layoutIfNeeded()
        }
    }
    //MARK:返回上一页
    @IBAction func returnButtonClick(_ sender: Any) {
        //1.将scrollView滚动到第一页
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        //2.让两个按钮合并
        returnButton.isHidden = true
        closeButtonCenterX.constant = 0
        returnButtonCenterX.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
            self.returnButton.alpha = 0
        }, completion: { (_) in
            self.returnButton.alpha = 1
            self.returnButton.isHidden = true
        })
    }
   
    
    //MARK:关闭视图
    @IBAction func closeBtn(_ sender: Any) {
       // removeFromSuperview()
        hideButtons()
    }
}
//fileprivate 让extension中的所有方法都是私有的
fileprivate extension LSComposeTypeView{
    func setupUI(){
        
        //0.强行更新布局
        layoutIfNeeded()
        
        //1.向scrollView添加按钮
        let rect = scrollView.bounds
        let width = scrollView.bounds.width
        for i in 0..<2 {
            //2.向视图添加按钮
            let v = UIView(frame:rect.offsetBy(dx: CGFloat(i) * width, dy: 0))
            addButtons(v: v, idx: i * 6)
            
            //3.将视图添加到scrollView
            scrollView.addSubview(v)
        }
        //4.设置scrollView
        scrollView.contentSize = CGSize(width: 2 * width, height: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        //禁用滚动
        scrollView.isScrollEnabled = false
    }
    /// 向V中添加按钮，按钮中的数组索引从idx开始
    func addButtons(v: UIView, idx:Int){
        //从idx开始，添加6个按钮
        let count = 6
        for i in idx..<(idx + count){
            
            if i >= buttonsInfo.count{
                break
            }
            
            //0.获取图像名称和title
           let dict = buttonsInfo[i]
            guard let imageName = dict["imageName"],
            let title = dict["title"] else {
                continue
            }
            //1.创建按钮
            let btn = LSComposeTypeButton.composeTypeButton(imageName: imageName, title: title)
            //2.将btn添加到视图
            v.addSubview(btn)
            //3.添加监听方法
            if let actionName = dict["actionName"]{
                //OC中使用NSSelectorFromString(@"clickMore")
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }else{
                
                btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
            }
            
            //4.设置要展现的类名 -- 注意不需要任何的判断，有了就设置，没有就不设置
            btn.clsName = dict["clsName"]
        }
        
        //遍历视图的子视图，布局按钮
        //准备常量 
        let btnSize = CGSize(width: 100, height: 100)
        let margin = (v.bounds.width - 3 * btnSize.width) / 4
        for (i, btn) in v.subviews.enumerated() {
            let y: CGFloat = (i > 2) ? (v.bounds.height - btnSize.height) : 0
            let col = i % 3;
            let x = CGFloat((col + 1)) * margin + CGFloat(col) * btnSize.width
            btn.frame = CGRect(x: x, y: y, width: btnSize.width, height: btnSize.height)
        }
    }
}

//MARK:动画方法扩展
fileprivate extension LSComposeTypeView{
    
    //Mark: - 消除动画
    fileprivate func hideButtons(){
        //1.根据 contentOffset判断当前显示的子视图
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let v = scrollView.subviews[page]
        
        for (i, btn) in v.subviews.enumerated().reversed() {
           
            //1.创建动画
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            //2.设置动画属性
            anim.fromValue = btn.center.y
            anim.toValue = btn.center.y + 350
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(v.subviews.count - i) * 0.025
            //3.添加动画
            btn.layer.pop_add(anim, forKey: nil)
            //4.监听第0个动画是最后一个执行的
            if i == 0{
                anim.completionBlock = {_,_ in
                    self.hideCurrentView()
                }
            }
        }
       
    }
    //隐藏当前视图 -- 开始时间
    fileprivate func hideCurrentView(){
        //1.创建动画
        let anim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.fromValue = 1
        anim.toValue = 0
        anim.duration = 1.0
        
        //2.添加到视图
        pop_add(anim, forKey: nil)
        
        anim.completionBlock = {_, _ in
            self.removeFromSuperview()
        }
    }
    
    fileprivate func showCurrentView(){
        //1.创建动画
        let anim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = 0.4
        //2.添加到视图
        pop_add(anim, forKey: nil)
        
        //3.添加按钮的动画
        showButtons()
    }
    //弹力显示所有的按钮
    fileprivate func showButtons(){
        //1.获取scrollView的子视图的第0个视图
        let v = scrollView.subviews[0]
        //2.遍历v中的所有按钮
        for (i, btn) in v.subviews.enumerated() {
            //1>创建动画
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            //2>设置动画属性
            anim.fromValue = btn.center.y + 350
            anim.toValue = btn.center.y
            //弹力系数  0--20
            anim.springBounciness = 8
            //弹力速度
            anim.springSpeed = 8
            
            //设置动画启动时间
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(i) * 0.025
            
            //3>添加动画
            btn.pop_add(anim, forKey: nil)
        }
    }
}
