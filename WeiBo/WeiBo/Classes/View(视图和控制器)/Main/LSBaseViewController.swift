//
//  WBBaseViewController.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/9.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
// 面试题：OC 中支持多继承吗？如果不支持，如何替代？答案：使用协议替代！
// Swift 的写法更类似于多继承！
//class WBBaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

//MARK:- 所有控制器的基类控制器
class LSBaseViewController: UIViewController{

    //用户登录标记
    //var userlogIn:Bool = true
    
    //访客视图信息字典
    var vistorInforDic: [String : String]?
    
    
    //如果用户没有登录就不创建
    var tableView: UITableView?
    //刷新控件
    var refreshControl: LSRefreshControl?
    //上拉刷新的标记
    var isPullRefresh:Bool = false
    
    //自定义导航条
    lazy var navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.cz_screenWidth(), height: 64))
    //自定义导航条目
    lazy var navItem = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
      
        LSNetworkManager.shared.userLogon ? loadData() : ()
        
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name(rawValue: LSUserLoginSuccessNotification), object: nil)
    }
    
    deinit {
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:重写title的 set方法
    override var title: String?{
        didSet{
            navItem.title = title
        }
    }
    //加载数据
    func loadData(){//如果子类不实现任何方法，需要关闭刷新
        refreshControl?.endRefreshing()
    }

}
//MARK:- 设置访客视图的监听方法
extension LSBaseViewController{
    //登录成功处理
   @objc fileprivate func loginSuccess(n:NotificationCenter){
    
        print("登录成功")
        //登录成功之前左边是注册，右边是登录
         navItem.leftBarButtonItem = nil
         navItem.rightBarButtonItem = nil
    
         //更新UI  将访客试图替换为表格视图
        //需要重新设置View
        //当view 的getter方法时， 如果view为nil 会调用 loadView -> viewDidLoad
         view = nil
        //********关键  注销通知  否则会在执行viewDidLoad的时候重复注册通知
        NotificationCenter.default.removeObserver(self)
    }
    
   @objc fileprivate func login(){
        print("登录")
        //发送通知
        NotificationCenter.default.post(name: NSNotification.Name(LSUserHaveLoginNotification), object: nil);
    }
   @objc fileprivate func regiter(){
        print("注册")
    }
    
}
//MARK:- 设置界面
extension LSBaseViewController {
    func setUpUI() {
         view.backgroundColor = UIColor.cz_random()
         //设置内容缩进
        automaticallyAdjustsScrollViewInsets = false
        
        setNavagationBar()
        setUpTableView()
        LSNetworkManager.shared.userLogon ? setUpTableView() : setupVistorView()
    }
    //设置tableView
    func setUpTableView(){
        tableView = UITableView(frame: view.bounds, style: .plain)
        //tabView放在navigationBar下面
        view.insertSubview(tableView!, belowSubview: navigationBar)
        tableView?.dataSource = self
        tableView?.delegate = self
        //设置tablewView的内容缩进
        tableView?.contentInset = UIEdgeInsetsMake(navigationBar.bounds.height, 0, tabBarController?.tabBar.bounds.height ?? 49, 0)
        //修改指示器的缩进 -- 强行解包是为了拿到一个必有的 inset
        tableView?.scrollIndicatorInsets = tableView!.contentInset
        
        
        
        //创建刷新控件
        refreshControl = LSRefreshControl()
      
        tableView?.addSubview(refreshControl!)
        //添加监听方法
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
  
    
    //设置访客视图
    func setupVistorView() {
        let visitorView = LSVistorView(frame: view.bounds)
        view.insertSubview(visitorView, belowSubview: navigationBar)
        //1.把当前类的访客视图信息传给访客视图
        visitorView.vistorDicInfo = vistorInforDic
        //2.设置监听方法
        visitorView.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        visitorView.registerButton.addTarget(self, action: #selector(regiter), for: .touchUpInside)
        navItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(regiter))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .plain, target: self, action: #selector(login))
    }
    
    //设置导航条
    func setNavagationBar(){
        //添加导航条
        view.addSubview(navigationBar)
        //将item设置给 bar
        navigationBar.items = [navItem]
        //设置navBar 的渲染颜色
        navigationBar.barTintColor = UIColor.cz_color(withHex: 0xf6f6f6)
        //设置标题颜色
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
        //设置Iterm的颜色
        navigationBar.tintColor = UIColor.orange
    }
}

//MARK:- UITableViewDelegate/UITableViewDataSource
extension LSBaseViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    //基类 只是准备方法，子类负责具体实现
    //子类的数据源方法 不需要super
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         //判断是否最后一行 (最大section的最后一行)
        let row = indexPath.row
        let section = tableView.numberOfSections - 1
        let count = tableView.numberOfRows(inSection: section)
        
        if row == (count - 1) && !isPullRefresh {
           // print("刷新表格")
            isPullRefresh = true
            //开始刷新
            loadData()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 10
    }
}
