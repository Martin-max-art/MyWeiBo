//
//  LSNetworkManager.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/15.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

enum LSHTTPMethod{
    case GET
    case POST
}
//网络管理工具
class LSNetworkManager: AFHTTPSessionManager {
    //静态区 且是常量
    //闭包第一种写法
//    static let shared = { () ->LSNetworkManager in
//       //实例化对象
//        let instance = LSNetworkManager()
//        
//        return instance
//    }()
    
    //闭包第二种写法
    static let shared: LSNetworkManager = {
        //实例化对象
        let instance = LSNetworkManager()
        
        //设置反序列化支持的数据类型
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        return instance
    }()

    
    
//    //访问令牌
//    var accessToken:String?//= "2.00MoeccDmWnAHE4b82a582fd3E231E"
//    //uid
//    var uid: String? = "15581554271"
    
    //用户账户的懒加载属性
    lazy var userAccount = LSUserAccount()
    
    
    
    var userLogon:Bool{
        return userAccount.access_token != nil
    }
    
    
    
    //专门负责拼接token 的网络请求方法
    func tokenRequest(method : LSHTTPMethod = .GET,urlString : String,parameters: [String : AnyObject]?,completion: @escaping (_ json: Any?, _ isSuccess: Bool)->()) {
       
        //如果没有token 直接返回
        guard let token = userAccount.access_token else {
           
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LSUserHaveLoginNotification), object: nil)
            
            completion(nil, false)
            return
        }
        
        //判断字典是否存在
        var para = parameters
        
        if para == nil {
            para = [String : AnyObject]()
        }
       
        para?["access_token"] = token as AnyObject?
        //调用request方法
        request(urlString: urlString, parameters: para , completion: completion)
    }
    
    
    //使用一个函数封装GET / POST请求
    func request(method : LSHTTPMethod = .GET,urlString : String,parameters : [String : AnyObject]?,completion: @escaping (_ json: Any?, _ isSuccess: Bool)->()){
       //成功回调
        let success = { (task: URLSessionDataTask, json: Any?)->() in
            completion(json, true)
        }
        //错误回调
        let failure = { (task: URLSessionDataTask?, error: Error)->() in
            print("请求失败\(error)")
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("token过期了")
                
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: LSUserHaveLoginNotification), object: "badToken")
            }
            completion(nil, false)
        }
       
        if method == .GET {
           get(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
            
        }else{
            
           post(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
}
