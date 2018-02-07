//
//  LSRefreshControl.swift
//  WeiBo
//
//  Created by lishaopeng on 17/1/3.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
/// 刷新状态切换的临界点
fileprivate let LSRefreshOffset: CGFloat = 100

/// 刷新状态
///
/// - Normal: 普通状态，什么也不做
/// - Pulling: 超过临界点，如果放手，开始刷新
/// - WillRefresh: 用户超过临界点，并且放手
enum LSrefreshState{
    case Normal
    case Pulling
    case WillRefresh
}

//负责刷新相关的逻辑处理
class LSRefreshControl: UIControl {

    //刷新控件的父视图，下拉刷新控件应该适用于 UITableView /UICollectionView
    fileprivate var scrollView: UIScrollView?
    
    fileprivate lazy var refreshView: LSRefreshView = LSRefreshView.refreshView()
    
    init(){
        super.init(frame: CGRect())
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    //willMove addSubView 方法会调用
    //当添加到父视图的时候，newSuperView是父视图
    //当父视图被移除的时候，newSuperView是nil
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //记录父视图
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        scrollView = sv
        
        //KVO监听父视图的contentOffset
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    //本视图从父视图移除
    //提示所有的下拉刷新都是监听父视图的contentOffset
    override func removeFromSuperview() {
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
    }
    
    //所有KVO 方法会统一调用此方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //print(scrollView?.contentOffset ?? "")
        
        guard let sv = scrollView else {
            return
        }
        //初始高度应该是0
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        //print("height\(height)")
        
        if height < 0 {
            return
        }
        
        //可以根据高度设置刷新控件的frame
        self.frame = CGRect(x: 0,
                            y: -height,
                            width: sv.bounds.width,
                            height: height)
        
       
        //----传递父视图高度,如果正在刷新中不传递
        if refreshView.refreshState != .WillRefresh{
            refreshView.parentViewHeight = height
        }
        
        
        //判断临界点
        if sv.isDragging{
            if height > LSRefreshOffset && (refreshView.refreshState == .Normal){
                //print("放手刷新")
                refreshView.refreshState = .Pulling
            }else if height <= LSRefreshOffset && (refreshView.refreshState == .Pulling){
                refreshView.refreshState = .Normal
               //print("再使劲")
            }
            
        }else{//放手 判断是否炒股临界点
            
            if refreshView.refreshState == .Pulling{
                //print("准备开始刷新")
//                //刷新结束之后，将状态修改为.Nomal
//                refreshView.refreshState = .WillRefresh
//                
//                //让整个刷新视图能够显示出来
//                //解决方法:修改表格的contentInset
//                var inset = sv.contentInset
//                inset.top += LSRefreshOffset
//                sv.contentInset = inset
                beginRefreshing()
                
                //发送刷新数据的事件
                sendActions(for: .valueChanged)
            }
        }
    }
    
    
    
    //开始刷新
    func beginRefreshing(){
        //print("开始***刷新")
        //判断父视图
        guard let sv = scrollView else {
            return
        }
        //判断是否正在刷新，如果正在刷新，直接返回
        if refreshView.refreshState == .WillRefresh {
            return
        }
        
        //设置刷新视图状态
        refreshView.refreshState = .WillRefresh
        
        //调整表格间距
        var inset = sv.contentInset
        inset.top += LSRefreshOffset;
        sv.contentInset = inset
        
        //设置刷新视图的父视图高度
        refreshView.parentViewHeight = LSRefreshOffset
        
        //如果开始调用beginRefreshing 会重复发送刷新事件
//        sendActions(for: .valueChanged)
    }
    //结束刷新
    func endRefreshing(){
        //print("结束***刷新")
        guard let sv = scrollView else {
            return
        }
        //判断是否正在刷新，如果不是直接返回
        if refreshView.refreshState != .WillRefresh {
            return
        }
        
        //恢复刷新视图的状态
        //设置刷新视图状态
        refreshView.refreshState = .Normal
        
        //恢复表格视图的contentInset
        var inset = sv.contentInset
        inset.top -= LSRefreshOffset
        
        sv.contentInset = inset
    }


}
extension LSRefreshControl{
    
  fileprivate func setupUI(){
        self.backgroundColor = UIColor.clear
    
        //设置超出部分不显示
        //clipsToBounds = true
        
        //添加刷新视图 --从xib加载出来，默认是xib中指定的宽高
        addSubview(refreshView)
        
        //自动布局 -- 设置xib控件自动布局需要指定宽高
    refreshView.translatesAutoresizingMaskIntoConstraints = false;
    
    addConstraint(NSLayoutConstraint(item: refreshView,
                                     attribute: .centerX,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .centerX,
                                     multiplier: 1.0,
                                     constant: 0))
    addConstraint(NSLayoutConstraint(item: refreshView,
                                     attribute: .bottom,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 0))
    addConstraint(NSLayoutConstraint(item: refreshView,
                                     attribute: .width,
                                     relatedBy: .equal,
                                     toItem: nil,
                                     attribute: .notAnAttribute,
                                     multiplier: 1.0,
                                     constant: refreshView.bounds.width))
    addConstraint(NSLayoutConstraint(item: refreshView,
                                     attribute: .height,
                                     relatedBy: .equal,
                                     toItem: nil,
                                     attribute: .notAnAttribute,
                                     multiplier: 1.0,
                                     constant: refreshView.bounds.height))
    }
}
