//
//  WBMainViewController.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/9.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
import SVProgressHUD
class LSMainViewController: UITabBarController {

    // 定时器
    var time: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //创建子控制器
        setUpChildViewControllers()
        //创建中间的➕
        setUpAddButton()
        //创建定时器
        setupTimer()
        //设置新特性界面
        setupNewfeatureVAiews()
        
        
        //设置代理
        delegate = self
        
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(userLogin), name: NSNotification.Name(rawValue: LSUserHaveLoginNotification), object: nil)
        

    }
    
    deinit {
        //销毁定时器
        time?.invalidate()
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:设备方向
//    - 使用代码控制设备的方向，好处，可以在在需要横屏的时候，单独处理！
//    - 设置支持的方向之后，当前的控制器及子控制器都会遵守这个方向！
//    - 如果播放视频，通常是通过 modal 展现的！
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
  
    //MARK:按钮监听方法
    //FIXME: 没有实现
    func addBtnStatues() {
       print("按钮被点击了")
        /*测试横竖屏*/
//        let vc = UIViewController()
//        vc.view.backgroundColor = UIColor.cz_random()
//        let nav = UINavigationController(rootViewController: vc)
//        present(nav, animated: true, completion: nil)
        
    }
    //MARK: - 监听登录按钮的点击方法
    func userLogin(noti: Notification){
        print("用户登录通知\(noti)")
        var when = DispatchTime.now()
        
        if noti.object != nil{
            //渐变的
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.showInfo(withStatus: "用户登录已经超时，需要重新登录")
            //修改延迟时间
            when = DispatchTime.now() + 2
        }
        DispatchQueue.main.asyncAfter(deadline: when) {
            SVProgressHUD.setDefaultMaskType(.clear)
            //展现登录控制器
            let nvc = UINavigationController(rootViewController: LSWBOAuthViewController())
            self.present(nvc, animated: true, completion: nil)
        }
       
        
    }
    //MARK:私有控件 --中间的➕按钮
   lazy var addBtn:UIButton = UIButton.cz_imageButton("tabbar_compose_icon_add", backgroundImageName: "tabbar_compose_button")
}

//MARK:设置新特性界面
extension LSMainViewController{
    
    fileprivate func setupNewfeatureVAiews(){
       //1.判断是否登录
        if !LSNetworkManager.shared.userLogon{//不登录什么也不干
            return
        }
        
       //2.如果更新，显示新特性，否则显示欢迎
        let v: UIView = isNewVersion ? LSNewFeatureView.newFeatureView() : LSWelcomeView.welcomeView()
        view.addSubview(v)
        
    }
    //备注:extension 中可以有计算型属性，不会占用存储空间
    fileprivate var isNewVersion:Bool{
        //1.取当前的版本号
        let currentVersion = Bundle.main.infoDictionary?["CFBundleshortVersionString"] as? String ?? ""
        print("当前版本\(currentVersion)")
      
        //2.取保存在document(iTunes会备份) 目录中的之前的版本号
          let path: String = ("version" as NSString).cz_appendTempDir()
          let sandboxVersion = try? String(contentsOfFile: path)
        print("沙盒版本\(sandboxVersion)")
        _ = try? currentVersion.write(toFile: path, atomically: true, encoding: .utf8)
        return currentVersion != sandboxVersion
    }
}
//MRAK: -UITabBarControllerDelegate
extension LSMainViewController: UITabBarControllerDelegate{
    //将要选择 TabBarItem
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("将要切换到\(viewController)")
        
        
        //1.获取控制器在数组中的索引
        let index = (childViewControllers as NSArray).index(of: viewController)
        //2.判断当前索引是首页，同事idx也是首页，重复点击首页按钮
        if selectedIndex==0 && index == selectedIndex{//重复点击首页按钮
            print("点击首页")
            //3.让表格视图滚动到顶部
            //a获取控制器
            let nav = childViewControllers[0] as! UINavigationController
            let vc = nav.childViewControllers[0] as! LSHomeViewController
            //b滚到顶部
            vc.tableView?.setContentOffset(CGPoint(x:0,y:-64), animated: true)
            
            //4.刷新数据 - 增加延迟，保证表格先滚动到顶部再刷新
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: { 
               vc.loadData()
            })
            //5.清除tabItem 的badgeNumber和应用程序的badgeNumber
            vc.tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        
        //判断目标控制器是否是 UIViewController
        return !viewController.isMember(of: UIViewController.self)
    }
}

//微博时钟相关方法
extension LSMainViewController {
    func setupTimer() {
        time = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    //定时检查  给tabBar加小红点
    @objc private func updateTimer() {
        
        if !LSNetworkManager.shared.userLogon {
            return
        }
        
        LSNetworkManager.shared.unreadCount { (count) in
            print("\(count)条新微博")
            self.tabBar.items?[0].badgeValue = count > 0 ? "\(count)" : nil
            //设置App的badgeNumber 
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
}


//extension 类似于OC中的分类，在Swift中还可以用来切分代码块
//可以把相近功能的函数，放在一个 extension中
//便于代码维护
//注意：和OC的分类一样，extension中不能定义属性
//MARK: - 设置界面
extension LSMainViewController{
    
    
    //MARK:设置➕号按钮
    func setUpAddButton() {
        tabBar.addSubview(addBtn)
        //计算按钮的宽度 减一的目的是将内缩进减小 让 ➕号按钮增大宽度
        let width = tabBar.bounds.width / CGFloat(childViewControllers.count)
        //OC中 用CGRectInset 正数向内缩进，负数向外扩展
        addBtn.frame = tabBar.bounds.insetBy(dx: 2 * width, dy: 0)
        
        //按钮监听方法
        addBtn.addTarget(self, action: #selector(addBtnStatues), for: .touchUpInside)
    }
    

    //MARK:设置子控制器
   func setUpChildViewControllers() {
    
//    let array:[[String : AnyObject]] = [["clsName":"LSHomeViewController" as AnyObject,"title":"首页" as AnyObject,"imageName":"home" as AnyObject,"vistorInforDic":["imageName":"", "message":"关注一些人，回这里看看有什么惊喜"] as AnyObject],
//                                        
//            ["clsName":"LSMessageViewController" as AnyObject,"title":"消息" as AnyObject,"imageName":"message_center" as AnyObject,"vistorInforDic":["imageName":"visitordiscover_image_message", "message":"登录后，别人发给你的消息，发给你的评论，都会在这里收到通知"] as AnyObject],
//            
//            ["clsName":"UIViewController" as AnyObject],
//            
//            ["clsName":"LSDisCoverViewController" as AnyObject,"title":"发现" as AnyObject,"imageName":"discover" as AnyObject,"vistorInforDic":["imageName":"visitordiscover_image_message", "message":"登录后，最新、最热的微博尽在掌握，不再会与实事潮流擦肩而过"] as AnyObject],
//            
//            ["clsName":"LSMineViewController" as AnyObject,"title":"我的" as AnyObject,"imageName":"profile" as AnyObject,"vistorInforDic":["imageName":"visitordiscover_image_profile", "message":"登录后你的微博、相册、个人资料都会在这里展示"] as AnyObject]]
    
    
    
    //测试数据格式是否正确---转换成plist 更加直观
    //  (array as NSArray).write(toFile: "/Users/lishaopeng/Desktop/demo.plist", atomically: true)
    //数组 -> json //将界面数据输出到json
//   let data = try!JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted])
//   (data as NSData).write(toFile: "/Users/lishaopeng/Desktop/demo.json", atomically: true)
    
    
    
    
    //0获取沙河 json路径
    let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let jsonPath = (docDir as NSString).appendingPathComponent("demo.json")
    //加载data
    var data = NSData(contentsOfFile: jsonPath)
    if data == nil {//网络上加载的是否有内容 没有就加载本地的
        //从本地加载
        let path = Bundle.main.path(forResource: "demo.json", ofType: nil)
        data = NSData(contentsOfFile: path!)
    }
    //data 一定有内容 
    //反序列化成数组
    guard let array = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [[String : AnyObject]] else {
        return
    }
    
        var  arrayM  = [UIViewController]()
        for dic in array! {
            arrayM.append(controller(dic: dic))
        }
        viewControllers = arrayM

    }
    
        private func controller(dic: [String: AnyObject]) -> UIViewController {
            //1.取字典的内容
            guard let clsName = dic["clsName"] as? String,
            let title = dic["title"] as? String,
            let imageName = dic["imageName"] as? String ,
            let cls = NSClassFromString(Bundle.main.nameSpace + "." + clsName) as? LSBaseViewController.Type,
            let vistorDic = dic["vistorInforDic"] as? [String : String]
            else {
                return UIViewController()
            }
            //2.创建视图控制器
            let vc = cls.init()
            
            //设置控制器的视图信息
            vc.vistorInforDic = vistorDic
            
            //3.设置图像
            vc.tabBarItem.image = UIImage(named: "tabbar_" + imageName)
            vc.tabBarItem.selectedImage = UIImage(named: "tabbar_" + imageName + "_selected")?.withRenderingMode(.alwaysOriginal)
        
            //4.设置标题
            vc.title = title
            vc.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.orange], for: .highlighted)
            vc.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14)], for: .normal)
            
            
            let nav = LSNavgationController(rootViewController: vc)
            return nav
     
        }
}
